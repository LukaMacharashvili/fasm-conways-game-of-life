# Conway's Game of Life written in Flat Assembler (FASM)

## How to run:
```bash
fasm main.asm
./main
```

## How to use:
1. Change init_matrix in main.asm to your liking
2. Available Conway's Game of Life patterns: Glider, Blinker, Block
3. Example
```asm
macro init_matrix
{
    mov r8, matrix1
    mov r9, matrix2

    glider r8 ; <--- Change this to blinker or block
    glider r9 ; <--- Change this to blinker or block
}
```

## TODOs:
- [ ] Use graphics instead of text
