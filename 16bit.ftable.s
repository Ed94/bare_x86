; x86
; 16-bit - Real Mode, V86 Mode
; File Table


; 0xF91E7AB1E { filename; sector#; filename; sector#; }
filetable:
	dd	0xEF7AB1E
	dw	0x0000
	db 	'{ testfile; 04; testProg; 06; }'

; Byte pad 512 bytes (zeroed)
times	512-$+filetable		db 0
