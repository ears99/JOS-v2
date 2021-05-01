;JOS Kernel
BITS 32
VGA_WIDTH equ 80
VGA_HEIGHT equ 25

VGA_COLOR_BLACK equ 0
VGA_COLOR_BLUE equ 1
VGA_COLOR_GREEN equ 2
VGA_COLOR_CYAN equ 3
VGA_COLOR_RED equ 4
VGA_COLOR_MAGENTA 5
VGA_COLOR_BROWN equ 6
VGA_COLOR_LIGHT_GREY equ 7
VGA_COLOR_DARK_GREY equ 8
VGA_COLOR_LIGHT_BLUE equ 9
VGA_COLOR_LIGHT_GREEN equ 10
VGA_COLOR_LIGHT_CYAN equ 11
VGA_COLOR_LIGHT_RED equ 12
VGA_COLOR_LIGHT_MAGENTA equ 13
VGA_COLOR_LIGHT_BROWN equ 14
VGA_COLOR_WHITE equ 15

global kernel_main
kernel_main:
  mov dh, VGA_COLOR_WHITE
  mov dl, VGA_COLOR_BLACK
  call terminal_setColor
  mov esi, hello_str
  call terminal_writeString
  jmp $


;terminal_getidx:
;IN: dl: y, dh: x
;OUT: dx: index w/ offset set at 0xb8000 at VGA buffer
terminal_getidx:
  push ax ;preserve regs
  shl dh, 1 ;multiply by 2 bc every entry is a word (2 bytes)
  mov al, VGA_WIDTH
  mul dl
  mov dl, al

  shl dl, 1 ;same
  add dl, dh
  mov dh, 0
  pop ax
  ret

;terminal_set_color:
;IN: dl: BG color, dh: FG color
;OUT: NONE
terminal_setColor:
    shl dl, 4
    or dl, dh
    mov [terminal_color], dl
    ret

;terminal_getentryat:
;IN: dl: y, dh: x, al: ASCII character
;OUT: none
terminal_putEntryAt:
  pusha
  call terminal_getidx
  mov ebx, edx

  mov dl, [terminal_color]
  mov byte [0xB8000 + ebx], al
  mov byte [0xB8001 + ebx], dl
  popa
  ret

;IN: al: ASCII character
terminal_putChar:
  mov dx, [terminal_cursorPos] ;loads column at dh, row at dl
  call terminal_putEntryAt

  inc dh
  cmp dh, VGA_WIDTH
  jne .cursorMoved

  mov dh, 0
  inc dl

  cmp dl, VGA_HEIGHT
  jne .cursorMoved

  mov dl, 0

  .cursorMoved:
    ;store new cursor pos
    mov [terminal_cursorPos], dx
    ret

;terminal_write
;IN: cx: length of string, esi: string location
terminal_write:
  pusha
.looper:
  mov al, [esi]
  call terminal_putChar

  dec cx
  cmp cx, 0
  je .done

  inc esi
  jmp .looper

.done:
  popa
  ret

;terminal_strLen:
;IN: esi: zero-delimited string location
;OUT: ecx: string length
terminal_strLen:
  push eax
  push esi
  mov ecx, 0
.looper:
  mov al, [esi]
  cmp al, 0
  je .done

  inc esi
  inc ecx
  jmp .looper
.done:
  pop esi
  pop eax
  ret

;terminal_writeString
;IN: esi: string location
;OUT: none
terminal_writeString:
  pusha
  call terminal_strLen
  call terminal_write
  popa
  ret

hello_str db "JOS Kernal v1.0.0", 0x0A, 0
terminal_color db 0

terminal_cursorPos:
  terminal_column db 0
  terminal_row db 0
