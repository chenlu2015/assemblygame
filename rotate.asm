; #########################################################################
;
;   rotate.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include trig.inc		; Useful prototypes
    include rotate.inc		; 	and definitions


.DATA
	;; You may declare helper variables here, but it would probably be better to use local variables

	
	maxX DWORD 639
	maxY DWORD 479
	
	bmWidth DWORD ?
	bmHeight DWORD ?
	
	transpValue BYTE ? ;transparent value
	
	bitmapADDR DWORD ?  ;color value start address
	
	screenX DWORD ? ;xlocation to draw
	screenY DWORD ? ;ylocation to draw
	
	centerX DWORD ? ;center xloc
	centerY DWORD ? ;center yloc

.CODE
;; Define the functions BasicBlit and RotateBlit
;; Take a look at rotate.inc for the correct prototypes (if you don't follow these precisely, you'll get errors)
;; Since we have thoroughly covered defining functions in class, its up to you from here on out...
;; Remember to include the 'ret' instruction or your program will hang


BasicBlit PROC uses edx esi edi eax lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD 
;; fill in code
	; edx - srcBitMap
	; esi - x coord of mouse
	; 	- y coord of mouse
	mov edx, lpBmp
	mov esi, xcenter
	mov edi, ycenter
	Call BlitReg
	
	ret
BasicBlit ENDP


RotateBlit PROC uses edx esi edi eax lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:DWORD
	
	LOCAL cosa:DWORD, sina:DWORD, shiftX:DWORD, shiftY:DWORD, dstWidth:DWORD, dstHeight:DWORD, dstX:DWORD, dstY:DWORD, srcX:DWORD, srcY:DWORD
	
	mov eax, 0
	INVOKE FixedCos, angle
	mov cosa, eax
	
	mov eax, 0
	INVOKE FixedSin, angle
	mov sina, eax
	
	mov esi, lpBmp ; srcBitMap
	mov edi, lpDisplayBits ; screen
	
	mov al, (EECS205BITMAP PTR [esi]).bTransparent 
	mov transpValue, al 				;srcBitMap transparent value
	
	mov eax, (EECS205BITMAP PTR [esi]).lpBytes
	mov bitmapADDR, eax 				;srcBitMap color value start address
	
	mov eax,(EECS205BITMAP PTR [esi]).dwWidth 
	mov bmWidth, eax					;srcBitMap Width
	
	mov eax,(EECS205BITMAP PTR [esi]).dwHeight 
	mov bmHeight, eax 					;srcBitMap Height
	
	mov eax, xcenter
	mov centerX, eax
	mov eax, ycenter
	mov centerY, eax

	mov eax, bmWidth ;(EECS205BITMAP PTR [esi]).dwWidth * cosa / 2 
	imul cosa
	sal edx, 16
	sar eax, 16
	mov dx, ax
	sar edx, 1 ;div2
	mov ebx, edx
	mov eax, bmHeight ; (EECS205BITMAP PTR [esi]).dwHeight * sina / 2
	imul sina
	sal edx, 16
	sar eax, 16
	mov dx, ax
	sar edx, 1
	sub ebx, edx ; subtract
	mov shiftX, ebx
	
	mov eax, bmWidth
	imul sina
	sal edx, 16
	sar eax, 16
	mov dx, ax
	sar edx, 1 ;div2
	mov ebx, edx
	mov eax, bmHeight
	imul cosa
	sal edx, 16
	sar eax, 16
	mov dx, ax
	sar edx, 1
	add ebx, edx
	mov shiftY, ebx
	
	mov eax, bmWidth
	add eax, bmHeight
	mov dstWidth, eax
	mov dstHeight, eax
	
	neg eax
	mov dstX, eax
	mov dstY, eax

;dstX, dstY = loop counters
yLoop:
	mov eax, dstX ;srcX = dstX*cosa + dstY*sina; 
	imul cosa
	sal edx, 16
	sar eax, 16
	mov dx, ax
	mov ebx, edx
	
	mov eax, dstY
	imul sina
	sal edx, 16
	sar eax, 16
	mov dx, ax
	add edx, ebx
	mov srcX, edx

	mov eax, dstY ;srcY = dstY*cosa – dstX*sina;
	imul cosa
	sal edx, 16
	sar eax, 16
	mov dx, ax
	mov ebx, edx
	
	mov eax, dstX
	imul sina
	sal edx, 16
	sar eax, 16
	mov dx, ax
	sub ebx, edx
	mov srcY, ebx
	

	;; check if off srcbitmap
	cmp srcX, 0
	jl SKIP
	cmp srcY, 0
	jl SKIP
	mov eax, bmWidth
	cmp srcX, eax
	jg SKIP
	mov eax, bmHeight
	cmp srcY, eax
	jg SKIP
	
	mov eax, xcenter
	add eax, dstX
	sub eax, shiftX
	mov screenX, eax ; screenX = xcenter+dstX­shiftX

	mov eax, ycenter
	add eax, dstY
	sub eax, shiftY
	mov screenY, eax  ; screenY = ycenter+dstY­shiftY

	;; check if off screen
	cmp screenX, 0
	jl SKIP
	cmp screenY, 0
	jl SKIP
	mov eax, maxX
	cmp screenX, eax
	jg SKIP
	mov eax, maxY
	cmp screenY, eax
	jg SKIP
	
	;; lpDisplayBits[screenY*dwPitch + screenX]
	mov eax, screenY
	mul dwPitch
	add eax, screenX
	mov ebx, eax	
	
	;; srcBitmap->lpBytes[bmpY*(srcBitmap->dwWidth)+bmpX]
	mov eax, bmWidth
	mul srcY
	add eax, srcX
	mov edx, bitmapADDR
	add edx, eax
	mov al, [edx]
	
	;; check transparency
	cmp al, transpValue ; 
	je SKIP
	
	;; change the color
	mov BYTE PTR[edi+ebx], al
	
	SKIP:
	;dstX, dstY = loop counters
	; esi = lpBmp ; bitmap to draw (src)
	; edi = lpDisplayBits ; screen bitmap
	mov eax, dstHeight
	cmp dstY, eax
	jg xLoop
	
	;if not at end of the
	inc dstY
	jmp yLoop 


xLoop:
	inc dstX    ;increment X
	mov eax, dstHeight
	neg eax
	mov dstY, eax ;reset bmpY
	
	mov eax, dstWidth
	cmp dstX, eax
	jl yLoop 

;; fall if bmpY > bmHeight
fall: 

	ret
RotateBlit ENDP



		

END
