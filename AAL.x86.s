;=============================================================================================================
;=============================================================================================================
;=============================================================================================================
; AAL - Assembly Abstraction layer
; x86-64
;		Provides a suite of docs, functionatliy, macros, etc.
;
; Made while learning x86
; Edward R. Gonzalez	
;=============================================================================================================
;=============================================================================================================
;=============================================================================================================
;
; See 
; https://en.wikibooks.org/wiki/X86_Assembly/16,_32,_and_64_Bits
; https://wiki.osdev.org/X86-64
; http://www.ctyme.com/rbrown.htm
; https://github.com/Captainarash/The_Holy_Book_of_X86/blob/master/book_vol_1.txt


;=============================================================================================================
; Calling Convention
;=============================================================================================================
; Calling convention - Caller/Callee Saved Registers
;
; Caller rules: When calling a function the registers 
; RAX, RCX, RDX, R8, R9, R10, R11 are considered volatile and must be saved into the stack
; by the caller, if it relies on them 
; (unless otherwise safety-provable by analysis such as whole program optimization).
;	
; Callee rules:
; RBX, RBP, RDI, RSI, RSP, R12, R13, R14, and R15
; are considered nonvolatile and must be saved and restored from the stack by the callee if it modify them.
;=============================================================================================================
; END OF CALLING CONVENTION
;=============================================================================================================

;=============================================================================================================
; Register Documentation
;=============================================================================================================
; General Purpose
; 8	High	Low	16	32	64	Intended Purpose
; 	AH	AL	AX	EAX	RAX	Accumulator
; 	BH	BL	BX	EBX	RBX	Base
;	CH	CL	CX	ECX	RCX	Counter
;	DH	DL	DX	EDX	RDX	Data	(Used to extend the A register)
;		SIL	SI	ESI	RSI	Source index for strings ops
;		DIL	DI	EDI	RDI	Destination index for string operations
;		SPL	SPL	ESP	RSP	Stack pointer
;		BPL	BP	EBP	RBP	Base pointer (meant for stack frames)
;		R8B	R8W	R8D	R8	General Purpose (and below)
;		R9B	R9W	R9D	R9
;		R10B	R10W	R10D	R10
;		R11B	R11W	R11D	R11
;		R12B	R12W	R12D	R12
;		R13B	R13W	R13D	R13
;		R14B	R14W	R14D	R14
;		R15B	R15W	R15D	R15
; Instruction Pointer
; 		16	32	64
;		IP	EIP	RIP
; Segment 
;		16		
;		CS				Code Segment
;		DS				Data Segment
;		SS				Stack Segment
;		ES				Extra Segment
;		FS				General-purpose
;		GS				General-purpose
; RFLAGS
; 	Bit(s)	Label	Description
; 	0	CF	Carry Flag
;	1	1	Reserved
;	2	PF	Parity Flag
;	3	0	Reserved
;	4	AF	Auxiliary Carry Flag
;	5	0	Reserved
;	6	ZF	Zero Flag
;	7	SF	Sign Flag
;	8	TF	Trap Flag
;	9	IF	Interrupt Enable Flag
;	10	DF	Direction Flag
;	11	OF	Overflow Flag
;	12-13	IOPL	I/O Privilege Level
;	14	NT	Nested Task
;	15	0	Reserved
;	16	RF	Resume Flag
;	17	VM	Virtual-8086 Mode
;	18	AC	Alignment Check / Access Control
;	19	VIF	Virtual Interrupt Flag
;	20	VIP	Virtual Interrupt Pending
;	21	ID	ID Flag
;	22-63	0	Reserved

; Control
; CR0
;	Bit(s)	Label	Description
; 	0	PE	Protected Mode Enable
; 	1	MP	Monitor Co-Processor
; 	2	EM	Emulation
; 	3	TS	Task Switched
; 	4	ET	Extension Type
; 	5	NE	Numeric Error
; 	6-15	0	Reserved
; 	16	WP	Write Protect
; 	17	0	Reserved
; 	18	AM	Alignment Mask
; 	19-28	0	Reserved
; 	29	NW	Not-Write Through
; 	30	CD	Cache Disable
; 	31	PG	Paging
; 	32-63	0	Reserved
; CR2
; Contains the linear (virtual) address which triggered a page fault, available in the page fault's interrupt handler.
;
; CR3
;	Bit(s)	Label	Description	Condition
;	0-11	0-2	0	Reserved	CR4.PCIDE = 0
;	3	PWT	Page-Level Write Through
;	5	PCD	Page-Level Cache Disable
;	5-11	0	Reserved
;	0-11	PCID	CR4.PCIDE = 1
;	12-63	Physical Base Address of the PML4
;
;	Note that this must be page aligned
;
; CR4
; 	Bit(s)	Label	Description
; 	0	VME	Virtual-8086 Mode Extensions
; 	1	PVI	Protected Mode Virtual Interrupts
; 	2	TSD	Time Stamp enabled only in ring 0
; 	3	DE	Debugging Extensions
; 	4	PSE	Page Size Extension
; 	5	PAE	Physical Address Extension
; 	6	MCE	Machine Check Exception
; 	7	PGE	Page Global Enable
; 	8	PCE	Performance Monitoring Counter Enable
; 	9	OSFXSR	OS support for fxsave and fxrstor instructions
; 	10	OSXMMEXCPT	OS Support for unmasked simd floating point exceptions
; 	11	UMIP	User-Mode Instruction Prevention (SGDT, SIDT, SLDT, SMSW, and STR are disabled in user mode)
; 	12	0	Reserved
; 	13	VMXE	Virtual Machine Extensions Enable
; 	14	SMXE	Safer Mode Extensions Enable
; 	15	0	Reserved
; 	17	PCIDE	PCID Enable
; 	18	OSXSAVE	XSAVE And Processor Extended States Enable
; 	19	0	Reserved
; 	20	SMEP	Supervisor Mode Executions Protection Enable
; 	21	SMAP	Supervisor Mode Access Protection Enable
; 	22	PKE	Enable protection keys for user-mode pages
; 	23	CET	Enable Control-flow Enforcement Technology
; 	24	PKS	Enable protection keys for supervisor-mode pages
; 	25-63	0	Reserved
; CR8
;	CR8 is a new register accessible in 64-bit mode using the REX prefix. 
;	CR8 is used to prioritize external interrupts and is referred to as the task-priority register (TPR).
;	
;	The AMD64 architecture allows software to define up to 15 external interrupt-priority classes. 
;	Priority classes are numbered from 1 to 15, with priority-class 1 being the lowest and priority-class 15 the highest. 
;	CR8 uses the four low-order bits for specifying a task priority and the remaining 60 bits are reserved and must be written with zeros.
;	
;	System software can use the TPR register to temporarily block low-priority interrupts from interrupting a high-priority task. 
;	This is accomplished by loading TPR with a value corresponding to the highest-priority interrupt that is to be blocked. 
;	For example, loading TPR with a value of 9 (1001b) blocks all interrupts with a priority class of 9 or less, 
;	while allowing all interrupts with a priority class of 10 or more to be recognized. 
;	Loading TPR with 0 enables all external interrupts. Loading TPR with 15 (1111b) disables all external interrupts.
;	
;	The TPR is cleared to 0 on reset.
;	Bit	Purpose
;	0-3	Priority
;	4-63	Reserved
;	CR1, CR5-7, CR9-15
;	Reserved, the cpu will throw a #ud exeption when trying to access them.
;
; CR1, CR5-7, CR9-15
; Reserved, the cpu will throw a #ud exeption when trying to access them.
;
; MSRs
;
; IA32_EFER
;	Extended Feature Enable Register (EFER) is a model-specific register added in the AMD K6 processor, 
;	to allow enabling the SYSCALL/SYSRET instruction, and later for entering and exiting long mode. 
;	This register becomes architectural in AMD64 and has been adopted by Intel. Its MSR number is 0xC0000080.
;	
;	Bit(s)	Label	Description
;	0	SCE	System Call Extensions
;	1-7	0	Reserved
;	8	LME	Long Mode Enable
;	10	LMA	Long Mode Active
;	11	NXE	No-Execute Enable
;	12	SVME	Secure Virtual Machine Enable
;	13	LMSLE	Long Mode Segment Limit Enable
;	14	FFXSR	Fast FXSAVE/FXRSTOR
;	15	TCE	Translation Cache Extension
;	16-63	0	Reserved
;
; FS.base, GS.base
;
;	MSRs with the addresses 0xC0000100 (for FS) and 0xC0000101 (for GS) contain the base addresses of the FS and GS segment registers. 
;	These are commonly used for thread-pointers in user code and CPU-local pointers in kernel code. Safe to contain anything, 
;	since use of a segment does not confer additional privileges to user code.
;	
;	In newer CPUs, these can also be written with WRFSBASE and WRGSBASE instructions at any privilege level.
;	
; KernelGSBase
;	MSR with the address 0xC0000102. 
;	Is basically a buffer that gets exchanged with GS.base after a swapgs instruction. 
;	Usually used to seperate kernel and user use of the GS register.
;	
; Debug Registers
;
; DR0 - DR3
;	Contain linear addresses of up to 4 breakpoints. If paging is enabled, they are translated to physical addresses.
; DR6
;	It permits the debugger to determine which debug conditions have occured. 
;	When an enabled debug exception is enabled, low order bits 0-3 are set before entering debug exception handler.
; DR7
; 	Bit	Description
; 	0	Local DR0 Breakpoint
; 	1	Global DR0 Breakpoint
; 	2	Local DR1 Breakpoint
; 	3	Global DR1 Breakpoint
; 	4	Local DR2 Breakpoint
; 	5	Global DR2 Breakpoint
; 	6	Local DR3 Breakpoint
; 	7	Global DR3 Breakpoint
; 	16-17	Conditions for DR0
; 	18-19	Size of DR0 Breakpoint
; 	20-21	Conditions for DR1
; 	22-23	Size of DR1 Breakpoint
; 	24-25	Conditions for DR2
; 	26-27	Size of DR2 Breakpoint
; 	28-29	Conditions for DR3
; 	30-31	Size of DR3 Breakpoint
;
; 	A local breakpoint bit deactivates on hardware task switches, while a global does not.
; 	00b condition means execution break, 01b means a write watchpoint, and 11b means an R/W watchpoint. 
;	10b is reserved for I/O R/W (unsupported).
;
; Test Registers
; Name	Description
; TR3 - TR5	Undocumented
; TR6	Test 	Command Register
; TR7	Test 	Data Register
;
; Protected Mode Registers
; GDTR
;
; 	Operand	Size			Label	Description
;	64-bit		32-bit
; 	Bits 0-15	(Same)		Limit	Size of GDT
;	Bits 16-79	Bits 16-47	Base	Starting Address of GDT
;
; LDTR
;	Stores the segment selector of the LDT.
;
; TR
;	Stores the segment selector of the TSS.
;
; IDTR
;	Operand Size			Label	Description
;	64-bit		32-bit
;	Bits 0-15	(Same)		Limit	Size of IDT
;	Bits 16-79	Bits 16-47	Base	Starting Address of IDT
;=============================================================================================================
; END OF REGISTER DOCUMENTATION
;=============================================================================================================

%ifndef AAL_x86_Def
;=============================================================================================================
; Instructions Library
;=============================================================================================================
; NO-Operation : Exchanges value of rax with rax to achieve nothing.
%define nop	XCHG	rax, rax
;=============================================================================================================
; END - Instructions Library
;=============================================================================================================

;=============================================================================================================
; Interrupts
;=============================================================================================================
; BIOS

; CX, DX Interval in microseconds
; CX : High, DX : Low
; SystemService
%define BIOS_Wait	0x86

; Disk

; AL = Number of sectors to read (must be non-zero)
; CH = Track/Cylinder Number
; CL = Sector Number
; DH = Head Number
; DL = Drive Number
; ES:BX = Pointer to Buffer
%define Disk_ReadIntoMemory	0x02

; Disk Services (Storage)
%define DiskService	0x13

; Memory

; Real Mode - Conventional Lower Memory
%define Mem_RM_CLower_Start	0x0500
%define Mem_RM_CLower_End	0x7BFF
; 2 Byte Boundary Alignment
%define Mem_RM_CLower_2BB_End	0x7BE0

; Real Mode - Conventional Upper memory
%define Mem_RM_CUpper_Start	0x7E00
%define Mem_RM_CUpper_End	0x7FFF
; 2 Byte Boundary Alignment
%define Mem_RM_CUpper_2BB_End   0x7FE0

; Real Mode - OS Boot Sector
%define Mem_BootSector_Start	0x7C00
%define Mem_BootSector_512	0x7CFE
%define Mem_BootSector_End	0x7DFF

; Misc System Services
%define SystemService	0x15

; Video
%define VideoService	0x10

; Returns
; AH = Number of character columns
; AL = Display mode 
; BH = Active Page
%define Video_GetCurrentMode	0x0F

; Used to set the video mode.
%define Video_SetMode	0x00

; SetVideoMode - Modes
; cbOff : Color Burst Off
%define VideoMode_Text_40x25_cbOff	 	0x00
%define VideoMode_Text_40x25			0x01
%define VideoMode_Text_80x25_cbOff		0x02
%define VideoMode_Text_80x25			0x03
%define VideoMode_Graphics_320x200		0x04
%define VideoMode_Graphics_320x200_cboff	0x05
%define VideoMode_Graphics_640x200		0x06

; Output a character
%define Video_TeleType		0xE
; Where memory buffer for Video's Text mode starts
%define Video_Text_MemBuffer	0xB800
;=============================================================================================================
; END - Interrupts
;=============================================================================================================


%define char_CR	0xD	; Carriage Return
%define char_LF 0xA	; Line Feed


%define AAL_x86_Def
%endif


