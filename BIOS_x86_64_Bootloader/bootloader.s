/* this is the stage 1 bootloader -- the first bit of code that is executed on the machine */
/* AnisDjerrab, 2025, GPL v3.0 */

.section .text
.org 0x7C00         /* tells GAS that the code will start at that adress (convention) */
.code16             /* set ro the real mode */
_start: jmp boot    /* set the boot function */


boot:
    /* basic init of the system */
    cli             /* no interrupts */
    cld             /* init the system */
    /* set the buffer index */
    mov $0x50, %ax  /* start adress of the OS */
    /* this is a standard start adress that does not corrupt BIOS memory and leaves space for the OS */
    movw %ax, %es
    xorw %bx, %bx
    mov $8, %al     /* read Heigt sectors */
    mov $0, %ch     /* track 0 */
    mov $2, %cl     /* sectors to read (the second sector) */
    mov $0, %dh     /* head number */
    mov $0, %dl     /* drive number */
    mov $0x02, %ah  /* read sectors for disk */
    int $0x13       /* call the BIOS routine.. */
    jc disk_error   /* catch the failed reads */
    ljmp $0x50,$0x0 /* boot the operating system */

disk_error:
    mov $0x0E, %ah  /* BIOS teletype output function */
    mov $'!', %al   /* Character to print */
    int $0x10       /* Call BIOS interrupt */
    hlt             /* halt the system in case something went wrong */

/* we have to be 512 bytes long. erase the rest of the */
.fill 510 -(.-_start), 1, 0
/* boot signature */
.word 0xAA55
