OUTPUT_FORMAT(binary)
OUTPUT(BIOS_x86_64_Bootloader/early_boot.bin)

ENTRY(_start)

SECTIONS
{
    . = 0x500;

    .text : ALIGN(1)
    {
        BIOS_x86_64_Bootloader/early_boot.o(.text*)
        BIOS_x86_64_Bootloader/c_combined.o(.text*)
        *(.text*)
    }

    .rodata : ALIGN(1)
    {
        BIOS_x86_64_Bootloader/early_boot.o(.rodata*)
        BIOS_x86_64_Bootloader/c_combined.o(.rodata*)
        *(.rodata*)
    }

    .data : ALIGN(1)
    {
        BIOS_x86_64_Bootloader/early_boot.o(.data*)
        BIOS_x86_64_Bootloader/c_combined.o(.data*)
        *(.data*)
    }

    .bss : ALIGN(1)
    {
        BIOS_x86_64_Bootloader/early_boot.o(.bss*)
        BIOS_x86_64_Bootloader/c_combined.o(.bss*)
        *(COMMON)
    }

    /DISCARD/ :
    {
        *(.eh_frame*)
        *(.comment)
        *(.note*)
    }
}
