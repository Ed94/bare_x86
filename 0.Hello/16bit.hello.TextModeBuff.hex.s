; Print HEx

; x86 
; 16-bit - Real Mode, V86 Mode

; https://codereview.stackexchange.com/questions/230755/display-hexadecimal-value-stored-at-a-register


%include "AAL.x86.S"


; 16-Bit Mode
[BITS	16]
; The ORG directive specifies the starting address of a segment
[ORG	Mem_BootSector_Start]


start:
	mov 	BX, Mem_BootSector_Start

;	textmode_ClearScreen
; 		Params
	mov 	AH, Video_SetMode
	mov 	AL, VideoMode_Text_80x25
; 		Call Interrupt
int	VideoService			

;	Exclusive-OR (xor'ing a value to itself zeros the value)
	xor 	AX, AX
;	Set Data Segment and Extra Segment to 0x0000
	mov	DS, AX
	mov	ES, AX
;	Set Stack Segment (SS) to to 0x0000
	mov 	SS, AX
;	Set Stack Pointer (SP) to the start of the boot sector.
	mov 	SP, BX

	mov BX, 0x2022
call 	output_Hex

; Idle
hang :
jmp short hang


;=============================================================================================================
; Output Hex to TextMode via Teletype
;=============================================================================================================
%define hex	BX
%define backup	CX

output_Hex:
;	Clear Interrupt Flag : Prevents interrupts form occuring
	cli
;	Push all registers values onto the stack
	pusha

;	Store original value in backup
	mov	backup, hex
;	Setup referfence to hex chars  memory
	mov	SI, .CharHex

;	Shift Logical Right : SHR performs an unsigned divide
;	The high-order bit is set to 0.
;	0b1000 -> 0b0100, 0b0001 -> 0b0000
	shr	hex, 12 		; First four : 0x[#]### -> 0x000#
	and	hex, 0x0F		; Mask out any garbage
	mov	AL, [hex + SI]		; AL = hex + SI
	mov	[.Result + 2], AL	; result[2] = AL

	mov 	hex, backup		; Next four
	shr	hex, 8
	and	hex, 0x0F
	mov	AL, [hex + SI]
	mov	[.Result + 3], AL

	mov 	hex, backup		; ...
	shr	hex, 4
	and	hex, 0x0F
	mov	AL, [hex + SI]
	mov	[.Result + 4], AL

	mov 	hex, backup
	shr	hex, 0
	and	hex, 0x0F
	mov	AL, [hex + SI]
	mov	[.Result + 5], AL

;	BX : String arg
	mov CX, .Result
call	output_String

;	Pop all register values that were saved on the current stack
	popa
;	Set Interrupt Flag : Restore interrupts
	ret

; Proc Data
.CharHex:
db '0123456789ABCDEF', 0x0

.Result:
db '0x0000', 0x0

%undef   hex
%undef 	 backup
%unmacro index 1


;=============================================================================================================
; Output String to TextMode via Teletype
;=============================================================================================================
%define string		CX
%define CharHex_Length	6
%macro	TextMode_SetChar 2
	mov 	word [%1 * 2    ], %2
	mov 	word [%1 * 2 + 1], 0x0F
%endmacro
output_String:
	pusha 
;	Will track string index
	mov	SI, 0x0
	
;	Prep BH and AH with Teletype video service option
	mov	BH, 0x0
	mov	AH, Video_TeleType

;	Reg CX cannot be used as an index speciifer. [BX] is
;	SI can be used as an offset inside [BX + offset]
	mov BX, CX

.loop:
;	Compare
	cmp	SI, CharHex_Length
	je	.break
;	Jump

;	Print via teletype
	mov AL, [BX + SI];
int	VideoService

;	Increment index
	inc	SI
	jmp 	short .loop

.break:
	popa
	ret

%undef	 string
%undef	 index
%undef	 CharHex_Length
%unmacro TextMode_SetChar 2



;=============================================================================================================
; Wrap up
;=============================================================================================================
; Byte pad 512 bytes (zeroed)
times 	510-$+start 	db 0
; Master Boot Record signature
db 	0x55
db 	0xAA
