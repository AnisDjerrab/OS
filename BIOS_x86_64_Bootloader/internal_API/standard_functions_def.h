// this file contains definitions of the standard functions provided to the bootloader

#include <stdint.h>
typedef uint8_t char8_t;

extern char* tmp_buffer;
extern int64_t* line;

// declare the map_memory_space_flat & map_memory_space_flat structs
struct memory_space_map_flat {
    uint64_t real_addr;
    uint64_t number_of_pages;
    uint64_t PML4_table_index;
    uint64_t PDPT_table_index;
    uint64_t PDT_table_index;
    uint64_t PT_table_index;
    uint64_t used_space;
};
struct memory_space_map_virtual {
    struct memory_space_map_flat flat_strct;
    int64_t virtual_addr;
};

// include the asm func to change the cursor position wherever we want
extern "C" volatile void setCursorPos(uint32_t pos);

void memcpy(int* dest, int* src, uint64_t size);

void memset(int* ptr, char8_t value, uint64_t size);

void memset(int* ptr, char16_t value, uint64_t size);

int strlen(const char* str);

int printf(const char* str, int line);

char* itoa(int number, char* str, int base);

char* merge(char* output_str, int number_of_elements, char* input_strings[]);

extern "C" void map_memory_space_flat(memory_space_map_flat* map);
