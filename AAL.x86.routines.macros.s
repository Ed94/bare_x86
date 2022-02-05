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

%macro	Video_SetGraphicsMode_320x200 0
	mov	AH, Video_SetMode
	mov	AL, VideoMode_Graphics_320x200
	int	VideoService
%endmacro

%macro	Video_SetGraphicsMode_640x200 0
	mov	AH, Video_SetMode
	mov	AL, VideoMode_Graphics_640x200
	int	VideoService
%endmacro

;=============================================================================================================
; Routines
;=============================================================================================================

%macro Char_Out 1
	mov	AH, Video_TeleType
	mov	AL, %1
	int	VideoService
%endmacro

%macro DumpOut 2
	mov	BX, %1
	mov	DX, %2
	call	out_Dump
%endmacro

%macro Hex16_ToString 2
	mov	DX, %1
	mov	CX, %2
	push	CX
	call	h16_toString
	pop	CX
%endmacro

%macro NewLine_Out 0
	mov	AH, Video_TeleType
	mov	AL, char_LF
	int	VideoService
	mov	AL, char_CR
	int	VideoService
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
