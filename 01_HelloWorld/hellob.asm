;
;  hellob.asm
; 
;  Last Update: 14.02.2023
;  Author:      Frank Bjørnø
;
;          This program is written for the Microsoft Macro Assembler and runs in the Windows Console.
;          To assemble and link this program from the command line, use the following commands:
;          ml /c hellob.asm
;          link /subsystem:console /defaultlib:kernel32.lib /entry:main hellob.obj
;
;          (/subsystem:console isn't really necessary for this program, but this is how
;           to link if the main procedure wasn't called 'main'.)
;
;          This program achieves exactly the same as HelloA.asm, but without hardcoding
;          the string length into the second invoke directive. 
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



;  The .386 directive enables assembly of nonprivileged instructions for the 80386 process and disables
;  instructions introduced with later processors. This program, because it uses 32 bit registers, requires 
;  at least this instruction set to run.
.386
.model flat, stdcall


;  the default stack size is 1024 bytes. We don't need anywhere near that to run this program.
.stack 128


STD_OUTPUT_HANDLE equ -11


GetStdHandle  proto, :dword
WriteConsoleA proto, :dword, :ptr byte, :dword, :ptr dword, :ptr dword


.data
msg   db "Hello world!", 0
hcout dw 0					;  handle to the standard output device (console)
n     dd 0                                      ;  use this to hold string length


.code

;  Placing the main part of the program in a procedure requires us to define entrypoint when linking.
;  Naming it 'main' enables the linker to infer the subsytem, otherwise subsytem has to be defined.
main proc
		invoke GetStdHandle, STD_OUTPUT_HANDLE
		mov hcout, ax		
		
		;  get string length to use in call to WriteConsoleA
		lea  esi, msg			;  load address of msg into ESI
		call strlen		        ;  call strlen to get length of string
		mov  n,   ecx			;  store result in n	
				
		invoke WriteConsoleA, hcout, offset msg, n, 0, 0		
main endp


;--------------------------------------------------------------------------------------------------------;
;     Procedure: strlen                                                                                  ;
;                Count number of characters in a given string.                                           ;
;                The procedure doesn't count the string terminator, although ESI is incremented          ;
;                just beyond it.                                                                         ;
;     Input:     Address of string in ESI                                                                ;
;     Return:    Number of characters in ECX                                                             ;
;     Registers: EAX, ECX, ESI                                                                           ;
;--------------------------------------------------------------------------------------------------------;
strlen proc
		xor ecx, ecx                    ;  reset character count
		cld                             ;  clear direction flag so the lodsb instruction increments ESI
a:
		lodsb                           ;  loads the current character (byte) pointed to by ESI into AL and increments ESI
		cmp  al, 0                      ;  AL == 0?
		jz   done			;  if yes, we are done
		inc  ecx                        ;  if no, increment counter
		jmp  a                          ;  loop back to a
done:
		ret                             ;  return control to caller
strlen endp

end                                             ;  end of program
