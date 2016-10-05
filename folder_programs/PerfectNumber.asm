;  Jamie Harvey
;  harvey.jamie.j@gmail.com
;  sometimesSysAdmin.github.io

;  Input: "-th" [Number of threads] "-lm" [Number limit in quaternary]
;  Output: # of perfect numbers, # of deficient numbers, # of abundant numbers
;  Description: Assembly language program provide a count  of the Perfect numbers, 
;  Abundant numbers  and Deficient numbers between 2 and a user provided limit.

; ***************************************************************

section	.data

; -----
;  Define standard constants.

LF		equ	10			; line feed
NULL		equ	0			; end of string
ESC		equ	27			; escape key

TRUE		equ	1
FALSE		equ	-1

SUCCESS		equ	0			; Successful operation
NOSUCCESS	equ	1			; Unsuccessful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; system call code for read
SYS_write	equ	1			; system call code for write
SYS_open	equ	2			; system call code for file open
SYS_close	equ	3			; system call code for file close
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

; -----
;  Message strings

header		db	LF, "*******************************************", LF
		db	ESC, "[1m", "Number Type Counting Program", ESC, "[0m", LF, LF, NULL
msgStart	db	"--------------------------------------", LF	
		db	"Start Counting", LF, NULL
pMsgMain	db	"Perfect Count: ", NULL
aMsgMain	db	"Abundent Count: ", NULL
dMsgMain	db	"Deficit Count: ", NULL
msgProgDone	db	LF, "Completed.", LF, NULL

numberLimit	dq	0
threadCount	dd	0

; -----
;  Globals (used by threads)

idxCounter	dq	2
aCount		dq	0
pCount		dq	0
dCount		dq	0

myLock		dq	0

; -----
;  Thread data structures

pthreadID0	dq	0, 0, 0, 0, 0
pthreadID1	dq	0, 0, 0, 0, 0
pthreadID2	dq	0, 0, 0, 0, 0
pthreadID3	dq	0, 0, 0, 0, 0

; -----
;  Local variables for thread function.

msgThread1	db	" ...Thread starting...", LF, NULL

; -----
;  Local variables for printMessageValue

newLine		db	LF, NULL

; -----
;  Local variables for getParams function

LIMITMIN	equ	100
LIMITMAX	equ	4000000000

errUsage	db	"Usgae: ./numCounter -th <1|2|3|4> ",
		db	"-lm <quaternaryNumber>", LF, NULL
errOptions	db	"Error, invalid command line options."
		db	LF, NULL
errTHspec	db	"Error, invalid thread count specifier."
		db	LF, NULL
errTHvalue	db	"Error, invalid thread count value."
		db	LF, NULL
errLSpec	db	"Error, invalid limit specifier."
		db	LF, NULL
errLValue	db	"Error, limit out of range."
		db	LF, NULL

; -----
;  Local variables for int2Quartenary function

dFour		dd	4
tmpNum		dq	0

; -----

section	.bss

tmpString	resb	20


; ***************************************************************

section	.text

; -----
; External statements for thread functions.

extern	pthread_create, pthread_join

; ================================================================
;  Number type counting program.

global main
main:

; -----
;  Check command line arguments

	mov	rdi, rdi			; argc
	mov	rsi, rsi			; argv
	mov	rdx, threadCount
	mov	rcx, numberLimit
	call	getParams

	cmp	rax, TRUE	;If getParams returns True
	jne	progDone	;If not jump to progDone

; -----
;  Initial actions:
;	Display initial messages

	mov	rdi, header
	call	printString

	mov	rdi, msgStart
	call	printString

; -----
;  Create new thread(s)
;	pthread_create(&pthreadID0, NULL, &threadFunction0, NULL);

	mov	rdi, pthreadID0
	mov	rsi, NULL
	mov	rdx, numberTypeCounter
	mov	rcx, NULL
	call	pthread_create	;Create thread 1

	mov	rdi, msgThread1
	call	printString	;Create thread message

	cmp	dword[threadCount], 1
	je	noCallMoreThreads ;If threadCount == 1 don't call more threads

	mov	rdi, pthreadID1
	mov	rsi, NULL
	mov	rdx, numberTypeCounter
	mov	rcx, NULL
	call	pthread_create	;Create thread 2

	mov	rdi, msgThread1
	call	printString	;Create thread message

	cmp	dword[threadCount], 2
	je	noCallMoreThreads ;If threadCount == 2 don't call more threads

	mov	rdi, pthreadID2
	mov	rsi, NULL
	mov	rdx, numberTypeCounter
	mov	rcx, NULL
	call	pthread_create	;Create thread 3

	mov	rdi, msgThread1
	call	printString	;Create thread message
	
	cmp	dword[threadCount], 3
	je	noCallMoreThreads ;If threadCount == 3 don't call more threads

	mov	rdi, pthreadID3
	mov	rsi, NULL
	mov	rdx, numberTypeCounter
	mov	rcx, NULL
	call	pthread_create	;Create thread 4

	mov	rdi, msgThread1
	call	printString	;Create thread message
noCallMoreThreads:	


; -----
;  Wait for thread(s) to complete.
;	pthread_join (pthreadID0, NULL);

WaitForThreadCompletion:

	cmp	dword[threadCount], 4
	jb	underFourThreadsJoin ;If threadCount < 4 jump to underFour
	
	mov	rdi, qword [pthreadID3]
	mov	rsi, NULL
	call	pthread_join	;Join thread 4

underFourThreadsJoin:
	cmp	dword[threadCount], 3
	jb	underThreeThreadsJoin ;If threadCount < 3 jump to underThree

	mov	rdi, qword[pthreadID2]
	mov	rsi, NULL
	call	pthread_join	;Join thread 3

underThreeThreadsJoin:	
	cmp	dword[threadCount], 2
	jb	underTwoThreadsJoin ;If threadCount < 2 jump to underThree

	mov	rdi, qword[pthreadID1]
	mov	rsi, NULL
	call	pthread_join	;Join thread 2

underTwoThreadsJoin:	

	mov	rdi, qword[pthreadID0]
	mov	rsi, NULL
	call	pthread_join	;Join thread 1
	

; -----
;  Display final count

showFinalResults:
	mov	rdi, newLine
	call	printString

	mov	rdi, pMsgMain
	call	printString
	mov	rdi, qword [pCount]
	mov	rsi, tmpString
	call	int2quaternary
	mov	rdi, tmpString
	call	printString
	mov	rdi, newLine
	call	printString

	mov	rdi, aMsgMain
	call	printString
	mov	rdi, qword [aCount]
	mov	rsi, tmpString
	call	int2quaternary
	mov	rdi, tmpString
	call	printString
	mov	rdi, newLine
	call	printString

	mov	rdi, dMsgMain
	call	printString
	mov	rdi, qword [dCount]
	mov	rsi, tmpString
	call	int2quaternary
	mov	rdi, tmpString
	call	printString
	mov	rdi, newLine
	call	printString

; **********
;  Program done, display final message
;	and terminate.

	mov	rdi, msgProgDone
	call	printString

progDone:
	mov	rax, SYS_exit			; system call for exit
	mov	rdi, SUCCESS			; return code SUCCESS
	syscall

; ******************************************************************
;  Thread function, numberTypeCounter()
;	display simple message (pre-defined)
;	while (idxCounter <= numberLimit)
;		detemrine the type (abundent, deficient, perfect)

; -----
;  Arguments:
;	N/A (global variable accessed)
;  Returns:
;	N/A (global variable accessed)
global numberTypeCounter
numberTypeCounter:	

	;; Get next number
getNextNumFromCount:	
	call	spinLock			;Locks for atomic operations
	mov	rax, qword[idxCounter]
	inc	qword[idxCounter]
	cmp	rax, qword[numberLimit]
	jae	reachedNumberLimit
	push	rax
	call 	spinUnlock
	pop	rax

	;; Begin sum at 1. Whenever a number is divided by i and rdx = 0, add i to sum
	mov	r9, 2		;r9 = i, begins at 2 because 1 will always be a divisor
	mov	r10, rax	;Save number in r10
	mov	r11, 1		;Running sum
	mov	r8, rax
	shr	r8, 1		;number/2 in r8


	;; Find divisors

	;; Number%i
divisionLoop:	
	mov	rax, r10	;Restore number in rax
	mov	rdx, 0		;Unsigned division
	div	r9		;r9 is i, remainder in rdx
	
	;; If Number%i == 0 add i to sum
	cmp 	rdx, 0
	jne	nextI		;Jump if number%i != 0

	add	r11, r9		;Add i to sum
nextI:	
	;; Check if i >= number/2
	cmp	r9, r8
	jae	checkSum
	;; If not, get next i

	inc	r9
	jmp	divisionLoop

checkSum:
	cmp	r11, r10	;If sum < number
	jb	incDCount	;Increment dCount

	cmp	r11, r10	;If sum > number
	ja	incACount	;Increment aCount

	cmp	r11, r10	;If sum = number
	je	incPCount	;Increment pCount

incDCount:
	lock inc qword[dCount]	;inc dCount
	jmp	getNextNumFromCount ;Get next number

incACount:
	lock inc qword[aCount]	; inc aCount
	jmp	getNextNumFromCount ;Get next number

incPCount:
	lock inc qword[pCount]	;inc pCount
	jmp	getNextNumFromCount ;Get next number

	;; Error Handling ******************************************
reachedNumberLimit:
	call	spinUnlock
	ret


; ******************************************************************
;  Mutex lock
;	checks lock (shared gloabl variable)
;		if unlocked, sets lock
;		if locked, loops to recheck until lock is free

global	spinLock
spinLock:
	mov	rax, 1			; Set the EAX register to 1.

lock	xchg	rax, qword [myLock]	; Atomically swap the RAX register with
					;  the lock variable.
					; This will always store 1 to the lock, leaving
					;  the previous value in the RAX register.

	test	rax, rax	        ; Test RAX with itself. Among other things, this will
					;  set the processor's Zero Flag if RAX is 0.
					; If RAX is 0, then the lock was unlocked and
					;  we just locked it.
					; Otherwise, RAX is 1 and we didn't acquire the lock.

	jnz	spinLock		; Jump back to the MOV instruction if the Zero Flag is
					;  not set; the lock was previously locked, and so
					; we need to spin until it becomes unlocked.
	ret

; ******************************************************************
;  Mutex unlock
;	unlock the lock (shared global variable)

global	spinUnlock
spinUnlock:
	mov	rax, 0			; Set the RAX register to 0.

	xchg	rax, qword [myLock]	; Atomically swap the RAX register with
					;  the lock variable.
	ret

; ******************************************************************
;  Convert integer to ASCII/Quaternary string.
;	Note, no error checking required on integer.

; -----
;  Arguments:
;	1) integer, value
;	2) string, address
; -----
;  Returns:
;	ASCII/Quaternary string (NULL terminated)

global int2quaternary
int2quaternary:
	mov	r9, 0		   ;Counter
	mov	rax, rdi	;Put integer value into rax
	mov	r10, 0
	mov	r10d, dword[dFour]	;Quaternary to int division

countLoop:
	mov	edx, 0		;Reset rdx for division
	div	r10d		;Get next quat digit
	push	rdx		;Push quat digit to stack
	inc	r9
	cmp	rax, 4		;Look if there are more digits
	jge	countLoop	;Jump if greater or equal 4 because more quat digits can be pulled

	;; Get last digit
	push	rax
	inc	r9

	;; Now get digits off stack and add "0" to get chars

	mov	r11, 0		;r9 is counter and must start at 0
cvtQuatChar:
	pop	r8		;Get quat digit
	add	r8, "0"		;Convert to quat char
	mov	byte[rsi+r11], r8b ;Put quat char in &string
	inc	r11		;Get next digit
	cmp	r9, r11		;Loop while r9 > r11
	ja	cvtQuatChar

	mov	byte[rsi+r11], NULL

	;; Done, return
	ret
	



; ******************************************************************
;  Generic procedure to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:

; -----
; Count characters to write.

	mov	rdx, 0
strCountLoop:
	cmp	byte [rdi+rdx], NULL
	je	strCountLoopDone
	inc	rdx
	jmp	strCountLoop
strCountLoopDone:
	cmp	rdx, 0
	je	printStringDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; rdx=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

printStringDone:
	ret

; ******************************************************************
;  Function getParams()
;	Get, check, convert, verify range, and return the
;	thread count and number limit.

;  Example HLL call:
;	stat = getParams(argc, argv, &threadCount, &numberLimit)

;  This routine performs all error checking, conversion of ASCII/Quarternary
;  to integer, verifies legal range of each value.
;  For errors, applicable message is displayed and FALSE is returned.
;  For good data, all values are returned via addresses with TRUE returned.

;  Command line format (fixed order):
;	-th <1|2|3|4> -lm <quarternaryNumber>

; -----
;  Arguments:
;	1) ARGC, value
;	2) ARGV, address
;	3) thread count (dword), address
;	4) prime limit (qword), address
global	getParams
getParams:

	;; If argc == 1 display usage msg
	cmp	rdi, 1
	je	argcIsOne

	;; If argc < 5 display error msg
	cmp	rdi, 5
	jb	argcErrOptions

	;; If argc > 5 display error msg
	cmp	rdi, 5
	ja	argcErrOptions

	;; Check argv[1] "-th"
	mov	r11, qword[rsi+8]
	cmp	byte[r11], 0x2d		; "-"
	jne	badInputDescriptor
	cmp	byte[r11+1], 0x74 	; "t"
	jne	badInputDescriptor
	cmp	byte[r11+2], 0x68 	; "h"
	jne	badInputDescriptor
	cmp	byte[r11+3], 0x00 	; NULL
	jne	badInputDescriptor

	;; Check argv[2] and save in &threadCount
	mov	r11, qword[rsi+16]
	sub	byte[r11], "0"	;Convert char to int
	
	cmp	byte[r11], 1	;If thread#<1 jump to error
	jb	badThreadValue
	cmp	byte[r11], 4	;If thread#>4 jump to error
	ja	badThreadValue
	;Save byte at r11 to qword at rdx
	mov	r10, 0
	mov	r10b, byte[r11]	;Save in r10b with upper bits zeroed
	mov	dword[rdx], r10d	;Save this number in address at rdx

	;; Check argv[3] "-lm"
	mov	r11, qword[rsi+24]
	cmp	byte[r11], 0x2d		; "-"
	jne	badLimitDescriptor
	cmp	byte[r11+1], 0x6c 	; "l"
	jne	badLimitDescriptor
	cmp	byte[r11+2], 0x6d 	; "m"
	jne	badLimitDescriptor
	cmp	byte[r11+3], 0x00 	; NULL
	jne	badLimitDescriptor

	;; Convert argv[4] to int and save in &numberLimit
	mov	r11, qword[rsi+32] ;qStr
	mov	rdi, r11
	mov	rsi, rcx	;&numberLimit
	call	quaternary2int
	cmp	rax, FALSE
	je	badNumber

	;; rax already TRUE
	ret

	;; Error Handling******************************

	;; If argc == 1
argcIsOne:
	mov	rdi, errUsage
	call	printString
	jmp	badExit

	;; If argc < 5
argcErrOptions:
	mov	rdi, errOptions
	call	printString
	jmp	badExit

	;; If argv[1] != "-th"
badInputDescriptor:
	mov	rdi, errTHspec
	call	printString
	jmp	badExit

	;; If argv[2] > 4 || < 1
badThreadValue:
	mov	rdi, errTHvalue
	call	printString
	jmp	badExit

	;; If argv[3] != "-lm"
badLimitDescriptor:
	mov	rdi, errLSpec
	call	printString
	jmp	badExit

	;; If argv[4] returns with an error
badNumber:
	mov	rdi, errLValue
	call	printString
	jmp	badExit

badExit:
	mov	rax, FALSE
	ret

	

; ******************************************************************
;  Function: Check and convert ASCII/Quaternary to integer

;  Example HLL Call:
;	stat = quaternary2int(qStr, &num);
global quaternary2int
quaternary2int:

	mov	r11, 0		;Index
	mov	rax, 0		;Use for running sum
convertToIntLoop:
	mov	r10, 0		;r10 gets the char
	mov	r10b, byte[rdi+r11]
	cmp	r10b, NULL
	je	convertToIntDone ;NULL terminate

	;; Error Check
	cmp	r10b, "0"
	jb	badQuat	;Error check for less than "0"
	cmp	r10b, "4"
	ja	badQuat	;Error check for greater than "4"
	
	sub	r10b, "0"	;Convert char to int

	;; Part that adds converted char to int sum
	shl	rax, 2		;Sum = sum * 4
	add	rax, r10	;Sum = sum + int

	inc	r11		;Get next character
	jmp	convertToIntLoop
	
convertToIntDone:	
	;; Error Check
	cmp	rax, LIMITMAX	;Check below max
	ja	badQuat
	cmp	rax, LIMITMIN	;Check above max
	jb	badQuat

	mov	qword[rsi], rax
	mov	rax, TRUE
	ret
	
badQuat:
	mov	rax, FALSE
	ret


; ******************************************************************

