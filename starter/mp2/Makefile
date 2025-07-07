CC = "/opt/riscv/bin/riscv32-unknown-linux-gnu-gcc"
CFLAGS = -Wall -g -static
LD = "/opt/riscv/bin/riscv32-unknown-linux-gnu-ld"
AS = "/opt/riscv/bin/riscv32-unknown-linux-gnu-as"

as-ccals: as-ccals.s 
	$(CC) -static -o as-ccals as-ccals.s

clean:
	$(RM) as-ccals 
