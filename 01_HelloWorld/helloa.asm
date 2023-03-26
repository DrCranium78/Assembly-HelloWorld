;
;  helloa.asm
; 
;  Last Update: 14.02.2023
;  Author:      Frank Bjørnø
;
;          This program is written for the Microsoft Macro Assembler and runs in the Windows Console.
;          To assemble and link this program from the command line, use the following commands:
;          ml /c helloa.asm
;          link /defaultlib:kernel32.lib helloa.obj
;
;          The purpose of this program is just to get it to run. 
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



;  a flat memory model is used for 32 bit programs
;  stdcall calling convention is used to call Win32 API functions
.model flat, stdcall


;  the equ directive is used to define constants
STD_OUTPUT_HANDLE equ -11

;  the proto directive is used to prototype a function or procedure, so that 
;  it can later be called using the invoke directive
GetStdHandle  proto, :dword
WriteConsoleA proto, :dword, :ptr byte, :dword, :ptr dword, :ptr dword


;  global data is stored in the data segment
.data
msg   db "Hello world!", 0
hcout dw 0					;  handle to the standard output device (console)


;  code goes in the code segment
.code

main:
		;  the invoke directive calls the given procedure, passing the arguments
		;  on the stack or in registers according to the standard calling convention
		invoke GetStdHandle, STD_OUTPUT_HANDLE
		mov hcout, ax		
		
		
		;  Write "Hello World!" to the screen buffer
		invoke WriteConsoleA, hcout, offset msg, 12, 0, 0		
end main
