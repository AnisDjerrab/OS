// this file contains definitions of the standard functions provided to the bootloader

#include <stdint.h>
#include <uchar.h>

void memcpy(int* dest, int* src, uint64_t size);

void memset(int* ptr, char8_t value, uint64_t size);

void memset(int* ptr, char16_t value, uint64_t size);

int strlen(const char* str);

int printf(const char* str, int line);
