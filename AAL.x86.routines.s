%ifndef AAL_routines_Def

%include "AAL.x86.S"


;=============================================================================================================
; Routines
;=============================================================================================================

; Prints out a 16-bit hex value.
h16_toString:
; Arg - DX : Hex Num
; ArgStr: String
%define argStr	BP + 6
	push	BX
	push	BP
	mov	BP, SP

;	Half-Byte index
	push	SI
	xor	SI, SI

.loop:
;	If all 4-bit slots translate, break
	cmp	SI, 4
	je	.break
	
;	Get latest half-byte from DX
	mov	AX, DX
;	Doing only the first right-most digit
	and	AX, 0x000F
;	Get ASCII numeral or alpha character
	add	AL, 0x30
;	0->9 (<= 0x39), A->F (>= 0x39)
	cmp	AL, 0x39	; Numeral offset
	jle	.SetCharVal
	add	AL, 0x7		; A-F offset

.SetCharVal:
;	Add the char value to the string
	mov	BX, [argStr]
;	Move to last half-byte
	add	BX, 3
;	Go to the current half-byte via index offset
	sub	BX, SI
;	Write ascii hex value to half-byte in ArgStr
	mov	[BX], AL
;	Rotate the next half-byte over
	ror	DX, 4

	inc	SI
	jmp	.loop

.break:
	pop	SI
	pop 	BP
	pop 	BX
%undef argStr
ret


; Print out an ASCII character.
out_char:
%define arg1	BP + 6
	push	BX
	push 	BP
	mov	BP, SP

	mov	AH, Video_TeleType
	mov	AL, [arg1]
int VideoService

	pop	BP
	pop	BX
%undef arg1
ret


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


%define AAL_routines_Def
%endif
