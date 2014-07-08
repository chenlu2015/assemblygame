; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include trig.inc	

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           		;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  256 / PI   (use this to find the table entry for a given angle
								;;              it is easier to use than divison would be)

.CODE
;; Define the functions FixedSin and FixedCos
;; Since we have thoroughly covered defining functions in class, its up to you from here on out...
;; Remember to include the 'ret' instruction or your program will hang
;; Also, don't forget to set your return values

FixedSin PROC dwAngle:FIXED
;;    To convert a FIXED value in eax into an integer:  sar eax, 16
;;    To convert an integer value in eax into a FIXED:  shl eax, 16
	mov eax, dwAngle
	mov ebx, eax
	xor esi, esi ; 0 flag
	xor edi, edi ; 2nd 0 flag
	
	shr ebx, 31
	jnz CASE5
TESTAGAIN:	
	cmp eax, TWO_PI
	jge CASE4
	cmp eax, PI
	jge CASE3
	cmp eax, PI_HALF
	jge CASE2
	;else jmp case 1

;CASE1 [0,Pi/2)
;angle in eax
CASE1:
	xor edx, edx
	mov ebx, PI_INC_RECIP
	imul ebx
	mov eax, edx ; index
	shl eax, 1 ; multiply by 2
	jmp ENDSWITCH
	
;CASE [Pi/2, Pi)
;angle in eax
CASE2:
	mov ebx, PI
	sub ebx, eax
	xor edx, edx
	mov eax, ebx
	mov ebx, PI_INC_RECIP
	imul ebx
	mov eax, edx ;index
	shl eax, 1 ; multiply by 2
	jmp ENDSWITCH

;CASE3 [Pi, 2Pi)
; sin(x+pi) = -sin(x)
CASE3:
	sub eax, PI ; x-180 
	inc esi ; need to negate
	jmp TESTAGAIN

;CASE4 [2Pi, Inf)
; sin(x+pi) = -sin(x)	
CASE4:
	sub eax, TWO_PI; x-360
	jmp TESTAGAIN
;CASE5[-inf, 0)
CASE5:
	not eax
	inc eax
	inc edi
	jmp TESTAGAIN
;eax = index *2
;return sina
ENDSWITCH:	
;esi = flagcheck if need to negate
	mov ebx, OFFSET SINTAB 	;sintab address
	add ebx, eax 			;move to right location
	xor eax, eax
	mov ax, [ebx]
	
	cmp esi, 0
	jnz NEGATIVE ; check if need to negate. if not, fall
	
	jmp FALL
NEGATEAGAIN:
	not eax
	inc eax
	jmp LAST
NEGATIVE:
	not eax
	inc eax
FALL:
	cmp edi, 0
	jnz NEGATEAGAIN ; check if need to negate. if not, fall
LAST:
	ret
FixedSin ENDP
	
FixedCos PROC dwAngle:FIXED
	mov eax, dwAngle
	add eax, PI_HALF
	INVOKE FixedSin, eax
	ret
FixedCos ENDP
	
END
