		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Timer Definition
STCTRL		EQU		0xE000E010		; SysTick Control and Status Register
STRELOAD	EQU		0xE000E014		; SysTick Reload Value Register
STCURRENT	EQU		0xE000E018		; SysTick Current Value Register
	
STCTRL_STOP	EQU		0x00000004		; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 0, Bit 0 (ENABLE) = 0
STCTRL_GO	EQU		0x00000007		; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 1, Bit 0 (ENABLE) = 1
STRELOAD_MX	EQU		0x00FFFFFF		; MAX Value = 1/16MHz * 16M = 1 second
STCURR_CLR	EQU		0x00000000		; Clear STCURRENT and STCTRL.COUNT	
SIGALRM		EQU		14			; sig alarm

; System Variables
SECOND_LEFT	EQU		0x20007B80		; Secounds left for alarm( )
USR_HANDLER     EQU		0x20007B84		; Address of a user-given signal handler function	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Timer initialization
; void timer_init( )
        EXPORT  _timer_init
_timer_init
        PUSH    {R0-R12, LR}                 ; save registers

        LDR     R0, =STCTRL                  ; disable SysTick
        LDR     R1, =STCTRL_STOP
        STR     R1, [R0]

        LDR     R0, =STRELOAD                ; set reload register to max value
        LDR     R1, =STRELOAD_MX
        STR     R1, [R0]

        POP     {R0-R12, LR}                 ; restore registers
        MOV     PC, LR                       ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer start
; int timer_start( int seconds )
        EXPORT  _timer_start
_timer_start
        PUSH    {R1-R12, LR}                 ; save registers

        LDR     R1, =SECOND_LEFT             ; load previous seconds
        LDR     R2, [R1]
        STR     R0, [R1]                     ; update with new seconds
        MOV     R2, R0

        LDR     R1, =STCTRL                  ; enable SysTick
        LDR     R2, =STCTRL_GO
        STR     R2, [R1]

        LDR     R1, =STCURR_CLR              ; clear current value register
        LDR     R2, =STCURRENT
        STR     R2, [R1]

        POP     {R1-R12, LR}                 ; restore registers
        MOV     PC, LR                       ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update
; void timer_update( )
        EXPORT  _timer_update
_timer_update
        PUSH    {R0-R12, LR}                 ; save registers

        LDR     R0, =SECOND_LEFT             ; load seconds left
        LDR     R1, [R0]
        SUBS    R1, R1, #1                   ; decrement seconds
        STR     R1, [R0]
        BNE     timer_update_done

        LDR     R2, =STCTRL_STOP             ; disable SysTick if zero
        LDR     R3, =STCTRL
        STR     R2, [R3]

        LDR     R4, =USR_HANDLER             ; call user handler
        LDR     R5, [R4]
        BLX     R5

timer_update_done
        POP     {R0-R12, LR}                 ; restore registers
        MOV     PC, LR                       ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update
; void* signal_handler( int signum, void* handler )
        EXPORT  _signal_handler
_signal_handler
        PUSH    {R1-R12, LR}                 ; save registers

        LDR     R2, =SIGALRM                 ; load SIGALRM value
        CMP     R0, R2                       ; compare signum
        BNE     sig_return      			; if not SIGALRM, skip

        LDR     R3, =USR_HANDLER             ; store handler address
        LDR     R4, [R3]
        STR     R1, [R3]

sig_return
        MOV     R0, R4                       ; return previous handler
        POP     {R1-R12, LR}                 ; restore registers
        MOV     PC, LR                       ; return

        END
