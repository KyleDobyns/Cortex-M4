		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table
HEAP_TOP	EQU		0x20001000
HEAP_BOT	EQU		0x20004FE0
MAX_SIZE	EQU		0x00004000		; 16KB = 2^14
MIN_SIZE	EQU		0x00000020		; 32B  = 2^5
	
MCB_TOP		EQU		0x20006800      	; 2^10B = 1K Space
MCB_BOT		EQU		0x20006BFE
MCB_ENT_SZ	EQU		0x00000002		; 2B per entry
MCB_TOTAL	EQU		512			; 2^9 = 512 entries
	
INVALID		EQU		-1			; an invalid id
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Control Block Initialization
		EXPORT	_heap_init
_heap_init
		STMFD	sp!, {r1-r12, lr}                ; save registers
		LDR		R1, =MAX_SIZE                  ; load max size
        LDR		R2, =MCB_TOP                   ; load mcb top address
        MOV		R4, #0x0                       ; initialize R4 to 0
        STR		R1, [R2], #4                   ; store max size in mcb top
        LDR		R3, =0x20006C00                ; load limit address
init_loop	CMP		R2, R3                       ; compare current address with limit
		BGT		init_end                     ; if current address > limit, end
        STR		R4, [R2]                      ; store 0 in current address
        STR		R4, [R2, #1]                  ; store 0 in the next byte
        ADD		R2, R2, #2                    ; move to the next entry
        B		init_loop                    ; repeat until limit
init_end	LDMFD	sp!, {r1-r12, lr}             ; restore registers
		MOV		pc, lr                        ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory Allocation
; void* _k_alloc( int size )
		EXPORT	_kalloc
_kalloc
		STMFD	sp!, {r1-r12, lr}                ; save registers
		MOV		R3, R0                        ; move size to R3
        LDR		R1, =MCB_TOP                   ; load mcb top address
        LDR		R2, =MCB_BOT                   ; load mcb bottom address
        LDR		R11, =_ralloc                  ; load ralloc address
        BLX		R11                            ; branch to ralloc
        LDMFD	sp!, {r1-r12, lr}               ; restore registers
        MOV		pc, lr                        ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_ralloc
		STMFD	sp!, {r1-r12, lr}                ; save registers
		LDR		R10, =MCB_ENT_SZ              ; load mcb entry size

		SUB		R11, R2, R1                    ; calculate entire size
        ADD		R4, R11, R10                   ; add entry size to entire size

        ASR		R5, R4, #1                     ; calculate half size
        ADD		R6, R1, R5                     ; calculate midpoint
        MOV		R7, #0x0                       ; initialize heap address
        LSL		R9, R5, #4                     ; calculate actual half size
        LSL		R8, R4, #4                     ; calculate actual entire size

        CMP		R3, R9                         ; compare size with half size
        BGT		alloc_larger                   ; if size > half size, branch

        SUB		R2, R6, R10                    ; adjust right boundary
        BL		_ralloc                        ; recursive call to ralloc
        MOV		R7, R0                         ; update heap address
        CMP		R7, #0                         ; check if allocation succeeded
        BNE		alloc_success                  ; if successful, branch

        SUB		R12, R4, R10                   ; adjust entire size
        ADD		R12, R12, R1                   ; adjust left boundary
        MOV		R2, R12                        ; update right boundary
        MOV		R1, R6                         ; update midpoint

        BL		_ralloc                        ; recursive call to ralloc
        MOV		R7, R0                         ; update heap address
        B		alloc_end                      ; branch to end
alloc_success
        LDR		R12, [R6]                      ; load mcb entry
        AND		R12, R12, #0x01                ; check if entry is allocated

        CMP		R12, #0                        ; compare with zero
        BNE		alloc_check                    ; if not zero, branch
        STR		R9, [R6]                      ; store actual half size

alloc_check
        MOV		R7, R0                         ; update heap address
        B		alloc_end                      ; branch to end

alloc_larger
        LDR		R12, [R1]                      ; load mcb entry
        AND		R12, R12, #1                   ; check if entry is allocated
        CMP		R12, #0                        ; compare with zero
        BEQ		alloc_available                ; if zero, branch

        MOV		R7, #0                        ; set heap address to zero
        B		alloc_end                      ; branch to end
alloc_available
        LDR		R12, [R1]                      ; load mcb entry
        CMP		R12, R8                        ; compare with actual entire size
        BGE		alloc_match                    ; if >=, branch

        MOV		R7, #0                        ; set heap address to zero
        B		alloc_end                      ; branch to end
alloc_match
        LDR		R12, [R1]                      ; load mcb entry
        MOV		R11, R8                        ; set actual size
        ORR		R11, R11, #0x1                 ; mark as allocated
        STR		R11, [R1]                      ; store updated entry
        LDR		R11, =MCB_TOP                  ; load mcb top address
        SUB		R12, R1, R11                   ; calculate offset
        LSL		R12, R12, #4                   ; adjust offset
        LDR		R11, =HEAP_TOP                 ; load heap top address
        ADD		R7, R12, R11                   ; calculate heap address

alloc_end
        MOV		R0, R7                         ; move heap address to R0
        LDMFD	sp!, {r1-r12, lr}               ; restore registers
        MOV		pc, lr                        ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Kernel Memory De-allocation
; void free( void *ptr )
		EXPORT	_kfree
_kfree
		STMFD	sp!, {r1-r12, lr}                ; save registers
		LDR		R2, =HEAP_TOP                  ; load heap top address
        SUB		R1, R0, R2                    ; calculate offset
        ASR		R1, R1, #4                     ; adjust offset
        LDR		R3, =MCB_TOP                   ; load mcb top address
        MOV		R5, R0                        ; save original pointer
        ADD		R0, R3, R1                    ; calculate mcb entry address
        LDR		R11, =_rfree                   ; load rfree address
        BLX		R11                            ; branch to rfree
        LDMFD	sp!, {r1-r12, lr}               ; restore registers
        MOV		pc, lr                        ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_rfree
		STMFD	sp!, {r1-r12, lr}                ; save registers

		LDR		R1, [R0]                      ; load mcb entry
        LDR		R5, =MCB_TOP                   ; load mcb top address
        SUB		R2, R0, R5                    ; calculate offset
        ASR		R1, R1, #4                     ; adjust size
        MOV		R3, R1                        ; save size
        LSL		R1, R1, #4                    ; calculate actual size
        MOV		R4, R1                        ; save actual size
        STR		R1, [R0]                      ; store size

        SDIV	R6, R2, R3                    ; calculate division
        MOV		R8, #2                        ; set divisor
        SDIV	R11, R6, R8                   ; calculate division
        MLS		R7, R8, R11, R6               ; calculate modulo
        CMP		R7, #0                        ; compare with zero
        BNE		free_next                     ; if not zero, branch
        ADD		R6, R0, R3                    ; calculate buddy address
        LDR		R7, =MCB_BOT                  ; load mcb bottom address
        CMP		R6, R7                       ; compare with bottom address
        BLT		free_merge                    ; if less, branch

        MOV		R9, #0                        ; set return value to zero
        B		free_end                      ; branch to end

free_merge
        LDR		R10, [R6]                     ; load buddy entry
        AND		R12, R10, #0x0001             ; check if buddy is allocated
        CMP		R12, #0                       ; compare with zero
        BNE		free_return                   ; if not zero, branch
        ASR		R10, R10, #5                  ; adjust buddy size
        LSL		R10, R10, #5                  ; adjust buddy size
        CMP		R10, R4                       ; compare with actual size
        BNE		free_return                   ; if not equal, branch
        MOV		R11, #0                      ; clear buddy entry
        STR		R11, [R6]                    ; store cleared entry
        LSL		R4, R4, #1                   ; double the size
        STR		R4, [R0]                     ; store new size
        BL		_rfree                        ; recursive call to rfree
        MOV		R9, R0                        ; update return value
        B		free_end                      ; branch to end

free_next
        SUB		R6, R0, R3                    ; calculate buddy address
        LDR		R7, =MCB_TOP                  ; load mcb top address
        CMP		R6, R7                       ; compare with top address
        BGE		free_merge_next               ; if greater or equal, branch

        MOV		R9, #0                        ; set return value to zero
        B		free_end                      ; branch to end

free_merge_next
        LDR		R10, [R6]                     ; load buddy entry
        AND		R12, R10, #0x0001             ; check if buddy is allocated
        CMP		R12, #0                       ; compare with zero
        BNE		free_return                   ; if not zero, branch
        ASR		R10, R10, #5                  ; adjust buddy size
        LSL		R10, R10, #5                  ; adjust buddy size
        CMP		R10, R4                       ; compare with actual size
        BNE		free_return                   ; if not equal, branch
        MOV		R11, #0                      ; clear buddy entry
        STR		R11, [R0]                    ; store cleared entry
        LSL		R4, R4, #1                   ; double the size
        STR		R4, [R6]                     ; store new size
        MOV		R0, R6                       ; update pointer
        BL		_rfree                        ; recursive call to rfree
        MOV		R9, R0                        ; update return value
        B		free_end                      ; branch to end

free_return
        MOV		R9, R0                        ; update return value

free_end
        MOV		R0, R9                        ; move return value to R0
        LDMFD	sp!, {r1-r12, lr}               ; restore registers
        MOV		pc, lr                        ; return
