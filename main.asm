format ELF64 executable

SYS_write equ 1
SYS_exit equ 60
matrix_size equ 800
matrix_cols equ 40
test_str db 'TEST', 10
matrix db '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        ', 10, '                                        '
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
    mov byte [matrix + offset], '#'
}

macro remove_cell offset
{
    mov byte [matrix + offset], ' '
}

macro cell_exists offset
{
    mov al, byte [matrix + eax]
    cmp al, '#'
}

macro cell_not_exists offset
{
    mov al, byte [matrix + eax]
    cmp al, ' '
}

macro sum_neighbors offset
{
    cell_exists offset - 1
    jne check_1
    ; increment neighbors count
check_1:
    cell_exists offset + 1
    jne check_2
    ; increment neighbors count
check_2:
    cell_exists offset - matrix_cols
    jne check_3
    ; increment neighbors count
check_3:
    cell_exists offset + matrix_cols
    jne check_4
    ; increment neighbors count
check_4:
    cell_exists offset - matrix_cols - 1
    jne check_5
    ; increment neighbors count
check_5:
    cell_exists offset - matrix_cols + 1
    jne check_6
    ; increment neighbors count
check_6:
    cell_exists offset + matrix_cols - 1
    jne check_7
    ; increment neighbors count
check_7:
    cell_exists offset + matrix_cols + 1
    jne end
    ; increment neighbors count
end:
}

macro display_grid
{
    clear
    write 1, matrix, matrix_size   
}

segment readable executable
entry main
main:
    mov eax, 0 ; col
    mov ebx, 0 ; row
    mov ecx, matrix_cols
    mov edx, ebx
    imul ebx, ecx
    add eax, ebx
    add eax, edx ; offset

    ; if cell exists and has 2 or 3 neighbors, it lives
    ; if cell does not exist and has 3 neighbors, it is born
    ; otherwise, it dies

    ; loop through each cell
    ; if cell exists, check neighbors
    ; if cell does not exist, check neighbors

    exit 0
