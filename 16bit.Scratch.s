; x86 
; 16-bit - Real Mode, V86 Mode

%include "AAL.x86.S"
%include "AAL.x86.routines.macros.S"


%macro DblNewLine_Out 0
	mov	AH, Video_TeleType
	mov	AL, char_LF
	int	VideoService
	mov	AL, char_CR
	int	VideoService
	mov	AL, char_LF
	int	VideoService
	mov	AL, char_CR
	int	VideoService
%endmacro 

; CmdStr Interface
; Inline
%macro CmdStr_Get 0
	mov	SI, CmdStr
%endmacro

; Inline
%macro CmdStr_Add 0
;	Put input char to CmdStr
	mov	[SI], AL
;	Increment DI, and increment cmdstr length.
	inc	SI
%endmacro


;=============================================================================================================
; Entrypoint
;=============================================================================================================
start:
	mov	AH, Video_SetMode
	mov	AL, VideoMode_Graphics_640_480_VGA
	int	VideoService

;	Give some times before starting
	mov	AH, BIOS_Wait
	mov	CX, 0x10
	int	SystemService

	String_Out	EntryMsg, [EntryMsg_len]
	DblNewLine_Out

;	Give some times before starting
	mov	AH, BIOS_Wait
	mov	CX, 0x01
	int 	SystemService

	String_Out	Input_F, [Input_F_len]

	push	SI
	; SI will be used as the char index in CmdStr


	CmdStr_Get
inputLoop:
;	Wait for input
	mov	AH, Keyboard_GetKeyStroke
	mov	AL, 0x00
	int	KeyboardService

	CmdStr_Add

;	Prep to outout character
	mov	AH, Video_TeleType
	mov	BH, 0x00

	cmp	AL, KeyL_Enter
		je	exe_Command

;	Output character if command not recognized
	int	VideoService

	NewLine_Out

	jmp short	inputLoop

exe_Command:
	; pop 	SI
	mov	AL, [CmdStr]


	cmp	AL, KeyL_N
		je	end_execution

	cmp	AL, KeyL_F
		jne	error_CmdNotFound
	String_Out	CmdFile, [CmdFile_len]

	CmdStr_Get
	jmp short	inputLoop

error_CmdNotFound:
	String_Out	CmdNotFnd, [CmdNotFnd_len]

	CmdStr_Get
	jmp short	inputLoop
;	End Program
	; cli
	; hlt

jmp short inputLoop


end_execution:
	String_Out	ExitMsg, [ExitMsg_len]

	cli
	hlt

hang:
jmp short hang


;=============================================================================================================
; Data
;=============================================================================================================
EntryMsg_len : dw 	29 
EntryMsg     : db 	'Bare x86  Mode: 16 bit (Real)', str_endl
; EntryMsg_len : equ $ - EntryMsg

ExitMsg_len : dw	12
ExitMsg     : db	'Exiting...', str_endl

Input_F_len : dw	36
Input_F     : db 	'F) File/Program Browser & Launcher', str_endl

CmdFile_len : dw	14
CmdFile	    : db	'Command File', str_endl

CmdNotFnd_len : dw	19
CmdNotFnd     : db	'Command not found', str_endl

CmdStr_len : dw		0
CmdStr     : db		''


%include "AAL.x86.routines.s"


;=============================================================================================================
; Wrap up
;=============================================================================================================
; Byte pad 512 bytes (zeroed)
times 	512-$+start	db 0
