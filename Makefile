#JOS makefile

jos: boot.o kernel.o
	nasm -fbin boot.o kernel.o -o jos.bin

boot: boot.asm
	nasm -felf32 boot.asm -o boot.o

kernel: kernel.asm
	nasm -felf32 kernel.asm -o kernel.o

.PHONY: clean run

clean:
	rm *.o

run: jos.bin
