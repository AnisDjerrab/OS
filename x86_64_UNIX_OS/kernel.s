// define some essential variables
// reserve the minimal 4096 bytes of space for the PT, PDT and PDPT tables
.equ PDPT_table, 0x10000        /* hard coded adress for PDPT table ([beginning adress]*8) */
.equ PDT_table, 0x11000         /* hard coded adress for PDT table ([beginning adress]*8 + 4096) */
.equ PT_table, 0x12000          /* hard coded adress for PT table ([beginning adress]*8 + 4096*2) */
.equ PML4T_table, 0x13000       /* A page map level 4 table, which replaces the PDPT table as the root */

/* Access bits */
.equ PRESENT       , 1 << 7
.equ NOT_SYS       , 1 << 4
.equ EXEC          , 1 << 3
.equ DC            , 1 << 2
.equ RW            , 1 << 1
.equ ACCESSED      , 1 << 0

// Flags bits
.equ GRAN_4K      , 1 << 7
.equ SZ_32        , 1 << 6
.equ LONG_MODE    , 1 << 5

GDT64:
.equ  GDT64_Null, . - GDT64
        .quad 0
.equ  GDT64_Code, . - GDT64
        GDT64_Code.limit_lo: .word  0xffff
        GDT64_Code.base_lo: .word  0
        GDT64_Code.base_mid: .byte 0
        GDT64_Code.access: .byte PRESENT | NOT_SYS | EXEC | RW
        GDT64_Code.flags: .byte GRAN_4K | LONG_MODE | 0xF   /* Flags & Limit (high, bits 16-19) */
        GDT64_Code.base_hi: .byte 0
.equ  GDT64_Data, . - GDT64
        GDT64_Data.limit_lo: .word  0xffff
        GDT64_Data.base_lo: .word  0
        GDT64_Data.base_mid: .byte 0
        GDT64_Data.access: .byte PRESENT | NOT_SYS | RW
        GDT64_Data.Flags: .byte GRAN_4K | SZ_32 | 0xF       /* Flags & Limit (high, bits 16-19) */
        GDT64_Data.base_hi: .byte 0
      GDT64_Pointer:
        .word . - GDT64 - 1
        .quad GDT64

// this is the first code that is execute after the operating system starts
init32:
    // initialize all segment registers to 0x10 (entry #2 in the GDT)
    movw $0x10, %ax                     /* entry #2 in GDT */
    mov %ax, %ds                        /* ds = 0x10 */
    mov %ax, %es                        /* es = 0x10 */
    mov %ax, %fs                        /* fs = 0x10 */
    mov %ax, %gs                        /* gs = 0x10 */
    mov %ax, %ss                        /* ss = 0x10 */
    // set the top of the stack to an arbitrary location
    movl $0x200000, %esp
    // the VGA ptr will be considered edx
    // erase the vga memory
    mov $0xb8000, %edi          /* Set pointer to VGA memory */
    mov $0x07, %ah              /* Set attribute (white on black) */
    mov $80 * 25, %ecx          /* 80 columns × 25 rows = 2000 characters */
    xorb %al, %al               /* Clear character (null) */
    rep stosw                   /* Write 2000 times: [0x0007] pairs */
    // now, it's time to enter long mode -- 64 bit
    // we first need to check wether CPUID is supported on our CPU or not by trying to flip the ID bit (bit 21)
    // if we can flip it, CPUID is supported.
    pushfl
    pop %eax                            /* Copy flags into eax via the stack */
    mov %eax, %ecx                      /* Copy to ecx to compare later on */
    xor $(1 << 21), %eax                /* flip the ID bit */
    push %eax                           /* push eax */
    popfl                               /* Copy eax to FLAGS via the stack */
    pushfl                              /* push FLAGS */
    pop %eax                            /* Copy flags back to eax (With the flipped bit if CPUID is supported) */
    push %ecx                           /* push the original FLAGS */
    popfl                               /* Restore flags from the old version stored in ecx (i.e : flipping the ID bit back) */
    cmpl %ecx, %eax                     /* compare eax and ecx. if equal, then that means that the bit wasn't flipped, and CPUID isn't supported. */
    je .error_missing_required_CPU_Feature
    // no that we have confirmed that CPUID is indeed supported, we can use it to check if our CPU supports long mode.
    // test if extended processor info is avalaible
    mov $0x80000000, %eax                                       /* implicit argument for cpuid */
    cpuid                                                       /* get highest supported argument */
    cmpl $0x80000001, %eax                                      /* it needs to be at least 0x80000001 */
    jb .error_missing_required_CPU_Feature                      /* if it's less, the CPU is too old for long mode */
    // use extended info to test if
    mov $0x80000001, %eax                                       /* argument for extended processor info */
    cpuid                                                       /* returns various feature bits in ecx and edx */
    testl $(1 << 29), %edx                                      /* test if the LM-bit is set in the D-register */
    jz .error_missing_required_CPU_Feature                      /* If it's not set, there is no long mode */
    // setup page tables
    // we first need to erase the previous content of the tables to avoid any bugs
    movl $PDPT_table, %edi
    mov $(4096*5), %ecx
    xor %eax, %eax
    rep stosb
    // link the first PML4T table entry to the P4 table
    movl $PDPT_table, %eax
    orl $3, %eax                                    /* present | writable */
    movl %eax, (PML4T_table)
    // link the first P4 entry to the P3 table
    movl $PDT_table, %eax
    orl $3, %eax                                    /* present | writable */
    movl %eax, (PDPT_table)
    // link the first P3 entry to the P2 table
    movl $PT_table, %eax
    orl $3, %eax                                    /* present | writable */
    movl %eax, (PDT_table)
    // now we need to map each p2 table entry to a 4096 Bytes page
    // this way our kernel will have 2Mib of virtual memory directly
    // we *could* use 1Gb pages, but they would break compatibility with older intel CPU from before 2010
    // in order to achieve this, we need a loop which maps physical pages from 0x0 forward in memory
    mov $0, %ecx                                    /* counted variable */
    movl $3, %edx                                   /* present | writable */
    movl %edx, %eax
    xor %ebx, %ebx
.map_PT_table:
    // map the ecx entry of the PT_table to a page that starts at adress 0x0 * ecx
    movl %eax, PT_table(, %ecx, 8)      /* map ecx-th entry */
    addl $0x1000, %ebx                  /* 4096 Bytes */
    movl %edx, %eax
    orl %ebx, %eax
    incl %ecx                           /* increase counter */
    cmpl $512, %ecx                     /* check if we succesfully mapped all pages */
    jnae .map_PT_table                  /* if it's not done yet, continue. else, exit the loop. */
    // no, we enable paging directly using the cr3 CPU register
    movl $PML4T_table, %eax             /* eax contains the adress of the P4 table */
    mov %eax, %cr3                      /* mov this adress in the cr3 control register */
    // enable PAE-flag in cr4 (Physical Adress Extension)
    mov %cr4, %eax
    orl $0b10100000, %eax
    movl %eax, %cr4
    // disable IRQs
    mov $0xFF, %al                      /* Out 0xFF to 0xA1 and 0x21 to disable all IRQs. */
    outb %al, $0xA1
    outb %al, $0x21
    lidt IDT                            /* Load a zero length IDT so that any NMI causes a triple fault. */
    // set the long mode bit in the EFER MSR (model specific register)
    mov $0xC0000080, %ecx               /* read from the EFER MSR */
    rdmsr
    orl $0x00000100, %eax               /* set the LME limit */
    wrmsr
    // enable paging in the cr0 register
    mov %cr0, %eax
    orl $0x80000001, %eax               /* enable paging and protection simultaneously */
    movl %eax, %cr0
    // no, the CPU is still not in 64-bit mode -- it's still in a 32 bit compatibility submode
    // to truly use 64 bit, an essential legacy step is still the GDT table -- the 64 bit one, this time around
    lgdt GDT64_Pointer                  /* loads the GDT table */
    // far jmp to the 64 bit main to flush everything nicely
    // now, we manually encore the ljmp instruction that jumps to the x86_64 entry and flushes the instruction stream
    .byte 0xEA
    .long init64
    .word CODE_SEG

.error_missing_required_CPU_Feature:
    // placeholder, for now
    // maybe later an error message
    hlt

.code64

.extern kernel_main

init64:
    cli                                 /* no interruptions */
    // load 0x10 into all data segment registers
    movw $0x10, %ax
    mov %ax, %ss
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    // we are in 64 bit long mode
    // finally, load and launch the C main the scan disks and mount the ext2 partition
    mov $0x200000, %rsp                 /* set the top of the stack to the very end of the mapped RAM area */
    lea kernal_main(%rip), %rax
    callq *%rax                         /* now, we officially handed control of everything to the C main. */
