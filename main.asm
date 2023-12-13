format ELF64 executable

SYS_write equ 1
SYS_exit equ 60
matrix_size equ 820
matrix_cols equ 40
matrix_rows equ 20
test_str db 'TEST', 10
new_line db 10
matrix db '                                        ', 10, '                                        ', 10, '                                        ', 10, '    ##                                  ', 10, '    ##                                  ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        '
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

;    cmp temp_val, 0
;    je check_1
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
    cell_exists offset - matrix_cols - 1
    jne check_5
    add rcx, 1
check_5:
    cell_exists offset - matrix_cols + 1
    jne check_6
    add rcx, 1
check_6:
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
    write 1, matrix, matrix_size   
    write 1, new_line, 1 
}

segment readable executable
entry main
main:
    display_matrix

    mov r10, 0  ; col counter

_start:
    add r10, 1

    mov r9, 0  ; row counter
outer_loop:
    ; Initialize column counter
    mov r8, 0  ; col counter

inner_loop:
    ; Calculate the offset for the current cell
    mov rax, r9         ; row
    imul rax, matrix_cols
    add rax, r8         ; col
    mov rbx, matrix     ; base address of matrix
    add rbx, rax        ; address of the current cell

    ; logic
    cell_exists rbx
    je exists

    sum_neighbors rbx, rax
does_not_exist:
    cmp rcx, 3
    je does_not_exist_add
    jne end_inner_loop
does_not_exist_add:
    add_cell rbx
    jmp end_inner_loop

exists:
    cmp rcx, 3
    jle exists_less_than_3
    je end_inner_loop
    remove_cell rbx
    jmp end_inner_loop
exists_less_than_3:
    cmp rcx, 2
    jle exists_less_than_2
    jmp end_inner_loop
exists_less_than_2:
    remove_cell rbx
    jmp end_inner_loop

end_inner_loop:
    ; Move to the next column
    add r8, 1
    cmp r8, matrix_cols
    jl inner_loop

    ; Move to the next row
    add r9, 1
    cmp r9, matrix_rows
    jl outer_loop

;    mov r11, 100000000
;delay_loop:
;    dec r11
;    jnz delay_loop

    display_matrix

    cmp r10, 100
    jle _start

    exit 0
