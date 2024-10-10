		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table
SYSTEMCALLTBL	EQU		0x20007B00 ; originally 0x20007500
SYS_EXIT		EQU		0x0		; address 20007B00
SYS_ALARM		EQU		0x1		; address 20007B04
SYS_SIGNAL		EQU		0x2		; address 20007B08
SYS_MEMCPY		EQU		0x3		; address 20007B0C
SYS_MALLOC		EQU		0x4		; address 20007B10
SYS_FREE		EQU		0x5		; address 20007B14


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table Initialization
		EXPORT	_syscall_table_init
		
_syscall_table_init
		STMFD	sp!, {r1-r12, lr}			; save registers
	
		LDR		R1, =SYSTEMCALLTBL			; load system call table base address
		ADD		R1, R1, #4					; move to the next entry
	
		IMPORT _timer_start
		LDR		R2, =_timer_start			; load address of timer_start
		STR		R2, [R1]					; store in system call table
	
		IMPORT _signal_handler
		ADD		R1, R1, #4					; move to the next entry	
		LDR		R2, =_signal_handler		; load address of signal_handler
		STR		R2, [R1]					; store in system call table
	
		IMPORT _kalloc
		ADD		R1, R1, #4					; move to the next entry
		LDR		R2, =_kalloc				; load address of kalloc
		STR		R2, [R1]					; store in system call table
		
		IMPORT _kfree
		ADD		R1, R1, #4					; move to the next entry
		LDR		R2, =_kfree					; load address of kfree
		STR		R2, [R1]					; store in system call table	
		
		LDMFD	sp!, {r1-r12, lr}			; restore registers
		MOV		pc, lr						; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table Jump Routine
        EXPORT	_syscall_table_jump
_syscall_table_jump
		STMFD	sp!, {r1-r12, lr}			; save registers

		CMP		R7, #0x1					; compare syscall number with 1
		BNE		sig							; branch if not equal
		LDR		R11, =SYSTEMCALLTBL			; load system call table base address
		ADD		R11, R11, #4				; move to timer_start entry
		LDR		R11, =_timer_start			; load address of timer_start
		BLX		R11							; branch to timer_start
sig		CMP		R7, #0x2					; compare syscall number with 2
		BNE		malloc						; branch if not equal
		ADD		R11, R11, #8				; move to signal_handler entry
		LDR		R11, =_signal_handler		; load address of signal_handler
		BLX		R11							; branch to signal_handler
		
malloc	CMP		R7, #0x4					; compare syscall number with 4
		BNE		free						; branch if not equal
		ADD		R11, R11, #12				; move to kalloc entry
		LDR		R11, =_kalloc				; load address of kalloc
		BLX		R11							; branch to kalloc
		
free	CMP		R7, #0x5					; compare syscall number with 5
		BNE		end_						; branch if not equal
		ADD		R11, R11, #16				; move to kfree entry		
		LDR		R11, =_kfree				; load address of kfree
		BLX		R11							; branch to kfree
		
end_	LDMFD	sp!, {r1-r12, lr}			; restore registers
		MOV		pc, lr						; return

		END	