;
;  fmt.asm
; 
;  Last Update: 02.03.2023
;  Author:      Frank Bjørnø
;
;          This program is written for the Microsoft Macro Assembler and runs in the Windows Console.
;          To assemble and link this program from the command line, use the following commands:
;          ml /c fmt.asm
;          link /subsystem:console /entry:main fmt.obj
;
;          This program demonstrates how to format a string using the WINAPI function wsprintfA. The
;          example inserts the values of four registers into a format string, which can be useful as
;          a way to debug a program.
; 
;  License:
;  
;          Copyright (C) 2023 Frank Bjørnø
;
;          1. Permission is hereby granted, free of charge, to any person obtaining a copy 
;          of this software and associated documentation files (the "Software"), to deal 
;          in the Software without restriction, including without limitation the rights 
;          to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
;          of the Software, and to permit persons to whom the Software is furnished to do 
;          so, subject to the following conditions:
;        
;          2. The above copyright notice and this permission notice shall be included in all 
;          copies or substantial portions of the Software.
;
;          3. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
;          INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
;          PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
;          HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
;          CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
;          OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;


.386
.model flat, stdcall

	;  if we include libraries, we can omit the /defaultlib: option when linking
includelib kernel32.lib
includelib   user32.lib

     ;  prototypes for functions in kernel32.lib.
GetStdHandle   proto, :dword
WriteConsoleA  proto, :dword, :ptr byte, :dword, :ptr dword, :ptr dword
ExitProcess    proto, :dword

	;  prototypes for functions in user32.lib. Note that the use of varargs requires C calling convention.
wsprintfA proto C :ptr byte, :ptr byte, :vararg


STD_OUTPUT_HANDLE equ -11


.stack 128

.data

hcout  dw 0
buffer db 64 dup(?)
fmt    db "EAX: %08x    EBX: %08x    ECX: %08x    EDX: %08x", 0

.code

main proc
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov hcout, ax

		;  set registers to known values for demonstration purposes.
	mov eax, 010h
	mov ebx, 0100h
	mov ecx, 01000h
	mov edx, 010000h
	
		;  format the output using the format string. string length is returned in eax.
	invoke wsprintfA, offset buffer, offset fmt, eax, ebx, ecx, edx	
	
	invoke WriteConsoleA, hcout, offset buffer, eax, 0, 0
	
	invoke ExitProcess, 0
main endp

end