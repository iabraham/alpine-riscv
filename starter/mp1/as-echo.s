# RISC-V Assembler program to print "Hello World!" and echo 
# user input via stdin back to stdout 
#
# a0-a2 : parameters to linux function services
# a7    : linux function number
#
.equ  STDIN, 0
.equ  SYS_READ, 63
.equ  MAX_CHARS, 31
.equ  STDOUT, 1
.equ  SYS_WRITE, 64
.equ  SYS_EXIT, 93

.section  .data
.align 8
  hello_world:  .string	"Hello World!\n"
  prompt:       .string	"Enter some characters:\n"
  result:       .string  "\nYou entered:\n"

.section  .bss
.align 8
  buffer:       .space 	32

.section  .text
.align 8
  .global _start      # Provide program starting address to linker

# Setup the parameters to print hello world
# and then call Linux to do it.

_start: 
  li    a0, STDOUT        # 1 = StdOut
  la    a1, hello_world   # load address of hello_world
  addi  a2, x0, 13        # (a) _______________________
  li    a7, SYS_WRITE     # system call to write 
  ecall                   

	addi  a0, x0, 1         # Manually set a0 = (b) __________
	la   	a1, prompt      # load address of prompt
	addi 	a2, x0, 23      # (c) ________________________  
	addi 	a7, x0, 64      # system call to write
	ecall

	li  	a0, STDIN       # (d) ___________________
	la   	a1, buffer      # Location for entry from STDIN
	li    a2, MAX_CHARS     # max chars to read
	li   	a7, SYS_READ    # sys to read, result (e) _________
	ecall

	mv	  s1, a0        # Save (f) ________________________

	li    a0, STDOUT
	la	  a1, result
	addi	a2, x0, 14      # (g) _____________________________
	li  	a7, SYS_WRITE
	ecall

	addi  a0, x0, 1
	la   	a1, buffer
	mv   	a2, s1          # (h) _____________________________
	addi  a7, x0, 64
	ecall

# Setup the parameters to exit the program
# and then call Linux to do it.

  addi  a0, x0, 0           # (i) _____________________________
  li	  a7, SYS_EXIT      # Service code (j)________ terminates
  ecall               		
