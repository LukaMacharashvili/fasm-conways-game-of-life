format ELF64 executable

SYS_write equ 1
SYS_exit equ 60
matrix_cols equ 40
matrix_rows equ 20
matrix_size equ matrix_cols * matrix_rows
test_str db 'TEST', 10
new_line db 10
matrix1 db '                                        ', '                                        ', ' #                                      ', '  #                                     ', '###                                     ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        '
matrix2 db '                                        ', '                                        ', ' #                                      ', '  #                                     ', '###                                     ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        '
clear_str db 27, '[2J', 27, '[H'

macro write fd, buf, count
{
    mov rax, SYS_write
    mov rdi, fd
    mov rsi, buf
    mov rdx, count
    syscall
}

macro clear
{
    write 1, clear_str, 7
}

macro exit code
{
    mov rax, SYS_exit
    mov rdi, code
    syscall
}

macro add_cell offset, location
{
    mov byte [location + offset], '#'
}

macro remove_cell offset, location
{
    mov byte [location + offset], ' '
}

macro cell_exists offset, location
{
    mov bl, byte [location + offset]
    cmp bl, '#'
}

macro cell_not_exists offset, location
{
    mov bl, byte [location + offset]
    cmp bl, ' '
}

macro sum_neighbors offset, location
{
    mov r10, matrix_cols

check_0:
    mov rax, offset
    add rax, 1
    mov rdx, 0
    div r10
    mov rax, 0
    cmp rdx, 0
    je check_3

    cell_exists offset + 1, location
    jne check_1
    add rax, 1
check_1:
    cell_exists offset - matrix_cols + 1, location
    jne check_2
    add rax, 1
check_2:
    cell_exists offset + matrix_cols + 1, location
    jne check_3
    add rax, 1
check_3:
    push rax
    mov rax, offset
    mov rdx, 0
    div r10
    pop rax
    cmp rdx, 0
    je check_6

    cell_exists offset - 1, location
    jne check_4
    add rax, 1
check_4:
    cell_exists offset - matrix_cols - 1, location
    jne check_5
    add rax, 1
check_5:
    cell_exists offset + matrix_cols - 1, location
    jne check_6
    add rax, 1
check_6:
    cell_exists offset - matrix_cols, location
    jne check_7
    add rax, 1
check_7:
    cell_exists offset + matrix_cols, location
    jne end_of_sum
    add rax, 1
end_of_sum:
    ; Placeholder
}

macro display_matrix
{
    mov rcx, 0
display_matrix_loop:
    mov r8, matrix1
    add r8, rcx

    push rcx
    write 1, r8, 1 ; This macro changes rcx for some reason, so we need to push and pop it
    pop rcx

    mov rax, rcx
    add rax, 1
    mov rdx, 0
    mov r9, matrix_cols

    div r9
    cmp rdx, 0
    jne display_matrix_next_iteration

    push rcx
    write 1, new_line, 1 ; This macro changes rcx for some reason, so we need to push and pop it
    pop rcx

display_matrix_next_iteration:
    add rcx, 1
    cmp rcx, matrix_size
    jl display_matrix_loop
}

macro copy_matrix matrix_target, matrix_source
{
    mov rcx, 0
copy_matrix_loop:
    mov r8, matrix_source
    add r8, rcx
    mov r9, matrix_target
    add r9, rcx

    mov bl, byte [r8]
    mov byte [r9], bl

    add rcx, 1
    cmp rcx, matrix_size
    jl copy_matrix_loop
}

segment readable executable
entry main
main:
_start:
    mov rcx, 0
main_loop:
    mov r8, matrix1
    mov r9, matrix2

    ; logic
    sum_neighbors rcx, r8
    cell_exists rcx, r8
    je exists

does_not_exist:
    cmp rax, 3
    je main_add_cell
    jne end_loop
main_add_cell:
    add_cell rcx, r9
    jmp end_loop

exists:
    cmp rax, 2
    jl main_remove_cell
    cmp rax, 3
    jg main_remove_cell
    jmp end_loop
main_remove_cell:
    remove_cell rcx, r9
    jmp end_loop

end_loop:
    add rcx, 1
    cmp rcx, matrix_size
    jl main_loop

    copy_matrix matrix1, matrix2
    display_matrix

    mov rcx, 0
delay_loop:
    add rcx, 1
    cmp rcx, 100000000 ; Change this value to change the delay
    jl delay_loop

    clear

    jmp _start

    exit 0
