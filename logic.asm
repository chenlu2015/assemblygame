; #########################################################################
;
;   logic.asm - Assembly file for EECS205 Assignment 4/5
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include stars.inc	
    include blit.inc
    include rotate.inc	
    include game.inc
    include keys.inc		
	
.DATA
floor DWORD 385
facing DWORD 1 ; 0 is left, 1 is right

scroll BYTE 0
grav BYTE 1
timeinair DWORD 0
shotsFired DWORD 0
killcount DWORD 0
time DWORD 0
.CODE

;; Define the function GameLogic
;; Since we have thoroughly covered defining functions in class, its up to you from here on out...

GameLogic PROC xinc:DWORD, yinc:DWORD

;; gamestates
;; 1 = normal
;; 2 = end
;;
	cmp gState, 2
	je ENDGAME
	
	inc time; increase game time
	
	;;check for collisions
	mov eax, charSprite.location.y 
	add eax, 31
	mov charSprite.bot, eax
	sub eax, 62
	mov charSprite.top, eax
	
	mov eax, charSprite.location.x
	add eax, 31
	mov charSprite.right, eax
	sub eax, 63 
	mov charSprite.left, eax
	
	;projectiles (FIREBALLS)
	cmp xinc, 0Dh ;return
	jne dontfire
	cmp shotsFired, 56 ;max shots = 3
	jg dontfire
	mov eax, offset fireballs
	add eax, shotsFired
	mov ebx, charSprite.location.x
	mov (AdvSprite PTR [eax]).location.x, ebx
	mov ebx, charSprite.location.y
	mov (AdvSprite PTR [eax]).location.y, ebx
	add shotsFired, 28 ;1 shot = 28bytes
dontfire:

	;update projectile positions
	mov eax, offset fireballs
	mov esi, 56
	add esi, eax
ll: 
	add (AdvSprite PTR [eax]).location.x, 3
	
	;update hitbox bounds on sprite
	mov ebx, (AdvSprite PTR [eax]).location.y 
	add ebx, 18
	mov (AdvSprite PTR [eax]).bot, ebx
	sub ebx, 36
	mov (AdvSprite PTR [eax]).top, ebx
	
	mov ebx, (AdvSprite PTR [eax]).location.x
	add ebx, 25
	mov (AdvSprite PTR [eax]).right, ebx
	sub ebx, 50
	mov (AdvSprite PTR [eax]).left, ebx
	
	;increment
	cmp eax, esi
	jge sk
	add eax, 28
	jmp ll
sk:
	
	;calculations for enemysprites
	mov eax, offset enemySprites
	mov esi, 28
	add esi, eax ;max
	


d3:
	sub (AdvSprite PTR [eax]).location.x, 3
	
	;update hitbox bounds on sprite
	mov ebx, (AdvSprite PTR [eax]).location.y 
	add ebx, 18
	mov (AdvSprite PTR [eax]).bot, ebx
	sub ebx, 36
	mov (AdvSprite PTR [eax]).top, ebx
	
	mov ebx, (AdvSprite PTR [eax]).location.x
	add ebx, 16
	mov (AdvSprite PTR [eax]).right, ebx
	sub ebx, 32 
	mov (AdvSprite PTR [eax]).left, ebx
		
		
	;compare to fireballs (NESTED LOOP)
	mov edx, offset fireballs
	mov ecx, 56
	add ecx, edx ;max
loo:
	;nest loop
	mov ebx, (AdvSprite PTR [edx]).top
	cmp ebx, (AdvSprite PTR [eax]).bot
	jg sk2
	mov ebx, (AdvSprite PTR [edx]).bot
	cmp ebx, (AdvSprite PTR [eax]).top
	jl sk2
	mov ebx, (AdvSprite PTR [edx]).right
	cmp ebx, (AdvSprite PTR [eax]).left
	jl sk2
	cmp ebx, (AdvSprite PTR [eax]).right
	jg sk2
	;;collision detected
	inc score
	mov edi, (AdvSprite PTR [eax]).location.x
	mov exp.location.x, edi
	mov edi, (AdvSprite PTR [eax]).location.y
	mov exp.location.y, edi
	mov fxState, 1
	
	add (AdvSprite PTR [eax]).location.x, 600
	add (AdvSprite PTR [edx]).location.x, 650
	sub shotsFired, 28
	

sk2:
	; increment
	cmp edx, ecx
	jge s4
	add edx, 28
	jmp loo
s4:


	;compare to char bounds
	mov ebx, charSprite.top
	cmp ebx, (AdvSprite PTR [eax]).bot
	jg f
	mov ebx, charSprite.bot
	cmp ebx, (AdvSprite PTR [eax]).top
	jl f
	mov ebx, charSprite.right
	cmp ebx, (AdvSprite PTR [eax]).left
	jl f
	cmp ebx, (AdvSprite PTR [eax]).right
	jg f
	mov gState, 2
	jmp ENDGAME

	
f:
	mov ebx, (AdvSprite PTR [eax]).location.x
	cmp ebx, -20
	jle r
	;;increment
	cmp eax, esi
	jge s3
	add eax, 28
	jmp d3
	
r:
	add (AdvSprite PTR [eax]).location.x, 1000
	jmp d3
s3:




	
	; facing left or right
	cmp xinc, 27h ;right
	jne dn
	add charSprite.location.x, 3
	mov facing, 1
	dn:
	cmp xinc, 25h ;left
	jne dnn
	sub charSprite.location.x, 3
	mov facing, 0
	dnn:
	
	
	cmp xinc, 20h ;spacebar
	jne knd
	sub charSprite.location.y, 10
	jmp SKIP
knd:
	;gravity
	mov eax, charSprite.location.y
	cmp eax, floor
    jg SKIP
	add charSprite.location.y, 1
	SKIP:
	


	;; bg sprite location updates
	mov eax, offset bgSprites
	mov esi, 444
	add esi, eax ;max
	
	;slow down the scrolling, scroll every third loop
	cmp scroll, 2
	jne s
d1:
	sub (Sprite PTR [eax]).location.x, 1
	
	mov ebx, (Sprite PTR [eax]).location.x
	cmp ebx, -450
	jle relocate
d2:
	cmp eax, esi
	jge s
	add eax, 12
	mov scroll, 0 ;set to 0
	jmp d1
	
relocate:
	add ebx, 1400
	mov (Sprite PTR [eax]).location.x, ebx
	jmp d2
	
s:
	inc scroll ;add 1
	
ENDGAME:

	cmp time, 20
	jl sss
	mov fxState, 0
	mov time, 0
sss:

INVOKE GameRender
ret
GameLogic ENDP

	
END
