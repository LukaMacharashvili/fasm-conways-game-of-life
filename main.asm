format ELF64 executable

debugging_str db 'Debugging', 10
new_line db 10
clear_str db 27, '[2J', 27, '[H'

SYS_write equ 1
SYS_exit equ 60

matrix_cols equ 50 ; Change this value to change the matrix size
matrix_rows equ 50 ; Change this value to change the matrix size
matrix_size equ matrix_cols * matrix_rows

matrix1 db matrix_size dup(' ')
matrix2 db matrix_size dup(' ')

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

; TODO: This macro can not be used twice, because of label conflicts
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

; TODO: This macro can not be used twice, because of label conflicts
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

; TODO: This macro can not be used twice, because of label conflicts
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

macro block location
{
    add_cell 0, location
    add_cell 1, location
    add_cell matrix_cols, location
    add_cell matrix_cols + 1, location
}

macro blinker location
{
    add_cell matrix_cols + 0, location
    add_cell matrix_cols + 1, location
    add_cell matrix_cols + 2, location
}

macro glider location
{
    add_cell 1, location
    add_cell matrix_cols + 2, location
    add_cell 2 * matrix_cols, location
    add_cell 2 * matrix_cols + 1, location
    add_cell 2 * matrix_cols + 2, location
}

macro gosper_glider_gun location
{
    ; Left square
    add_cell 10 * matrix_cols, location
    add_cell 10 * matrix_cols + 1, location
    add_cell 11 * matrix_cols, location
    add_cell 11 * matrix_cols + 1, location

    ; Left
    add_cell 8 * matrix_cols + 12, location
    add_cell 8 * matrix_cols + 13, location
    add_cell 9 * matrix_cols + 11, location
    add_cell 9 * matrix_cols + 15, location
    add_cell 10 * matrix_cols + 10, location
    add_cell 10 * matrix_cols + 16, location
    add_cell 11 * matrix_cols + 10, location
    add_cell 11 * matrix_cols + 14, location
    add_cell 11 * matrix_cols + 16, location
    add_cell 11 * matrix_cols + 17, location
    add_cell 12 * matrix_cols + 10, location
    add_cell 12 * matrix_cols + 16, location
    add_cell 13 * matrix_cols + 11, location
    add_cell 13 * matrix_cols + 15, location
    add_cell 14 * matrix_cols + 12, location
    add_cell 14 * matrix_cols + 13, location

    ; Right
    add_cell 6 * matrix_cols + 24, location
    add_cell 7 * matrix_cols + 22, location
    add_cell 7 * matrix_cols + 24, location
    add_cell 8 * matrix_cols + 20, location
    add_cell 8 * matrix_cols + 21, location
    add_cell 9 * matrix_cols + 20, location
    add_cell 9 * matrix_cols + 21, location
    add_cell 10 * matrix_cols + 20, location
    add_cell 10 * matrix_cols + 21, location
    add_cell 11 * matrix_cols + 22, location
    add_cell 11 * matrix_cols + 24, location
    add_cell 12 * matrix_cols + 24, location

    ; Right square
    add_cell 8 * matrix_cols + 34, location
    add_cell 8 * matrix_cols + 35, location
    add_cell 9 * matrix_cols + 34, location
    add_cell 9 * matrix_cols + 35, location
}

; Change this to change the initial state
macro init_matrix
{
    mov r8, matrix1
    mov r9, matrix2

    gosper_glider_gun r8
    gosper_glider_gun r9
}

segment readable executable
entry main
main:
    init_matrix
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
    cmp rcx, 99999999 ; Change this value to change the delay
    jl delay_loop

    clear

    jmp _start

    exit 0
