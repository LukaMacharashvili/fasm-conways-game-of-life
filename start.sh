#!/usr/bin/env bash

rm output.txt
fasm main.asm
./main > output.txt
open output.txt
