//TODO: add newline support
//TODO: add keyboard support
//TODO: write command interpreter

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#if defined(__linux__)
#error "No cross compiler detected!"
#endif

#if !defined(__i386__)
#error "This needs to be compiled with a ix86-elf compiler!"
#endif

enum vga_color {
  VGA_COLOR_BLACK = 0,
  VGA_COLOR_BLUE = 1,
  VGA_COLOR_GREEN = 2,
  VGA_COLOR_CYAN = 3,
  VGA_COLOR_RED = 4,
  VGA_COLOR_MAGENTA = 5,
  VGA_COLOR_BROWN = 6,
  VGA_COLOR_LIGHT_GREY = 7,
  VGA_COLOR_DARK_GREY = 8,
  VGA_COLOR_LIGHT_BLUE = 9,
  VGA_COLOR_LIGHT_GREEN = 10,
  VGA_COLOR_LIGHT_CYAN = 11,
  VGA_COLOR_LIGHT_RED  = 12,
  VGA_COLOR_LIGHT_MAGENTA = 13,
  VGA_COLOR_LIGHT_BROWN = 14,
  VGA_COLOR_WHITE = 15,
};

static inline uint8_t vgaEntryColor(enum vga_color fg, enum vga_color bg) {
  return fg | bg << 4;
}

static inline uint8_t vgaEntry(unsigned char uc, uint8_t color) {
  return (uint16_t)uc | (uint16_t) color << 8;
}

//implementation of strlen, which returns the size of a string, excluding the \0
size_t stringLen(const char* string) {
  size_t length = 0;
  while(string[length])
    length++;
  return length;
}

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

size_t terminalRow;
size_t terminalCol;
uint8_t terminalColor;
uint16_t* terminalBuffer;

void terminal_init(void) {
  terminalRow = 0; //Row
  terminalCol = 0; //Column
  //white on black terminal color
  terminalColor = vgaEntryColor(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
  terminalBuffer = (uint16_t*) 0xB8000;
  for(size_t y = 0; y < VGA_HEIGHT; y++) {
    for(size_t x = 0; x < VGA_WIDTH; x++) {
      const size_t index = y * VGA_WIDTH + x;
      terminalBuffer[index] = vgaEntry(' ', terminalColor);
    }
  }
}

void terminalSetColor(uint8_t color) {
  terminalColor = color;
}

void terminalPutEntryAt(char c, uint8_t color, size_t x, size_t y) {
  const size_t index = y * VGA_WIDTH + x;
  terminalBuffer[index] = vgaEntry(c, color);
}

void terminalPutChar(char c) {
  terminalPutEntryAt(c, terminalColor, terminalCol, terminalRow);
  if(++terminalCol == VGA_WIDTH) {
    terminalCol = 0;
    if(++terminalRow == VGA_HEIGHT)
      terminalRow = 0;
  }
}

void terminalWrite(const char* data, size_t size) {
  for(size_t i = 0; i < size; i++) {
    terminalPutChar(data[i]);
  }
}

void terminalWriteString(const char* data) {
  terminalWrite(data, stringLen(data));
}

void kernelMain(void) {
  terminal_init();
  terminalWriteString("JOS Kernel v1.0.0\n");
}
