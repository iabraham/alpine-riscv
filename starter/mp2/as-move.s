# Program to move around an * with WASD keys
#
.equ  STDOUT, 1
.equ  STDIN, 0
.equ  SYS_WRITE, 64
.equ  SYS_READ, 63
.equ  SYS_EXIT, 93
.equ  NCOLS, 40
.equ  NROWS, 25

.section  .data
.align 8
 cls: 	.string "\033[2J\033[1;1H"
 right: .byte ' '  # Move left 1 column;
 down: 	.byte '\n' # Move down 1 line;
 star:  .byte '*'
 input: .space 2
.align 4
 vga_x: .word 0
 vga_y: .word 0

.section  .text
.align 8
.global _start      # Provide program starting address to linker


_start: 
# Start by clearing the screen
  jal	_clear
  jal 	_print_star
  jal 	_poll_user
  j	_exit


_poll_user:

  # Write code

_print_star:

  # Write code 

_clear:
  li    a0, STDOUT        # 1 = StdOut
  la    a1, cls       	  # load address of hello_world
  addi  a2, x0, 10        # number of chars to write 
  li    a7, SYS_WRITE     # system call to write 
  ecall
  ret


# Setup the parameters to exit the program
# and then call Linux to do it.
_exit: 
  addi  a0, x0, 0         # return code 
  li	a7, SYS_EXIT    # syscall to exit 
  ecall               		
