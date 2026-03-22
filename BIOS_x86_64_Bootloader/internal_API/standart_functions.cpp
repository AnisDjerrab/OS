// this file contains the standard functions provided to the bootloader
#include <stdint.h>
#include <uchar.h>

volatile char* VGA_MEMORY = (char*)0xB8000;
volatile char* VGA_TMP_BUFFER = (char*)0x3000;

void memcpy(int* dest, int* src, uint64_t size) {
    // since the 1st arg, dest, is contained in %rdi, we do not need to move it
    // since the 2nd arg, src, is contained in %rsi, we do not need to move it
    asm volatile("movq %%rdx, %%rcx \n\t"
                 "cld               \n\t"
                 "rep movsb         \n\t"
                 : // no output
                 : "D"(dest), "S"(src), "c"(size)
                 : "rdx", "memory");
}

void memset(int* ptr, char8_t value, uint64_t size) {
    asm volatile("movb %%sil, %%al  \n\t"
                 "movq %%rdx, %%rcx \n\t"
                 "cld               \n\t"
                 "rep stosb         \n\t"
                 : // no output
                 : "D"(ptr), "a"(value), "c"(size)
                 : "rdx", "memory");
}

void memset(int* ptr, char16_t value, uint64_t size) {
    asm volatile("movw %%si, %%ax   \n\t"
                 "movq %%rdx, %%rcx \n\t"
                 "cld               \n\t"
                 "rep stosw         \n\t"
                 : // no output
                 : "D"(ptr), "a"(value), "c"(size)
                 : "rdx", "memory");
}

int strlen(const char* str) {
    int len = 0;
    while (1) {
        if (str[len] == 0) {
            return len;
        }
        len++;
    }
}


int printf(const char* str, int line) {
    int numberOfLines = strlen(str) / 80 + 1;
    char16_t placeholder = 0x0007;
    if (80 - line >= numberOfLines) {
        memset((int*)(VGA_MEMORY + line*80), placeholder, numberOfLines*80);
        for (int i = 0; i < strlen(str); i+=2) {
            VGA_MEMORY[i + line*80] = str[i/2];
            VGA_MEMORY[i + 1 + line*80] = 0x07;
        }
        line += numberOfLines;
        return numberOfLines;
    } else {
        int neededLines = (80 - line - numberOfLines) * -1;
        memcpy((int*)(VGA_MEMORY + neededLines * 80), (int*)(VGA_TMP_BUFFER), (25 - neededLines) * 80);
        memset((int*)(VGA_MEMORY), placeholder, 80*25);
        memcpy((int*)(VGA_TMP_BUFFER), (int*)(VGA_MEMORY), (25 - neededLines) * 80);
        memcpy((int*)(VGA_MEMORY + (25 - neededLines)*80), (int*)(str), strlen(str));
        line = 25;
        return line;
    }

}
