CC = "/opt/riscv/bin/riscv32-unknown-linux-gnu-gcc"
CFLAGS = -Wall -g -static
LD = "/opt/riscv/bin/riscv32-unknown-linux-gnu-ld"
AS = "/opt/riscv/bin/riscv32-unknown-linux-gnu-as"

as-move: as-move.o 
	$(LD) -o as-move as-move.o

as-move.o: as-move.s
	$(AS) -o as-move.o as-move.s 

clean:
	$(RM) as-move as-move.o
