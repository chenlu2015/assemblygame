; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;
;	Author: Chen Lu
;   Description: Routine that draws 17 stars at fixed locations
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include stars.inc

.CODE

; Routine which uses DrawStarReg to create all the stars
DrawAllStars PROC 
	mov edi, 30
	mov esi, 50
	Call DrawStarReg

		mov edi, 30
	mov esi, 50
	Call DrawStarReg
	
		mov edi, 405
	mov esi, 305
	Call DrawStarReg
	
		mov edi, 200
	mov esi, 300
	Call DrawStarReg
	
		mov edi, 400
	mov esi, 375
	Call DrawStarReg
	
		mov edi, 150
	mov esi, 470
	Call DrawStarReg
	
		mov edi, 470
	mov esi, 200
	Call DrawStarReg
	
		mov edi, 130
	mov esi, 40
	Call DrawStarReg
	
    ret             ;; Don't delete this line
    
DrawAllStars ENDP

END
