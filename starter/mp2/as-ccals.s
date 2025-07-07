.section	.rodata
.align 8
enter_prompt: 	.asciz "Enter a, b, and c: "
scan: 		.asciz "%d %d %d"
result_out: 	.asciz "Result = %d\n"

.section .text
.align 8
.global main

main: 
    jal		prompt_sum

    # Exit 
    addi	a0, x0, 0 
    li		a7, 93
    ecall

prompt_sum:
    addi	sp, sp, -32     # Allocate 32 bytes from the stack
    sw		ra, 0(sp)       # Since we are making calls, we need the original RA

    # Prompt the user first
    la		a0, enter_prompt 
    call	printf

    # We've printed the prompt, now wait for user input
    la		a0, scan
    addi	a1, sp, 8        # Address of a is sp + 8
    addi	a2, sp, 16       # Address of b is sp + 16
    addi	a3, sp, 24       # Address of c is sp + 24
    call	scanf
    
    # Now all of the values are in memory, load them
    lw		a0, 8(sp)
    lw		a1, 16(sp)
    lw		a2, 24(sp)

    # Sum the numbers, result in a1 
    add		a1, a1, a0
    add		a1, a1, a2
    la		a0, result_out
    call	printf

    # Restore original RA and return
    lw      	ra, 0(sp)
    addi    	sp, sp, 32       # Always deallocate the stack!
    ret 
    

    
