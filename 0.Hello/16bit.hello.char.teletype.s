; Hello world.

; x86 
; 16-bit - Real Mode, V86 Mode

%include "AAL.x86.S"


; 16-Bit Mode
[BITS	16]
; The ORG directive specifies the starting address of a segment
[ORG	Mem_BootSector_Start]


start :

textmode_ClearScreen:
; 	Params
	mov AH, Video_SetMode	
	mov AL, VideoMode_Text_40x25
;	Call Interrupt
int	VideoService			

teletype_HelloWorld	:
	mov BH, 0x0	; Make sure the Active page is the first
	mov AH, Video_TeleType
	mov AL, 'H'
int	VideoService
	mov AL, 'e'
int	VideoService
	mov AL, 'l'
int	VideoService
	mov AL, 'l'
int	VideoService
	mov AL, 'l'
int	VideoService
	mov AL, 'o'
int	VideoService
	mov AL, ' '
int	VideoService
	mov AL, 'W'
int	VideoService
	mov AL, 'o'
int	VideoService
	mov AL, 'r'
int	VideoService
	mov AL, 'l'
int	VideoService
	mov AL, 'd'
int	VideoService

hang :
jmp short hang


; Byte pad 512 bytes (zeroed)
times 	510-$+start 	db 0
; Master Boot Record signature
db 	0x55
db 	0xAA
