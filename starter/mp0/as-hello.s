# RISC-V Assembler program to print "Hello World!"
#
# a0-a2 : parameters to linux function services
# a7    : linux function number
#
.equ  STDOUT, 1
.equ  SYS_WRITE, 64
.equ  SYS_EXIT, 93

.section  .data
.align 8

hello_world:  .string	"Hello World!\n"

.section  .text
.align 8
.global _start      # Provide program starting address to linker

# Setup the parameters to print hello world
# and then call Linux to do it.

_start: 
  li    a0, STDOUT        # 1 = StdOut
  la    a1, hello_world   # load address of hello_world
  addi  a2, x0, 13        # number of chars to write 
  li    a7, SYS_WRITE     # system call to write 
  ecall                   

# Setup the parameters to exit the program
# and then call Linux to do it.

  addi  a0, x0, 0         # return code 
  li	  a7, SYS_EXIT    # syscall to exit 
  ecall               		
