;JOS Multiboot header
MBALIGN equ 1 << 0
MEMINFO 1 << 1
FLAGS equ MBALIGN | MEMINFO
MAGIC equ 0x1BADB002
CHECKSUM equ -(MAGIC + FLAGS)

section .multiboot
align 4
  dd MAGIC
  dd FLAGS
  dd CHECKSUM

align 16
stack_bttm:
  resb 16384 ;16 Kilobyte stack
stack_top:

section .text
  global _start:function(_start.end - _start)
  ;_start is where the linker script specfies as the entry point to the kernel
_start:
  mov esp, stack_top ;set up the stack
  extern kernelMain
  call kernelMain
  ;if the system has nothing more to do, make it loop forever:
  cli ;disable interrupts
  
.hang:
    hlt
    jmp .hang
.end:
