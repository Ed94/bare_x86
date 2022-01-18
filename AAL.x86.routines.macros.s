%ifndef AAL_macro_routines_Def
%include "AAL.x86.S"


;=============================================================================================================
; Interrupts
;=============================================================================================================

%macro	Video_SetTextMode_80x25 0
	mov	AH, Video_SetMode
	mov	AL, VideoMode_Text_80x25
int	VideoService
%endmacro

;=============================================================================================================
; Routines
;=============================================================================================================

%macro Hex16_ToString 2
	mov	DX, %1
	mov	CX, %2
	push	CX
call	h16_toString
	pop	CX
%endmacro

%macro Char_Out 1
	mov	AX, %1
	push	AX
call	out_char
	pop	AX
%endmacro

%macro String_Out 2
	mov	BX, %1
	mov	AX, %2
	push	AX
call	out_string
	pop	AX
%endmacro

%define AAL_macro_routines_Def
%endif
