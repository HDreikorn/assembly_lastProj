TITLE Combinations     (program6b.asm)

; Author: Hillary Dreikorn		 Email: dreikorh@oregonstate.edu
; Course: CS271-400-W18			 Due Date: 03/18/2018
;
; Description: This program will calculate the number of combinations
; of r items from a set of n.
; * Random numbers will be generated for r and n.
; * The problem will be shown to the user.
; * The user will enter their answer.
; * The calucaltion will be made using the formula : n!/(r!(n-r)!)
;   Where the factorial procedure will be implemented recursively.
; * Finally the results will be shown along with an evalution.

INCLUDE Irvine32.inc

LO = 3
HI = 12

; Macro for write string 
;-------------------------------------------------------
mWriteString MACRO	buffer:REQ
; Writes a string variable.
; Adapted from : Irvine, Kip. "Assembly Language for x86 Processors".
;                Chapter 10, p. 418
; Receives: string variable name.
;-------------------------------------------------------
push	edx
mov		edx, buffer
call	WriteString
pop		edx
ENDM

; Macro for write decimal 
;-------------------------------------------------------
mWriteDec MACRO	number:REQ
; Writes a a unsigned integer.
; Receives: variable for the integer to be displayed
;-------------------------------------------------------
push	eax
mov		eax, number
call	WriteDec
pop		eax
ENDM

.data?
result	DWORD	?
n		DWORD	?
r		DWORD	?
answer	DWORD	?

.data
progTitle	BYTE	"                         ~~~~~ Combination Practice ~~~~~", 0dh, 0ah, 0
progmrName	BYTE	"                         Programmed by: Hillary Dreikorn", 0dh, 0ah, 0
extraCred	BYTE	"         **EC #1 : Counts problems and reports number of right and wrong.**", 0dh, 0ah, 0
instructs	BYTE	"     This program will help you practice calculations for combinations problems.", 0dh, 0ah
			BYTE	"Enter your answer after the problem is shown, then an evaluation will be given, good luck!", 0dh, 0ah, 0
inputChar	BYTE	">> ", 0
invalInput	BYTE	"Invalid input!", 0dh, 0ah, 0
prob		BYTE	0dh, 0ah, "Problem ", 0
setMsg		BYTE	":", 0dh, 0ah, "Number of elements in the set: ", 0
choiceMsg	BYTE	0dh, 0ah, "Number of elements to choose from the set: ", 0
question	BYTE	0dh, 0ah, "How many combinations are there?", 0dh, 0ah, 0
result1		BYTE	0dh, 0ah, "There are ", 0
result2		BYTE	" combinations of ", 0
result3		BYTE	" items in a set of ", 0
wrong		BYTE	".", 0dh, 0ah, "Your answer was incorrect, keep working at it!", 0dh, 0ah, 0
right		BYTE	".", 0dh, 0ah, "Your answer was correct, keep up the good work!", 0dh, 0ah, 0
keepOnMsg	BYTE	0dh, 0ah, "Do want to keep practicing (y/n)?", 0dh, 0ah, 0
endMsg		BYTE	"         You did great. Come back soon, goodbye!", 0dh, 0ah, 0
ec1			BYTE	"      ** You answered ", 0
ec2			BYTE	" correct and ", 0
ec3			BYTE	" incorrect. **", 0dh, 0ah, 0
count		DWORD	1
wrgAns		DWORD	0
rgtAns		DWORD	0
buffer		BYTE	20 DUP(0)

.code
main PROC

; Introduction (@progTitle, @progmrName, @instructs)
call	Introduction
call	Randomize			; Call once to set seed

practice:
; showProblem(@r, @n)
push	OFFSET r
push	OFFSET n
call	showProblem

; getUserData(size, @buffer, @answer)
push	SIZEOF buffer
push	OFFSET buffer
push	OFFSET answer
call	getUserData

; combinations(n, r, @result)
push	n
push	r
push	OFFSET result
call	combinations

; showResults(@wrgAns, @rgtAns, n, r, answer, result)
push	OFFSET wrgAns
push	OFFSET rgtAns
push	n
push	r
push	answer
push	result
call	showResults

mWriteString  OFFSET keepOnMsg
; toContinue(@count) = ebx
push	OFFSET count
call	toContinue
cmp		ebx, 1				; If ebx == 1, continue program
je		practice
; Else, report results end the program .
push	wrgAns
push	rgtAns
call	endingProc

 	exit  ; exit to operating system
main ENDP

;-------------------------------------------------------
Introduction PROC
; Displays introductory information including name of
; program and programmer, EC information, instruction
; for user. 
; Receives:
;	ptrTitle: PTR BYTE			; progTitle string
;	ptrName: PTR BYTE			; progmrName string
;	ptrInstr: PTR BYTE			; instructs string
; Returns: nothing
;-------------------------------------------------------
enter	0,0

mWriteString	OFFSET progTitle
mWriteString	OFFSET progmrName	
mWriteString	OFFSET extraCred	
mWriteString	OFFSET instructs	

leave
ret					
Introduction ENDP

;-------------------------------------------------------
getUserData PROC
; Prompts the user to enter answer to the problem.
; Gets user data as a string then converts it to an int.
; Stores value in answer variable.
; Receives: size = [ebp+16]
;			@buffer = [ebp+12]
;			@answer = [ebp+8]
; Returns : nothing
;-------------------------------------------------------
enter	0,0
pushad

mov		edi, [ebp+8]	; load @answer for later use
mov		eax, 0			; start answer at 0
mov		[edi], eax

readInput:
mWriteString OFFSET question	; Write question msg
mWriteString OFFSET inputChar	; Write input char

mov		edx, [ebp+12]	; Load in the @buffer
mov		ecx, [ebp+16]	; Load in SIZEOF buffer
call	ReadString		; eax = # of characteres entered

mov		ecx, eax		; loop counter = # of characters entered
mov		esi, [ebp+12]	; load @buffer into esi

parse:
mov		eax, [edi]		; move contents of answer into eax
mov		ebx, 10
mul		ebx				; multiply answer by 10
mov		[edi], eax		; copy product into answer
mov		al, [esi]		; move value of char into al
inc		esi				; move to next char
sub		al, 48			; subtract to get ASCII val
cmp		al, 0			; If char < zero, jump out
jl		invalEntry
cmp		al, 9			; If char > nine, jump out
jg		invalEntry
add		[edi], al		; add int into answer
loop	parse

jmp		completed

invalEntry:
mWriteString OFFSET invalInput	; Write invalid input msg
jmp		readInput

completed:
popad
leave
ret		12	
getUserData ENDP

;-------------------------------------------------------
toContinue PROC
; Evaluates the char recieved y or n.
; Returns true if user wants to continue otherwise returns
; false. 
; Receives: @count = [ebp+8]
; Returns: EBX = true or false		; 1(valid) or 0(invalid)
;-------------------------------------------------------
	enter	0,0
	push	eax					; save value in eax
	push	edi

	mov		edi, [ebp+8]
getChar:
	call	ReadChar
	cmp		al, 89				; compare user input to 'Y'
	JE		yes				
	cmp		al, 121			; compare user input to 'y'
	JE		yes				
	cmp		al, 78				; compare user input to 'N'
	JE		no
	cmp		al, 110			; compare user input to 'n'
	JE		no
inval:
	mWriteString OFFSET invalInput
	jmp		getChar

yes:
	mov		eax, 1
	add		[edi], eax				; Increase counter for problems done
	mov		ebx, 1				; change return value to 1(yes)
	jmp		endGetChar
no:
	mov		ebx, 0				; change return value to 0(no)
	jmp		endGetChar

endGetChar:
	pop		edi
	pop		eax					; restore eax
	leave
	ret		4
toContinue ENDP

;-------------------------------------------------------
showProblem PROC
; Generates the random numbers and displays the problem.
; Receives: n: PTR DWORD	; @n
;			r: PTR DWORD	; @r
; Returns: nothing
; Adapted from: nextRand PROC in CS271-400-W18 (Oregon State
; University) Lecture 20
;-------------------------------------------------------
	enter	0,0
	push	esi
	push	edi
	push	eax

	mov		esi, [ebp+8]	; @n
	mov		edi, [ebp+12]	; @r

	; Generate random number for n
	mov		eax, HI			; use formula: (HI-LO) + 1
	sub		eax, LO
	inc		eax
	call	RandomRange		; Produce range from 0 - (EAX - 1)
	add		eax, LO			; Add LO to keep in desired range
	mov		[esi], eax		; Copy value of eax into n
	
	; Generate random number for r in range [1..n]
	; eax = n = new HI
	; 1 = new LO
	; (HI - LO) + 1 = (n - 1) + 1 = n
	call	RandomRange		; Produce range from 0 - (n - 1)
	add		eax, 1			; Add new LO (1) to keep in desired range
	mov		[edi], eax		; Copy value into r

	; Display the problem
	mWriteString OFFSET prob	; Writes problem title
	mWriteDec	count
	mWriteString OFFSET setMsg	; Writes set message
	mWriteDec [esi]				; Writes n
	mWriteString OFFSET choiceMsg	; Writes choice message
	mWriteDec [edi]				; Writes r
	
	pop		eax
	pop		edi
	pop		esi
	leave
	ret		8
showProblem ENDP

;-------------------------------------------------------
combinations PROC
; 
; Receives:	n: DWORD
;			r: DWORD
;			result: PTR DWORD	; @result
; Returns : nothing
;-------------------------------------------------------
enter	12,0
pushad

mov		esi, [ebp+8]		; @result
mov		ecx, [ebp+16]		; move value of n into ecx
push	ecx
call	factorial			; eax = n!
mov		[ebp-4], eax		; save n! in local variable

mov		ebx, [ebp+12]		; move value of r into ebx
push	ebx
call	factorial			; eax = r!
mov		[ebp-8], eax		; save r! in local variable

sub		ecx, ebx			; subtract r from n
push	ecx
call	factorial			; eax = (n -r)!
mov		ebx, [ebp-8]		; mov r! into ebx
mul		ebx					; eax = r! * (n - r)!
mov		[ebp-12], eax		; save into local variable

mov		eax, [ebp-4]		; move n! into eax
mov		edx, 0				; clear edx
mov		ebx, [ebp-12]		; move in local variable for denominator value
div		ebx					; eax = n! / (r! * (n - r)!)

mov		[esi], eax			; save calculation in @result

popad
leave
ret		12	
combinations ENDP

;-------------------------------------------------------
factorial PROC
; 
; Receives: [ebp+8] = num , the number to calculate
; Adapted from: Irvine, Kip. "Assembly Language for x86 Processors".
;               Chapter 8, p. 305-306
; Returns : eax = the factorial of num
;-------------------------------------------------------
enter	0,0
push	ebx

mov		eax, [ebp+8]; load num into eax
cmp		eax, 0		; If num > 0
ja		L1			; continue with calculation
mov		eax, 1		; otherwise return 1 as 0!
jmp		L2

L1:
dec		eax
push	eax			; Use (num - 1) for next call		
call	factorial

ReturnFact:
mov		ebx, [ebp+8]; load in num
mul		ebx

L2:
pop	ebx
leave
ret	4	
factorial ENDP

;-------------------------------------------------------
showResults PROC
; 
; Receives:	@wrgAns = [ebp+28]
;			@rghtAns = [ebp+24]
;			n=[ebp+20],
;			r=[ebp+16],
;			answer=[ebp+12],
;			result=[ebp+8] 
; Returns : nothing
;-------------------------------------------------------
enter	0,0
pushad

mWriteString	OFFSET result1	; write result1
mWriteDec		[ebp+8]			; write result
mWriteString	OFFSET result2	; write result2
mWriteDec		[ebp+16]		; write r
mWriteString	OFFSET result3	; write result3
mWriteDec		[ebp+20]		; write n

mov		ecx, 1
mov		esi, [ebp+28]		; Save @wrgAns for later use
mov		edi, [ebp+24]		; Save @rgtAns for later use
mov		ebx, [ebp+8]		; Save result into ebx

cmp		ebx, [ebp+12]		; If answer == result, print right msg
jne		incorrect			; else print wrong msg
mWriteString	OFFSET right
add		[edi], ecx			; increment value of rgtAns
jmp		fin

incorrect:
mWriteString OFFSET wrong
add		[esi], ecx			; increment value of wrgAns

fin:
popad
leave
ret	24	
showResults ENDP

;-------------------------------------------------------
endingProc PROC
; 
; Receives:	wrgAns = [ebp+12]
;			rgtAns = [ebp+8]
; Returns : nothing
;-------------------------------------------------------
enter	0,0
pushad

mWriteString OFFSET ec1
mWriteDec [ebp+8]
mWriteString OFFSET ec2
mWriteDec [ebp+12]
mWriteString OFFSET ec3
mWriteString OFFSET endMsg

popad
leave
ret		8
endingProc ENDP
END main