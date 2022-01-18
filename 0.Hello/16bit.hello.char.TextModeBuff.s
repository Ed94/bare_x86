; Hello world.

; x86 
; 16-bit - Real Mode, V86 Mode

%include "AAL.x86.S"


; 16-Bit Mode
[BITS	16]
; The ORG directive specifies the starting address of a segment
[ORG	Mem_BootSector_Start]


; A label to the address in memory
; Auto calculated by the assembler
start :

textmode_ClearScreen		:
; 		Params
	mov AH, Video_SetMode
	mov AL, VideoMode_Text_80x25
; 		Call Interrupt
int	VideoService			

; 	Set Data segment to the text mode's memory buffer
mov	AX, Video_Text_MemBuffer
mov	DS, AX

%macro	SetChar 2
	; word     : 16-bit (2-byte) increments
	; [offset] : specifies offset in Data Segment (DS)
	; Character
	mov word [%1 * 2    ], %2
	; Attributes - Low: Black, High: White
	mov word [%1 * 2 + 1], 0x0F
%endmacro
	SetChar 0x00, 'H'
	SetChar 0x01, 'e'
	SetChar 0x02, 'l'
	SetChar 0x03, 'l'
	SetChar 0x04, 'o'
	SetChar 0x05, ' '
	SetChar 0x06, 'W'
	SetChar 0x07, 'o'
	SetChar 0x08, 'r'
	SetChar 0x09, 'l'
	SetChar 0x0A, 'd'

hang :
jmp short hang


; Byte pad 512 bytes (zeroed)
times 	510-$+start 	db 0
; Master Boot Record signature
db 	0x55
db 	0xAA
