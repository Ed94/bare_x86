; TODO: Finish?
; Hello world.

; x86 
; 16-bit - Real Mode, V86 Mode


%include "AAL.x86.S"


; 16-Bit Mode
[BITS 16]


; The ORG directive specifies the starting address of a segment
[ORG 	BIOS_LoadCode_Address]


start :

textmode_ClearScreen		:
; 		Params
	mov AH, Video_SetMode	
	mov AL, VideoMode_Text_40x25
; 		Call Interrupt
int	VideoService			

textmode_CheckDisplayMode	:
	mov AH, Video_GetCurrentMode
int	VideoService
;	Return Values
	mov BH, AH
	mov BL, AL

; 	Print Cols
	mov AH, Video_TeleType
	mov AL, BH
int 	VideoService
; 	Print Mode
	mov AH, Video_TeleType
	mov AL, BL
int 	VideoService


hang :
jmp short ang


; Byte pad 512 bytes (zeroed)
times 	510-$+start 	db 0
; Master Boot Record signature
db 	0x55
db 	0xAA
