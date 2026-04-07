// this file contains a critical function that mapps memory to a certain adress.
// if takes a single argument: a ptr to the following memory layout:
//              uint64_t real_addr                      +0
//              uint64_t number_of_pages                +8
//              uint64_t PML4_table_index               +16
//              uint64_t PDPT_table_index               +24
//              uint64_t PDT_table_index                +32
//              uint64_t PT_table_index                 +40
//              uint64_t used_space                     +48
// it returns nothing but modified the struct in place with updated data.

.global map_memory_space_flat
map_memory_space:
    // create the stack frame
    push %rsp
    mov %rsp, %rbp
    push %r9
    push %r10
    push %r11
    push %r12
    push %r13
    push %r14
    // the struct is contained in rdi
    // now, we can start mapping memory
    // tables adresses
    mov 16(%rdi), %rax
    mov 24(%rdi), %rbx
    mov 32(%rdi), %rdx
    mov 40(%rdi), %rsi
    // used_space, real addr, number of pages
    mov 48(%rdi), %r8
    mov 0(%rdi), %r9
    mov 8(%rdi), %r10
    push %r9                                        /*preserve real addr*/
    mov $4096, %r14
.main_loop:
    // we first need to check that none of the tables are filled, and if they are, allocate new ones.
    // calculate the index in the PML4 table
    push %rdx
    push %rax
    xor %rdx, %rdx
    mov %rbx, %rax
    div %r14                                       /*index (rdx) = addr (rax) % 4096*/
    mov %rdx, %r13
    pop %rdx
    pop %rax
    // now, check if the table is filled
    cmpq $511, %r13
    jae .allocate_PDPT_entry
    jmp .scan_PDT_table
.allocate_PDPT_entry:
    movq %r9, %r12
    orq $3, %r12                                    /* present | writable */
    movq %r12, (%rax)
    movq %r9, %rbx
    addq $8, %rax
    addq $4096, %r9
.scan_PDT_table:
    //calculate the index in the PDT table
    push %rdx
    push %rax
    mov %rdx, %r13
    xor %rdx, %rdx
    mov %r13, (%rax)
    div %r14                                       /*index (rdx) = addr (rax) % 4096*/
    mov %rdx, %r13
    pop %rdx
    pop %rax
    // now, check if the table is filled
    cmpq $511, %r13
    jae .allocate_PDT_entry
    jmp .scan_PT_table
.allocate_PDT_entry:
    movq %r9, %r12
    orq $3, %r12                                    /* present | writable */
    movq %r12, (%rbx)
    movq %r9, %rdx
    addq $8, %rbx
    addq $4096, %r9
.scan_PT_table:
    push %rdx
    push %rax
    xor %rdx, %rdx
    mov %rsi, %rax
    div %r14                                        /*index (rdx) = addr (rax) % 4096*/
    mov %rdx, %r13
    pop %rdx
    pop %rax
    // now, check if the table is filled
    cmpq $511, %r13
    jae .allocate_PT_entry
    jmp .allocate_memory_page
.allocate_PT_entry:
    movq %r9, %r12
    orq $3, %r12                                    /* present | writable */
    movq %r12, (%rdx)
    movq %r9, %rsi
    addq $8, %rdx
    addq $4096, %r9
.allocate_memory_page:
    // here's the core of the function : the code to allocate a memory page at a given adress
    movq $3, %r11                                   /* present | writable */
    movq %r11, %rsi
    addq $8, %rsi
    // now, loop
    dec %r10
    jnz .main_loop                                  /* memory mapping is done */
    // set the used space field
    pop %r12
    mov %r12, %r8
    sub %r9, %r8
    // write down th modified struct in RAM
    mov %rax, 16(%rdi)
    mov %rbx, 24(%rdi)
    mov %rdx, 32(%rdi)
    mov %rsi, 40(%rdi)
    mov %r8, 48(%rdi)
    mov %r9, 0(%rdi)
    mov %r10, 8(%rdi)
    // now, quit the function
    mov %rbp, %rsp
    pop %r14
    pop %r13
    pop %r12
    pop %r11
    pop %r10
    pop %r9
    pop %rsp
    ret
