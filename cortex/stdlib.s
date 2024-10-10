		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _bzero( void *s, int n )
; Parameters
;	s 		- pointer to the memory location to zero-initialize
;	n		- a number of bytes to zero-initialize
; Return value
;   none
		EXPORT	_bzero
_bzero
		STMFD	sp!, {r1-r12, lr}                ; save registers
		MOV		R3, R0                        ; store initial pointer
		MOV		R2, #0                        ; set zero value
zero_loop	SUBS	r1, r1, #1                    ; decrement counter
		BMI		end_func_bzero                ; if counter is negative, end
		STRB	R2, [R0], #1                   ; store zero and increment pointer
		B		zero_loop                     ; repeat until counter is zero
		
end_func_bzero
		MOV		R0, R3                         ; restore original pointer
		LDMFD	sp!, {r1-r12, lr}                ; restore registers
		MOV		pc, lr                         ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; char* _strncpy( char* dest, char* src, int size )
; Parameters
;   	dest 	- pointer to the buffer to copy to
;	src	- pointer to the zero-terminated string to copy from
;	size	- a total of n bytes
; Return value
;   dest
		EXPORT	_strncpy
_strncpy
		STMFD	sp!, {r1-r12, lr}                ; save registers
		MOV		R3, R0                        ; store initial destination pointer
		MOV		R5, R2                        ; store size
copy_loop	CMP		R5, #0                        ; compare size with zero
		BEQ		end_func_strncpy              ; if size is zero, end
		LDRB	R4, [R1], #1                   ; load byte from source and increment pointer
		SUB		R5, R5, #1                    ; decrement size
		STRB	R4, [R0], #1                   ; store byte to destination and increment pointer
		B		copy_loop                     ; repeat until size is zero
end_func_strncpy
		MOV		R0, R3                         ; restore original destination pointer
		LDMFD	sp!, {r1-r12, lr}                ; restore registers
		MOV		pc, lr                         ; return
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _malloc( int size )
; Parameters
;	size	- #bytes to allocate
; Return value
;   	void*	a pointer to the allocated space
		EXPORT	_malloc
_malloc
		STMFD	sp!, {r1-r12, lr}                ; save registers
		MOV		R7, #0x04                     ; system call number for malloc
	    SVC     #0x0                        ; supervisor call
		LDMFD	sp!, {r1-r12, lr}                ; restore registers
		MOV		pc, lr                         ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _free( void* addr )
; Parameters
;	size	- the address of a space to deallocate
; Return value
;   	none
		EXPORT	_free
_free
		STMFD	sp!, {r1-r12, lr}                ; save registers
		MOV		R7, #0x05                     ; system call number for free
        SVC     #0x0                        ; supervisor call
		LDMFD	sp!, {r1-r12, lr}                ; restore registers
		MOV		pc, lr                         ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; unsigned int _alarm( unsigned int seconds )
; Parameters
;   seconds - seconds when a SIGALRM signal should be delivered to the calling program	
; Return value
;   unsigned int - the number of seconds remaining until any previously scheduled alarm
;                  was due to be delivered, or zero if there was no previously schedul-
;                  ed alarm. 
		EXPORT	_alarm
_alarm
		STMFD	sp!, {r1-r12, lr}                ; save registers
		MOV		R7, #0x01                     ; system call number for alarm
        SVC     #0x0                        ; supervisor call
		LDMFD	sp!, {r1-r12, lr}                ; restore registers
		MOV		pc, lr                         ; return		
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _signal( int signum, void *handler )
; Parameters
;   signum - a signal number (assumed to be 14 = SIGALRM)
;   handler - a pointer to a user-level signal handling function
; Return value
;   void*   - a pointer to the user-level signal handling function previously handled
;             (the same as the 2nd parameter in this project)
		EXPORT	_signal
_signal
		STMFD	sp!, {r1-r12, lr}                ; save registers
		MOV		R7, #0x02                     ; system call number for signal
        SVC     #0x0                        ; supervisor call
		LDMFD	sp!, {r1-r12, lr}                ; restore registers
		MOV		pc, lr                         ; return	




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;EXTRA CREDIT FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _memset(void *s, int c, int n)
; Parameters
;   s   - pointer to the memory location to initialize
;   c   - the byte value to set
;   n   - number of bytes to set
; Return value
;   none
        EXPORT  _memset
_memset
        STMFD   sp!, {r4, lr}                ; save registers
        MOV     R3, R0                      ; store initial pointer in R3
        MOV     R4, R1                      ; store byte value to set in R4
        MOV     R5, R2                      ; store size in R5
memset_loop
        CMP     R5, #0                      ; compare size with zero
        BEQ     end_memset                  ; if size is zero, end
        STRB    R4, [R3], #1                ; store byte and increment pointer
        SUBS    R5, R5, #1                  ; decrement size
        B       memset_loop                 ; repeat until size is zero
end_memset
        MOV     R0, R3                      ; restore original pointer
        LDMFD   sp!, {r4, lr}                ; restore registers
        MOV     pc, lr                      ; return



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; int _strlen(const char* str)
; Parameters
;   str - pointer to the zero-terminated string
; Return value
;   length of the string (excluding the null terminator)
        EXPORT  _strlen
_strlen
        STMFD   sp!, {r1-r12, lr}            ; save registers
        MOV     R1, R0                      ; store initial pointer
        MOV     R2, #0                      ; initialize length counter
strlen_loop
        LDRB    R3, [R1], #1                ; load byte from string and increment pointer
        CMP     R3, #0                      ; compare byte with null terminator
        BEQ     end_strlen                  ; if byte is null terminator, end
        ADD     R2, R2, #1                  ; increment length counter
        B       strlen_loop                 ; repeat until null terminator is found
end_strlen
        MOV     R0, R2                      ; move length counter to R0
        LDMFD   sp!, {r1-r12, lr}            ; restore registers
        MOV     pc, lr                      ; return
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _memmove(void* dest, const void* src, int n)
; Parameters
;   dest - pointer to the buffer to copy to
;   src  - pointer to the buffer to copy from
;   n    - number of bytes to copy
; Return value
;   dest
        EXPORT  _memmove
_memmove
        STMFD   sp!, {r4, r5, r6, lr}        ; save registers
        MOV     R3, R0                      ; store initial destination pointer
        CMP     R0, R1                      ; compare dest and src
        BHI     move_backward               ; if dest > src, move backward

; Move forward
move_forward
        MOV     R4, R2                      ; load length
        CMP     R4, #0                      ; check if length is zero
        BEQ     end_memmove                 ; if zero, end
forward_loop
        LDRB    R5, [R1], #1                ; load byte from source
        STRB    R5, [R0], #1                ; store byte to destination
        SUBS    R4, R4, #1                  ; decrement length
        BNE     forward_loop                ; repeat until length is zero
        B       end_memmove

; Move backward
move_backward
        ADD     R0, R0, R2                  ; point to end of dest
        ADD     R1, R1, R2                  ; point to end of src
        MOV     R4, R2                      ; load length
backward_loop
        LDRB    R5, [R1, #-1]!              ; load byte from source backward
        STRB    R5, [R0, #-1]!              ; store byte to destination backward
        SUBS    R4, R4, #1                  ; decrement length
        BNE     backward_loop               ; repeat until length is zero

end_memmove
        MOV     R0, R3                      ; restore original destination pointer
        LDMFD   sp!, {r4, r5, r6, lr}       ; restore registers
        MOV     pc, lr                      ; return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		END
