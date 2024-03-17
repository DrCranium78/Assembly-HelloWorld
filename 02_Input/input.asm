;
;  input.asm
; 
;  Last Update: 16.03.2023
;  Author:      Frank Bjørnø
;
;          To assemble and link this program from the command line, use the following commands:
;          ml /c input.asm
;          link /subsystem:console /defaultlib:kernel32.lib /entry:main input.obj
;
;          This program demostrates a simple, but not necessarily the best way to get input from
;          the command line. This program also introduces arrays and local variables.
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

.stack 128


STD_INPUT_HANDLE  equ -10
STD_OUTPUT_HANDLE equ -11


GetStdHandle   proto, :dword
WriteConsoleA  proto, :dword, :ptr byte, :dword, :ptr dword, :ptr dword
ReadConsoleA   proto, :dword, :ptr byte, :dword, :ptr dword, :ptr dword


.data
hcin      dw 0
hcout     dw 0
prompt    db "Enter text: ", 0

;  declare the input buffer. 64 DUP(0) means 64 duplicates of zero, that is 
;  a 64 byte zero-initialized array. For an uninitalized array, we would
;  use DUP(?).
buffer    db 64 DUP(0)
buflen    dd 64


.code

main proc
		;  get input and output handles
	invoke GetStdHandle, STD_INPUT_HANDLE
	mov hcin, ax			
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov hcout, ax
	
		;  Prompt for input
	lea esi, prompt
	call     strlen	
	invoke WriteConsoleA, hcout, offset prompt, ecx, 0, 0
	
	
		;  Read input
	lea edi, buffer
	mov ecx, buflen	
	call     readcon
	
	
		;  display input string
	lea esi, buffer
	call     strlen
	invoke WriteConsoleA, hcout, offset buffer, ecx, 0, 0
	
	
		;  exit program
	xor eax, eax
	ret
main endp

;--------------------------------------------------------------------------------------------------------;
;     Procedure: readcon                                                                                 ;
;                Read input from the console buffer.                                                     ;
;     Input:     Address of buffer to store the input in EDI.                                            ;
;                Max number of characters to read in ECX                                                 ;
;     Return:    Number of characters read in EAX.                                                       ;
;     Registers: EAX, EDI                                                                                ;
;                                                                                                        ;
;     Note:      The default behavior of ReadConsoleA is to register (and count) the enter key as two    ;
;                characters; Carriage Return + Line Feed. This function accounts for this behavior by    ;
;                subtracting two from the count and overwrite the carriage return with a zero character. ;
;                When limiting the the number of input charcaters to the number in ECX, the caller       ;
;                should be advised that CR + LF is included in that number.                              ;
;--------------------------------------------------------------------------------------------------------;
readcon proc
	local sz:dword						;  store character count in local variable
	invoke ReadConsoleA, hcin, edi, ecx, addr sz, 0
	
	mov eax, sz
	sub eax, 2						;  subtract 2 from the count
	
	add edi, eax						;  add count to the buffer offset
	mov byte ptr[edi], 0					;  overwrite CR with NULL charcater
		
	ret
readcon endp

;--------------------------------------------------------------------------------------------------------;
;     Procedure: strlen                                                                                  ;
;                Count number of characters in a given string.                                           ;
;                The procedure doesn't count the string terminator, although ESI is incremented          ;
;                just beyond it.                                                                         ;
;     Input:     Address of string in ESI                                                                ;
;     Return:    Number of characters in ECX                                                             ;
;     Registers: AL, CX, ESI                                                                             ;
;--------------------------------------------------------------------------------------------------------;
strlen proc
	xor ecx, ecx						;  reset character count
	cld							;  clear direction flag so the lodsb instruction increments esi
a:
	lodsb							;  loads the current character (byte) pointed to by esi into AL and increments esi
	cmp  al, 0						;  al == 0?
	jz   done						;  if yes, we are done
	inc  ecx			    			;  if no, increment counter
	jmp  a            	     				;  loop back to a
done:
	ret			          			;  return control to caller
strlen endp

end
