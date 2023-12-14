format ELF64 executable

SYS_write equ 1
SYS_exit equ 60
matrix_size equ 800
matrix_cols equ 40
matrix_rows equ 20
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
    mov byte [offset + location], '#'
}

macro remove_cell offset, location
{
    mov byte [offset + location], ' '
}

macro cell_exists offset, location
{
    mov al, byte [offset + location]
    cmp al, '#'
}

macro cell_not_exists offset, location
{
    mov al, byte [offset + location]
    cmp al, ' '
}

macro sum_neighbors offset, location
{
    mov rcx, 0
    mov r10, matrix_cols

check_0:
    mov rax, offset
    add rax, location
    add rax, 1
    mov rdx, 0
    div r10
    cmp rdx, 0
    je check_3

    cell_exists offset, location + 1
    jne check_1
    add rcx, 1
check_1:
    cell_exists offset, location - matrix_cols + 1
    jne check_2
    add rcx, 1
check_2:
    cell_exists offset, location + matrix_cols + 1
    jne check_3
    add rcx, 1
check_3:
    mov rax, offset
    add rax, location
    mov rdx, 0
    div r10
    cmp rdx, 0
    je check_6

    cell_exists offset, location - 1
    jne check_4
    add rcx, 1
check_4:
    cell_exists offset, location - matrix_cols - 1
    jne check_5
    add rcx, 1
check_5:
    cell_exists offset, location + matrix_cols - 1
    jne check_6
    add rcx, 1
check_6:
    cell_exists offset, location - matrix_cols
    jne check_7
    add rcx, 1
check_7:
    cell_exists offset, location + matrix_cols
    jne end_of_sum
    add rcx, 1
end_of_sum:
    ; Placeholder
}

macro display_matrix
{
    mov r8, 0
display_matrix_loop:
    mov r9, matrix1
    add r9, r8

    write 1, r9, 1

    mov rax, r8
    add rax, 1
    mov rdx, 0
    mov r10, matrix_cols

    div r10
    cmp rdx, 0
    jne display_matrix_next_iteration

    write 1, new_line, 1

display_matrix_next_iteration:
    add r8, 1
    cmp r8, matrix_size
    jl display_matrix_loop
}

macro copy_matrix matrix_target, matrix_source
{
    mov r8, 0
copy_matrix_loop:
    mov r9, matrix_source
    add r9, r8
    mov r10, matrix_target
    add r10, r8

    mov al, byte [r9]
    mov byte [r10], al

    add r8, 1
    cmp r8, matrix_size
    jl copy_matrix_loop
}

segment readable executable
entry main
main:
_start:
    mov r8, 0
main_loop:
    mov r9, matrix1
    mov r11, matrix2

    ; logic
    sum_neighbors r8, r9
    cell_exists r8, r9
    je exists

does_not_exist:
    cmp rcx, 3
    je main_add_cell
    jne end_loop
main_add_cell:
    add_cell r8, r11
    jmp end_loop

exists:
    cmp rcx, 2
    jl main_remove_cell
    cmp rcx, 3
    jg main_remove_cell
    jmp end_loop
main_remove_cell:
    remove_cell r8, r11
    jmp end_loop

end_loop:
    add r8, 1
    cmp r8, matrix_size
    jl main_loop

    copy_matrix matrix1, matrix2

    display_matrix

    mov r8, 0
delay_loop:
    add r8, 1
    cmp r8, 100000000 ; Change this value to change the delay
    jl delay_loop

    clear

    jmp _start

    exit 0
