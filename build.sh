#!/bin/sh


gcc -DUSE_TCL_STUBS -I"./tcl8.6/include" -L"./tcl8.6/lib" -Wall -Wextra -Os -static -static-libgcc -ffunction-sections -fdata-sections -Wl,-gc-sections -nostartfiles -shared ./source/lametta.c -o lametta.so -ltclstub8.6
