CC = "/opt/riscv/bin/riscv32-unknown-linux-gnu-gcc"
CFLAGS = -Wall -g -static
LD = "/opt/riscv/bin/riscv32-unknown-linux-gnu-ld"
AS = "/opt/riscv/bin/riscv32-unknown-linux-gnu-as"

c-echo: c-echo.o
	$(CC) -static -o c-echo c-echo.o

c-echo.o: c-echo.s
	$(CC) -c c-echo.s

c-echo.s: c-echo.c 
	$(CC) -S c-echo.c -o c-echo.s

as-echo: as-echo.o 
	$(LD) -o as-echo as-echo.o

as-echo.o: as-echo.s
	$(AS) -o as-echo.o as-echo.s 

clean:
	$(RM) c-hello c-hello.o c-hello.s as-hello as-hello.o as-echo as-echo.o
