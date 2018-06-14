#----------------------------------------------------------------
# Program lab_3a.s - Asemblery Laboratorium IS II rok
#----------------------------------------------------------------
#
#  To compile: as -o lab_3a.o lab_3a.s
#  To link:    ld -o lab_3a lab_3a.o
#  To run:     ./lab_3a
#STWORZENIE PLIKU, ZAPISANIE 10 LINI PETLA, ZAMKNIECIE
#----------------------------------------------------------------

	.equ	create_64,	0x55	# create file function
	.equ	close_64,	0x03	# close file function
	.equ	write_64,	0x01	# write data to file function
	.equ	exit_64,	0x3c	# exit program function

	.equ	mode,	0x180	# attributes for file creating, prawa dostepu
#0x180 - 110 000 000, 0x1ff - 111 111 111, iloczyn logiczny z zanegowana maska?

	.equ	errval,	2
	.equ 	stderr, 2
	
	.data
counter:		#dodanie nowej etykiety counter
	.byte 10
	
file_n:				# file name (0 terminated)
	.string	"testfile.txt"  #lub: .ascii "nazwa\0"?

file_h:				# file handle
	.quad		0

txtline:			# text to be written to file
	.ascii	"A line of text\n"

txtlen:				# size of written data
	.quad		( . - txtline )

errmsg:				# file error message
	.ascii	"File error!\n"

errlen:
	.quad		( . - errmsg )

allokmsg:			# All OK message
	.ascii	"\nAll is OK - too hard to believe!\n"

alloklen:
	.quad		( . - allokmsg )

	.text
	.global _start
	
_start:
	MOV	$create_64,%rax	# create function
	MOV	$file_n,%rdi	# RDI points to file name
	MOV	$mode,%rsi	# mode of created file in RSI
	SYSCALL
	
	CMP	$0,%rax
	JL	error		# if RAX<0 then something went wrong

	MOV	%rax,file_h	# store file handle returned in EAX

loop:						#petla loop wypisy=ujaca 10 linii w pliku
	MOV	$write_64,%rax	# write function
	MOV	file_h,%rdi	# file handle in RDI
	MOV	$txtline,%rsi	# RSI points to data buffer
	MOV	txtlen,%rdx	# bytes to be written
	SYSCALL

	CMP	%rdx,%rax
	JNZ	error		# if RAX<>RDX then something went wrong

	DECB counter	#odejmowanie od 10 po 1 az do 0
	JNZ loop		#przeskocz znowu do petli jesli nie jest zerem

	MOV	$close_64,%rax	# close function
	MOV	file_h,%rdi	# file handle in RDI
	SYSCALL

	CMP	$0,%rax
	JL	error		# if RAX<0 then something went wrong

all_ok:
	MOV	$write_64,%rax	# write function
	MOV	$stderr,%rdi	# file handle in RDI
	MOV	$allokmsg,%rsi	# RSI points to All OK message
	MOV	alloklen,%rdx	# bytes to be written
	SYSCALL

	XOR	%rdi,%rdi
	JMP	theend

error:
	MOV	$write_64,%rax	# write function
	MOV	$stderr,%rdi	# file handle in RDI
	MOV	$errmsg,%rsi	# RSI points to file error message
	MOV	errlen,%rdx	# bytes to be written
	SYSCALL

	MOV	$errval,%rdi

theend:
	MOV	$exit_64,%rax	# exit program function
	SYSCALL

