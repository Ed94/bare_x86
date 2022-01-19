; x86 
; 16-bit - Real Mode, V86 Mode

%include "AAL.x86.s"


%macro String_Out 2
	mov	BX, %1
	mov	AX, %2
	push	AX
call	out_string
	pop	AX
%endmacro


; 16-Bit Mode
[BITS	16]
; The ORG directive specifies the starting address of a segment
[ORG	Mem_BootSector_Start]


;=============================================================================================================
; Boot Sector Code
;=============================================================================================================
start:
;	Give some times before starting
	mov	AH, BIOS_Wait
	mov	CX, 0x10
int	SystemService

	xor 	AX, AX
;	Set Data Segment and Extra Segment to 0x0000
	mov	DS, AX
	mov	ES, AX
;	Set Stack Segment (SS) to to 0x0000
	mov 	SS, AX
;	Set Stack Pointer (SP) to the start of the boot sector.
	mov 	BX, Mem_BootSector_Start
	mov 	SP, BX

String_Out	PostMsg, [PostMsg_len]

	mov	AH, BIOS_Wait
	mov	CX, 0x05
int	SystemService


;	Loading the code from disk (storage)
	mov	DH, 0x0		; Head NUm
	mov	DL, 0x0		; Drive Num
	mov	CH, 0x0 	; Track Num
	mov	CL, 0x02	; Starting Sector
;	Setup ES:BX Memory address/segment
	mov	BX, 0x1000	; ES:BX : 0x1000:0x0
	mov	ES, BX
	mov	BX, 0x0

;	Read Disk (Storage)
	mov	AH, Disk_ReadIntoMemory
	mov	AL, 0x01	; Num Sectors
int	DiskService

String_Out	SendoffMsg, [SendOffMsg_len]

	mov	AH, BIOS_Wait
	mov	CX, 0x10
int	SystemService

;	Jump if carry flag
	; jc	error

	; cmp 	DH, AL
	; jne 	error

;	Reset segment registers for ram
	mov	AX, 0x1000
	mov	DS, AX
	mov	DS, AX
	mov	ES, AX
	mov	FS, AX
	mov	GS, AX
	mov	SS, AX

;	Heading to 16bit.scratch
	jmp 	0x1000:0x0	


;=============================================================================================================
; Routines
;=============================================================================================================
; Print out an ascii string of speicifed length
out_string:
; Arg - BX: String
%define argLen	BP + 4	; String Length
;	Store previous state of BP and set it to SP
	; pusha				; 14 bytes
	push	BP			; 4 bytes
	mov 	BP, SP
;	Using the source index
	push 	SI			; 0 bytes...
	xor	SI, SI

;	Backup BX for later
	mov	CX, BX			
	mov	AH, Video_TeleType

.loop:	
;	Bounds check
	cmp	SI, [argLen]
	je	.break

;	Output a character
	mov	BX, CX
	mov	AL, [BX + SI]
	xor	BH, BH			; Clear BH for correct active page
int	VideoService

	add	SI, 0x1
	jmp	.loop

.break:
	pop	SI
	pop	BP
%undef argLen
ret

error:
String_Out	ErrorMsg, [ErrorMsg_Len]
	hlt	; Halt


;=============================================================================================================
; Data
;=============================================================================================================
ErrorMsg     : db	'Failed - DiskService: ReadIntoMemory'
ErrorMsg_Len : dw	36

PostMsg     : db	'16bit.boot', char_LF, char_CR
PostMsg_len : dw	13

SendoffMsg     : db	'Sending over to 16bit.scratch...'
SendOffMsg_len : dw 32
;=============================================================================================================
; Wrap up
;=============================================================================================================
; Byte pad 512 bytes (zeroed)
times 	510-$+start 	db 0
; Master Boot Record signature
db 	0x55
db 	0xAA
