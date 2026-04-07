// this file contains a critical function that mapps memory to a certain adress.
// if takes a single argument: a ptr to the following memory layout:
//              uint64_t real_addr                      +0
//              uint64_t virtual_addr                   +8
//              uint64_t number_of_pages                +16
//              uint64_t PML4_table_index               +24
//              uint64_t PDPT_table_index               +32
//              uint64_t PDT_table_index                +40
//              uint64_t PT_table_index                 +48
//              uint64_t used_space                     +56
// it returns this same struct with updated fiels

.global map_memory_space
map_memory_space:
    // create the stack frame
    push %rsp
    mov %rsp, %rbp
    push %r9
    push %r10
    push %r11
    push %r12
    push %r13
    // the struct is contained in rdi
    // now, we can start mapping memory
    // tables adresses 
    mov (rdi + 24), %rax
    mov (rdi + 32), %rbx
    mov (rdi + 40), %rdx
    mov (rdi + 48), %rsi
    // used_space, real addr, virtual addr, number of pages
    mov (rdi + 56), %r8
    mov (rdi + 0), %r9
    mov (rdi + 8), %r10
    mov (rdi + 16), %r11
    push %r9                                        /*preserve real addr*/
.main_loop:
    // we first need to check that none of the tables are filled, and if they are, allocate new ones.
    // calculate the index in the PML4 table
    push %rdx
    push %rax
    xor %rdx, %rdx
    mov %rbx, %rax
    div $4096                                       /*index (rdx) = addr (rax) % 4096*/
    mov %rdx, %r13
    pop %rdx
    pop %rax
    // now, check if the table is filled
    cmp %r13, $511
    jae .allocate_PDPT_entry
    jmp .scan_PDT_table
.allocate_PML4_entry:
    movl %r9, %r12
    orl $3, %r12                                    /* present | writable */
    movl %r12, (%rax)
    mov %r9, %rbx
    addl $8, %rax
    addl $4096, %r9
.scan_PDT_table:
    //calculate the index in the PDT table
    push %rdx
    push %rax
    mov %rdx, %r13
    xor %rdx, %rdx
    mov %r13, %rax
    div $4096                                       /*index (rdx) = addr (rax) % 4096*/
    mov %rdx, %r13
    pop %rdx
    pop %rax
    // now, check if the table is filled
    cmp %r13, $511
    jae .allocate_PDT_entry
    jmp .scan_PT_table
.allocate_PDT_entry:
    movl %r9, %r12
    orl $3, %r12                                    /* present | writable */
    movl %r12, (%rbx)
    mov %r9, %rdx
    addl $8, %rbx
    addl $4096, %r9
.scan_PT_table:
    push %rdx
    push %rax
    xor %rdx, %rdx
    mov %rsi, %rax
    div $4096                                       /*index (rdx) = addr (rax) % 4096*/
    mov %rdx, %r13
    pop %rdx
    pop %rax
    // now, check if the table is filled
    cmp %r13, $511
    jae .allocate_PT_entry
    jmp .allocate_memory_page
.allocate_PT_entry:
    movl %r9, %r12
    orl $3, %r12                                    /* present | writable */
    movl %r12, (%rdx)
    mov %r9, %rsi
    addl $8, %rdx
    addl $4096, %r9
.allocate_memory_page:
    // here's the core of the function : the code to allocate a memory page at a given adress 
    dec %r11
    jnz .main_loop                                  /* memory mapping is done */
    // set the used space field
    pop %r12
    mov %r12, %r8
    sub %r9, %r8
    // now, quit the function
    mov %rbp, %rsp
    pop %r13
    pop %r12
    pop %r11
    pop %r10
    pop %r9
    pop %rsp
    ret
