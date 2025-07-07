CC = "/opt/riscv/bin/riscv32-unknown-linux-gnu-gcc"
CFLAGS = -Wall -g -static
LD = "/opt/riscv/bin/riscv32-unknown-linux-gnu-ld"
AS = "/opt/riscv/bin/riscv32-unknown-linux-gnu-as"

c-hello: c-hello.o
	$(CC) -static -o c-hello c-hello.o

c-hello.o: c-hello.s
	$(CC) -c c-hello.s

c-hello.s: c-hello.c 
	$(CC) -S c-hello.c -o c-hello.s

as-hello: as-hello.o 
	$(LD) -o as-hello as-hello.o

as-hello.o: as-hello.s
	$(AS) -o as-hello.o as-hello.s 

clean:
	$(RM) c-hello c-hello.o c-hello.s as-hello as-hello.o
