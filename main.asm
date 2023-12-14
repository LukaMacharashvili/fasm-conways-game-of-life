format ELF64 executable

SYS_write equ 1
SYS_exit equ 60
matrix_size equ 800
matrix_cols equ 40
matrix_rows equ 20
test_str db 'TEST', 10
new_line db 10
matrix db '#####################                   ', '##                                      ', '                                        ', '    ##                                  ', '    ##                                  ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                        ', '                                       #'
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

macro add_cell offset
{
    mov byte [offset], '#'
}

macro remove_cell offset
{
    mov byte [offset], ' '
}

macro cell_exists offset
{
    mov al, byte [offset]
    cmp al, '#'
}

macro cell_not_exists offset
{
    mov al, byte [offset]
    cmp al, ' '
}

macro sum_neighbors offset, temp_val
{
    mov rcx, 0
    mov r13, matrix_cols

    mov edx, 0
    div r13
    cmp edx, 0
    je check_1

    cell_exists offset - 1
    jne check_1
    add rcx, 1
check_1:
    cell_exists offset + 1
    jne check_2
    add rcx, 1
check_2:
    cell_exists offset - matrix_cols
    jne check_3
    add rcx, 1
check_3:
    cell_exists offset + matrix_cols
    jne check_4
    add rcx, 1
check_4:
    mov edx, 0
    div r13
    cmp edx, 0
    je check_5

    cell_exists offset - matrix_cols - 1
    jne check_5
    add rcx, 1
check_5:
    cell_exists offset - matrix_cols + 1
    jne check_6
    add rcx, 1
check_6:
    mov edx, 0
    div r13
    cmp edx, 0
    je check_7

    cell_exists offset + matrix_cols - 1
    jne check_7
    add rcx, 1
check_7:
    cell_exists offset + matrix_cols + 1
    je last_increment
last_increment:
    add rcx, 1
}

macro display_matrix
{
    mov r8, 0
display_matrix_loop:
    mov r9, matrix
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

segment readable executable
entry main
main:
    mov r12, 0

_start:
    add r12, 1

    mov r8, 0
main_loop:
    mov r9, matrix
    add r9, r8

    ; logic
    cell_exists r9
    je exists

    sum_neighbors r9, r8
does_not_exist:
    cmp rcx, 3
    je does_not_exist_add
    jne end_loop
does_not_exist_add:
    add_cell r9
    jmp end_loop

exists:
    cmp rcx, 3
    jle exists_less_than_3
    je end_loop
    remove_cell r9
    jmp end_loop
exists_less_than_3:
    cmp rcx, 2
    jle exists_less_than_2
    jmp end_loop
exists_less_than_2:
    remove_cell r9
    jmp end_loop

end_loop:
    add r8, 1
    cmp r8, matrix_size
    jl main_loop

    display_matrix

    cmp r12, 100
    jne _start
    write 1, test_str, 5

    exit 0
