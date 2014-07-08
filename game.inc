; #########################################################################
;
;   game.inc - Includes for EECS205 Assignment 4/5
;
;
; #########################################################################

;; These are library routines that you will call (but do NOT have to implement)
BeginDraw PROTO
EndDraw PROTO

;; You should not need to modify these prototypes (actually, it would probably be bad)
GameInit PROTO
GameMain PROTO mouseStatus:DWORD, keyDown:DWORD, keyUp:DWORD

;; Useful Library Routines
DrawString PROTO x:DWORD, y:DWORD, string:PTR BYTE 
DrawInt PROTO x:DWORD, y:DWORD, value:DWORD

;; Feel free to modify the following
GameRender PROTO
GameLogic PROTO xinc:DWORD, yinc:DWORD

Point STRUCT
 x     DWORD  ?
 y     DWORD  ?
Point ENDS

Sprite STRUCT
bitmap    DWORD ?
location  Point<?,?>
Sprite ENDS

AdvSprite STRUCT
bitmap    DWORD ?
location  Point<?,?>
top  	  DWORD ?
bot  	  DWORD ?
left 	  DWORD ?
right 	  DWORD ?
AdvSprite ENDS


EXTERNDEF lpTyroneBmp : DWORD

EXTERNDEF charSprite	: AdvSprite
EXTERNDEF enemySprites  : AdvSprite
EXTERNDEF fireballs		: AdvSprite
EXTERNDEF exp			: Sprite
EXTERNDEF bgSprites 	: Sprite

EXTERNDEF mouseX:DWORD
EXTERNDEF mouseY:DWORD
EXTERNDEF charX:DWORD
EXTERNDEF charY:DWORD
EXTERNDEF facing:DWORD
EXTERNDEF gState:DWORD
EXTERNDEF fxState:DWORD
EXTERNDEF score: DWORD

