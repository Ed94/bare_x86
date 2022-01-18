; Print HEx

; x86 
; 16-bit - Real Mode, V86 Mode

; https://codereview.stackexchange.com/questions/230755/display-hexadecimal-value-stored-at-a-register


%include "AAL.x86.S"
%include "AAL.x86.routines.macros.S"


; 16-Bit Mode
[BITS	16]
; The ORG directive specifies the starting address of a segment
[ORG	Mem_BootSector_Start]


;=============================================================================================================
; Boot Sector Code
;=============================================================================================================
start:
Video_SetTextMode_80x25

;	Exclusive-OR (xor'ing a value to itself zeros the value)
	xor 	AX, AX
;	Set Data Segment and Extra Segment to 0x0000
	mov	DS, AX
	mov	ES, AX
;	Set Stack Segment (SS) to to 0x0000
	mov 	SS, AX
;	Set Stack Pointer (SP) to the start of the boot sector.
	mov 	BX, Mem_BootSector_Start
	mov 	SP, BX

;	String testing
String_Out	TestStr, [TestStr_len]

	mov	AH, BIOS_Wait
	mov	CX, 0x02
int	SystemService

;	Hex Testing
String_Out	HexTest, [HexTest_len]
Hex16_ToString	[HexNum], HexString
Hex16_ToString	[HexNumT], HexStringT
String_Out	ResultStr, [ResultStr_len]
String_Out	HexString, 4
String_Out	HexStringT, 4

	mov	AH, BIOS_Wait
	mov	CX, 0x10
int	SystemService

Char_Out	char_LF
Char_Out	char_CR

	mov	BX, 0x7C00
	; sub	BX, 0x7DFF
	; mov	BX, 0x0000
	mov	DX, 512
call	dump_out

; Idle
hang :
jmp short hang


dump_out:
; Args:
; BX = StartLocation
; CX = ByteCount
%define StartLocation	BX
%define ByteCount	DX
	push 	BX
	push	SI
	; xor	BX, BX
	xor 	SI, SI

.loop:
	cmp	SI, ByteCount
	je	.break


	push BX
	push DX
	push SI
	mov	AX, StartLocation
	add	AX, SI

Hex16_ToString	AX, .HexStr
String_Out	.HexStr, 4

	pop	SI
	pop 	DX
	pop	BX

	mov	AH, [StartLocation + SI]
	add	SI, 1

	mov	AL, [StartLocation + SI]
	mov	[.HexNum], AX

	push BX
	push DX
	push SI
Char_Out	' '

Hex16_ToString	[.HexNum], .HexStr
String_Out	.HexStr, 4
	pop SI
	pop DX
	pop BX
	
Char_Out	' '

	mov	AH, BIOS_Wait
	mov	CX, 0x02
int	SystemService

	; add	SI, 4
	inc	SI
	jmp	.loop

.break:
	pop SI
	pop BX
ret

.HexNum : dw	0x0000
.HexStr	: dw	'    '
%undef StartLocation
%undef WordCount


%include "AAL.x86.routines.s"


;=============================================================================================================
; Data
;=============================================================================================================
TestStr     : db 	'String Test', char_LF, char_CR
TestStr_len : dw 	13

HexTest     : db 	'Hex Test', char_LF, char_CR
HexTest_len : dw 	10

HexNum     : dw 	0x1994
HexNumT     : dw 	0x2022
HexString  : db		'0000'
HexStringT  : db	'0000'

ResultStr     : db	'Result: '
ResultStr_len : db	8

;=============================================================================================================
; Wrap up
;=============================================================================================================
; Byte pad 512 bytes (zeroed)
times 	510-$+start 	db 0
; Master Boot Record signature
db 	0x55
db 	0xAA
