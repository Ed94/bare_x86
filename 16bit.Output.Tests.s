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
; Video_SetGraphicsMode_320x200
; Video_SetGraphicsMode_640x200

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
Hex16_ToString	[HexNumA], HexStringA
Hex16_ToString	[HexNumB], HexStringB
String_Out	ResultStr, [ResultStr_len]
String_Out	HexStringA, 4
String_Out	HexStringB, 4

	mov	AH, BIOS_Wait
	mov	CX, 0x10
int	SystemService

Char_Out	char_LF
Char_Out	char_CR

DumpOut		0x7C00, 512

; Idle
hang :
jmp short hang


%include "AAL.x86.routines.s"


;=============================================================================================================
; Data
;=============================================================================================================
TestStr     : db 	'String Test', char_LF, char_CR
TestStr_len : dw 	13

HexTest     : db 	'Hex Test', char_LF, char_CR
HexTest_len : dw 	10

HexNumA     : dw 	0x1994
HexNumB     : dw 	0x2022
HexStringA  : db	'0000'
HexStringB  : db	'0000'

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
