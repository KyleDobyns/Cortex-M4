# Cortex-M4
**Introduction**
This project involved implementing several standard library functions and system-level handlers 
in ARM/THUMB-2 assembly for a TM4C129 microcontroller. The primary objective was to 
deepen my understanding of low-level programming, memory management, and interrupt 
handling, using the Keil µVision IDE. Through this project I was able to gain practical 
experience in writing and debugging assembly code that performs fundamental tasks such as 
memory allocation, string manipulation, and signal handling.

**Implemented Functions**
_bzero: I implemented the _bzero function to initialize a specified memory area to zero. This 
function is used to properly clear memory before use. The function takes two parameters: a 
pointer to the memory location and the number of bytes to initialize. The implementation 
involves saving the current registers, using a loop to set each byte to zero, and then restoring the 
registers before returning. This method confirms that memory is correctly zeroed out without 
affecting other parts of the program.

_strncpy: The _strncpy function copies a specified number of characters from the source string 
to the destination buffer. This function is important for safely copying strings, especially when 
dealing with fixed-size buffers. It takes three parameters: the destination pointer, source pointer, 
and the number of characters to copy. The implementation involves saving the current registers, 
looping to copy each character, and then restoring the registers before returning. This ensures 
that the string copy operation is completed properly.

_malloc: The _malloc function allocates a specified number of bytes and returns a pointer to the 
allocated memory. This function is a fundamental part of dynamic memory management in C 
programs. I used a supervisor call (SVC) to handle the system call for memory allocation. The 
implementation involves saving the current registers, setting up the SVC call, and restoring the 
registers before returning. 

_free: The _free function deallocates memory previously allocated by _malloc. Proper memory 
deallocation is needed to prevent memory leaks and ensure efficient use of memory resources. I 
used an SVC call to handle the system call for freeing memory. The implementation involves 
saving the current registers, setting up the SVC call, and restoring the registers before returning,
which ensures that memory is correctly released back to the system for future use.

_alarm: The _alarm function sets a timer to deliver a SIGALRM signal after a specified number 
of seconds. This function is used to implement timed events in programs. I used an SVC call to 
handle the system call for setting the alarm. The implementation involves saving the current 
registers, setting up the SVC call, and restoring the registers before returning. This allows the 
program to schedule future actions based on passing time increments.

_signal: The _signal function defines a handler for a signal, specifically SIGALRM. Signal 
handling is a feature used for managing asynchronous events in a program. I used an SVC call to 
handle the system call for setting the signal handler. The implementation involves saving the 
current registers, setting up the SVC call, and restoring the registers before returning. This allows 
the program to specify custom behavior when signals are received.

_memset: The _memset function sets a block of memory with a specified value. This function is 
useful for initializing memory regions to a specific value, such as setting all bytes to zero or a 
particular character. The implementation involves looping through the memory block and setting 
each byte to the given value.

_strlen: The _strlen function calculates the length of a string, excluding the null terminator. It 
counts the number of characters in a string until it reaches the null terminator. This function is 
used for string manipulation and validation. 

_memmove: The _memmove function copies a block of memory from one location to another, 
handling overlapping regions correctly. This function is needed when the source and destination 
memory areas overlap, as it ensures that data is not corrupted during the copy operation. The 
implementation involves conditional copying either forwards or backwards to handle overlaps. 
This ensures that the data is copied correctly regardless of the source and destination addresses.
System-Level Implementations

Reset_Handler: The Reset_Handler function initializes system settings, memory, and starts the 
main program. It configures the stack pointers, initializes the system call table, heap space, and 
the SysTick timer. This function ensures the system is ready for application execution by setting 
up the necessary environment and resources.

SVC_Handler: The SVC_Handler function handles system calls by jumping to appropriate 
system call handlers based on the system call number. It manages the transition between userlevel and 
kernel-level code, which allows for secure and controlled execution of system-level functions. This 
handler is needed for implementing system services that applications can request.
SysTick_Handler: The SysTick_Handler function updates the timer and calls user-defined 
signal handlers when the SysTick timer expires. This function is used for implementing periodic 
tasks and handling time-based interrupts in the system. It ensures that time-sensitive operations 
are performed at the correct intervals.

**Challenges and Improvements**
One of the main challenges I faced was integrating SVC instructions with assembly routines. 
This integration is needed for handling system-level functions like memory allocation and signal 
management, but it was complex due to the low-level nature of these operations and my lack of 
experience with them.

Another significant challenge was implementing correct memory allocation and deallocation 
using the buddy system. The buddy system is designed to manage memory efficiently by 
splitting blocks into halves to minimize fragmentation. However, this required meticulous 
handling of memory control blocks and ensuring that adjacent free blocks are merged correctly. 
Most of my time was spent implementing this in C for the Midpoint Report, and then translating 
it into Thumb-2 assembly code.

Debugging assembly code proved to be challenging. The low-level nature of assembly instructions 
means that a single incorrect instruction can lead to system crashes or unpredictable behavior. 
Several improvements could be made to enhance the efficiency and reliability of the 
implemented functions. For instance, optimizing the inner loops of functions like _bzero and 
_strncpy could reduce execution time and improve performance. If I had more time, I would 
perform more comprehensive testing is needed to find and fix potential bugs, especially in edge 
cases. While the implemented functions were tested under typical conditions, additional testing 
under various scenarios, such as boundary conditions would help me uncover hidden issues. 
I would also focus on enhancing the integration of the buddy system for memory management. 
Implementing more sophisticated algorithms to handle memory allocation and deallocation, 
along with detailed logging and monitoring of memory usage, which would improve the system's 
efficiency and reliability.
