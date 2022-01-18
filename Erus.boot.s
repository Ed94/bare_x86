; Print HEx

; x86 
; 16-bit - Real Mode, V86 Mode

; https://codereview.stackexchange.com/questions/230755/display-hexadecimal-value-stored-at-a-register


%include "AAL.x86.s"
%include "AAL.x86.routines.macros.s"


; 16-Bit Mode
[BITS	16]
; The ORG directive specifies the starting address of a segment
[ORG	Mem_BootSector_Start]


start:
	mov 	BX, Mem_BootSector_Start

	mov	AH, BIOS_Wait
	mov	CX, 0x10
int	SystemService

;	Exclusive-OR (xor'ing a value to itself zeros the value)
	xor 	AX, AX
;	Set Data Segment and Extra Segment to 0x0000
	mov	DS, AX
	mov	ES, AX
;	Set Stack Segment (SS) to to 0x0000
	mov 	SS, AX
;	Set Stack Pointer (SP) to the start of the boot sector.
	mov 	SP, BX

	mov 	BX, Str_Erus
	mov	CX, 4
	push	CX
call 	out_string
	pop	CX

	mov	BX, Str_PostMsg
	mov	CX, 22
	push	CX
call	out_string
	pop	CX

	mov	AH, BIOS_Wait
	mov	CX, 0x10
int	SystemService

	mov 	AH, Video_SetMode
	mov 	AL, VideoMode_Text_80x25
int	VideoService	

	mov 	BX, Str_Erus
	mov	CX, 4
	push	CX
call 	out_string
	pop	CX

; Idle
hang :
jmp short hang

%include "AAL.x86.routines.s"

; Data
Str_Erus: db 'Erus'
Str_PostMsg : db '... taking over boot', 0xA, 0xD

;=============================================================================================================
; Wrap up
;=============================================================================================================
; Byte pad 512 bytes (zeroed)
times 	510-$+start 	db 0
; Master Boot Record signature
db 	0x55
db 	0xAA
