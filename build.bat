echo off
cls

SET CCFLAGS=-DUSE_TCL_STUBS -I".\tcl8.6\include" -Wall -Wextra -Os
SET LDFLAGS=-mwindows -L".\tcl8.6\lib" -static -static-libgcc -ffunction-sections -fdata-sections -Wl,-gc-sections -Wl,--add-stdcall-alias

gcc %CCFLAGS% -c ./source/lametta.c -o lametta.o
gcc %CCFLAGS% %LDFLAGS% -shared lametta.o ./source/lametta.def -o lametta.dll -lkernel32 -ltclstub86
strip --strip-all lametta.dll
