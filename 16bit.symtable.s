; x86
; 16-bit - Real Mode, V86 Mode
; Symbol  Table


; 0x5E7AB1E { symbol; hash; symbol; hash; }
symtable:
	dd	0x5E7AB1E
	dw	0x0000
	db 	'{ listDir; #; createFile; #; }'

; Byte pad 512 bytes (zeroed)
times	512-$+symtable		db 0
