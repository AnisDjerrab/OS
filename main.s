	.file	"main.cpp"
	.text
	.type	_ZL4outltj, @function
_ZL4outltj:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, %eax
	movl	%esi, -8(%rbp)
	movw	%ax, -4(%rbp)
	movl	-8(%rbp), %eax
	movzwl	-4(%rbp), %edx
#APP
# 19 "BIOS_x86_64_Bootloader/Peripherals/PCI.h" 1
	outl %eax, %dx
# 0 "" 2
#NO_APP
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	_ZL4outltj, .-_ZL4outltj
	.type	_ZL3inlt, @function
_ZL3inlt:
.LFB1:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, %eax
	movw	%ax, -20(%rbp)
	movzwl	-20(%rbp), %eax
	movl	%eax, %edx
#APP
# 23 "BIOS_x86_64_Bootloader/Peripherals/PCI.h" 1
	inl %dx, %eax
# 0 "" 2
#NO_APP
	movl	%eax, -4(%rbp)
	movl	-4(%rbp), %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	_ZL3inlt, .-_ZL3inlt
	.type	_ZL10pci_read32hhhh, @function
_ZL10pci_read32hhhh:
.LFB2:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movl	%ecx, %eax
	movl	%edi, %ecx
	movb	%cl, -20(%rbp)
	movl	%esi, %ecx
	movb	%cl, -24(%rbp)
	movb	%dl, -28(%rbp)
	movb	%al, -32(%rbp)
	movzbl	-20(%rbp), %eax
	sall	$16, %eax
	movl	%eax, %edx
	movzbl	-24(%rbp), %eax
	sall	$11, %eax
	orl	%eax, %edx
	movzbl	-28(%rbp), %eax
	sall	$8, %eax
	orl	%eax, %edx
	movzbl	-32(%rbp), %eax
	andl	$252, %eax
	orl	%edx, %eax
	orl	$-2147483648, %eax
	movl	%eax, -4(%rbp)
	movl	-4(%rbp), %eax
	movl	%eax, %esi
	movl	$3320, %edi
	call	_ZL4outltj
	movl	$3324, %edi
	call	_ZL3inlt
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	_ZL10pci_read32hhhh, .-_ZL10pci_read32hhhh
	.globl	_Z16scan_pci_devicesPji
	.type	_Z16scan_pci_devicesPji, @function
_Z16scan_pci_devicesPji:
.LFB3:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movl	%esi, -28(%rbp)
	movl	$0, -12(%rbp)
	movl	$0, -8(%rbp)
	movw	$0, -14(%rbp)
	jmp	.L7
.L16:
	movb	$0, -16(%rbp)
	jmp	.L8
.L15:
	movb	$0, -15(%rbp)
	jmp	.L9
.L14:
	movl	-12(%rbp), %eax
	cmpl	-28(%rbp), %eax
	jl	.L10
	movw	$512, -14(%rbp)
	jmp	.L11
.L10:
	movzbl	-16(%rbp), %esi
	movzwl	-14(%rbp), %eax
	movzbl	%al, %eax
	movl	$0, %ecx
	movl	$0, %edx
	movl	%eax, %edi
	call	_ZL10pci_read32hhhh
	movl	%eax, -4(%rbp)
	movl	-4(%rbp), %eax
	movzwl	%ax, %eax
	cmpl	$65535, %eax
	je	.L18
	addl	$1, -12(%rbp)
	movzwl	-14(%rbp), %eax
	sall	$16, %eax
	movl	%eax, %edx
	movzbl	-16(%rbp), %eax
	sall	$8, %eax
	movl	%edx, %ecx
	orl	%eax, %ecx
	movzbl	-15(%rbp), %edx
	movl	-8(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rsi
	movq	-24(%rbp), %rax
	addq	%rsi, %rax
	orl	%ecx, %edx
	movl	%edx, (%rax)
	jmp	.L13
.L18:
	nop
.L13:
	movzbl	-15(%rbp), %eax
	addl	$1, %eax
	movb	%al, -15(%rbp)
.L9:
	cmpb	$7, -15(%rbp)
	jbe	.L14
.L11:
	movzbl	-16(%rbp), %eax
	addl	$1, %eax
	movb	%al, -16(%rbp)
.L8:
	cmpb	$31, -16(%rbp)
	jbe	.L15
	movzwl	-14(%rbp), %eax
	addl	$1, %eax
	movw	%ax, -14(%rbp)
.L7:
	cmpw	$255, -14(%rbp)
	jbe	.L16
	movl	-12(%rbp), %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	_Z16scan_pci_devicesPji, .-_Z16scan_pci_devicesPji
	.globl	VGA_MEMORY
	.data
	.align 8
	.type	VGA_MEMORY, @object
	.size	VGA_MEMORY, 8
VGA_MEMORY:
	.quad	753664
	.globl	VGA_TMP_BUFFER
	.align 8
	.type	VGA_TMP_BUFFER, @object
	.size	VGA_TMP_BUFFER, 8
VGA_TMP_BUFFER:
	.quad	12288
	.text
	.globl	_Z6memcpyPiS_m
	.type	_Z6memcpyPiS_m, @function
_Z6memcpyPiS_m:
.LFB4:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movq	%rdx, -24(%rbp)
	movq	-8(%rbp), %rax
	movq	-16(%rbp), %rsi
	movq	-24(%rbp), %rcx
	movq	%rax, %rdi
#APP
# 11 "BIOS_x86_64_Bootloader/internal API/standart_functions.hpp" 1
	movq %rdx, %rcx
	cld
	rep movsb

# 0 "" 2
#NO_APP
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	_Z6memcpyPiS_m, .-_Z6memcpyPiS_m
	.globl	_Z6memsetPihm
	.type	_Z6memsetPihm, @function
_Z6memsetPihm:
.LFB5:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -8(%rbp)
	movl	%esi, %eax
	movq	%rdx, -24(%rbp)
	movb	%al, -12(%rbp)
	movq	-8(%rbp), %rsi
	movzbl	-12(%rbp), %eax
	movq	-24(%rbp), %rcx
	movq	%rsi, %rdi
#APP
# 20 "BIOS_x86_64_Bootloader/internal API/standart_functions.hpp" 1
	movb %sil, %al
	movq %rdx, %rcx
	cld
	rep stosb

# 0 "" 2
#NO_APP
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	_Z6memsetPihm, .-_Z6memsetPihm
	.globl	_Z6memsetPiDsm
	.type	_Z6memsetPiDsm, @function
_Z6memsetPiDsm:
.LFB6:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -8(%rbp)
	movl	%esi, %eax
	movq	%rdx, -24(%rbp)
	movw	%ax, -12(%rbp)
	movq	-8(%rbp), %rsi
	movzwl	-12(%rbp), %eax
	movq	-24(%rbp), %rcx
	movq	%rsi, %rdi
#APP
# 30 "BIOS_x86_64_Bootloader/internal API/standart_functions.hpp" 1
	movw %si, %ax
	movq %rdx, %rcx
	cld
	rep stosw

# 0 "" 2
#NO_APP
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	_Z6memsetPiDsm, .-_Z6memsetPiDsm
	.globl	_Z6strlenPKc
	.type	_Z6strlenPKc, @function
_Z6strlenPKc:
.LFB7:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)
	movl	$0, -4(%rbp)
.L25:
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	-24(%rbp), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	testb	%al, %al
	jne	.L23
	movl	-4(%rbp), %eax
	jmp	.L26
.L23:
	addl	$1, -4(%rbp)
	jmp	.L25
.L26:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	_Z6strlenPKc, .-_Z6strlenPKc
	.globl	_Z6printfPKci
	.type	_Z6printfPKci, @function
_Z6printfPKci:
.LFB8:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movl	%esi, -28(%rbp)
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	_Z6strlenPKc
	movslq	%eax, %rdx
	imulq	$1717986919, %rdx, %rdx
	shrq	$32, %rdx
	sarl	$5, %edx
	sarl	$31, %eax
	subl	%eax, %edx
	leal	1(%rdx), %eax
	movl	%eax, -8(%rbp)
	movw	$7, -14(%rbp)
	movl	$80, %eax
	subl	-28(%rbp), %eax
	cmpl	%eax, -8(%rbp)
	jg	.L28
	movl	-8(%rbp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$4, %eax
	movslq	%eax, %rsi
	movzwl	-14(%rbp), %ecx
	movq	VGA_MEMORY(%rip), %rdi
	movl	-28(%rbp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$4, %eax
	cltq
	addq	%rdi, %rax
	movq	%rsi, %rdx
	movl	%ecx, %esi
	movq	%rax, %rdi
	call	_Z6memsetPiDsm
	movl	$0, -12(%rbp)
	jmp	.L29
.L30:
	movl	-12(%rbp), %eax
	movl	%eax, %edx
	shrl	$31, %edx
	addl	%edx, %eax
	sarl	%eax
	movslq	%eax, %rdx
	movq	-24(%rbp), %rax
	leaq	(%rdx,%rax), %rcx
	movq	VGA_MEMORY(%rip), %rsi
	movl	-28(%rbp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$4, %eax
	movl	%eax, %edx
	movl	-12(%rbp), %eax
	addl	%edx, %eax
	cltq
	leaq	(%rsi,%rax), %rdx
	movzbl	(%rcx), %eax
	movb	%al, (%rdx)
	movq	VGA_MEMORY(%rip), %rcx
	movl	-12(%rbp), %eax
	leal	1(%rax), %esi
	movl	-28(%rbp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$4, %eax
	addl	%esi, %eax
	cltq
	addq	%rcx, %rax
	movb	$7, (%rax)
	addl	$2, -12(%rbp)
.L29:
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	_Z6strlenPKc
	cmpl	%eax, -12(%rbp)
	setl	%al
	testb	%al, %al
	jne	.L30
	movl	-8(%rbp), %eax
	addl	%eax, -28(%rbp)
	movl	-8(%rbp), %eax
	jmp	.L31
.L28:
	movl	$80, %eax
	subl	-28(%rbp), %eax
	movl	-8(%rbp), %edx
	subl	%eax, %edx
	movl	%edx, -4(%rbp)
	movl	$25, %eax
	subl	-4(%rbp), %eax
	movl	%eax, %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$4, %eax
	movslq	%eax, %rsi
	movq	VGA_TMP_BUFFER(%rip), %rcx
	movq	VGA_MEMORY(%rip), %rdi
	movl	-4(%rbp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$4, %eax
	cltq
	addq	%rdi, %rax
	movq	%rsi, %rdx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	_Z6memcpyPiS_m
	movzwl	-14(%rbp), %ecx
	movq	VGA_MEMORY(%rip), %rax
	movl	$2000, %edx
	movl	%ecx, %esi
	movq	%rax, %rdi
	call	_Z6memsetPiDsm
	movl	$25, %eax
	subl	-4(%rbp), %eax
	movl	%eax, %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$4, %eax
	movslq	%eax, %rdx
	movq	VGA_MEMORY(%rip), %rcx
	movq	VGA_TMP_BUFFER(%rip), %rax
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	_Z6memcpyPiS_m
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	_Z6strlenPKc
	movslq	%eax, %rcx
	movq	VGA_MEMORY(%rip), %rsi
	movl	$25, %eax
	subl	-4(%rbp), %eax
	movl	%eax, %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	sall	$4, %eax
	cltq
	leaq	(%rsi,%rax), %rdi
	movq	-24(%rbp), %rax
	movq	%rcx, %rdx
	movq	%rax, %rsi
	call	_Z6memcpyPiS_m
	movl	$25, -28(%rbp)
	movl	-28(%rbp), %eax
.L31:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	_Z6printfPKci, .-_Z6printfPKci
	.globl	PCI_DEVICES
	.data
	.align 8
	.type	PCI_DEVICES, @object
	.size	PCI_DEVICES, 8
PCI_DEVICES:
	.quad	1064960
	.globl	PCI_FOUND_DEVICES
	.align 8
	.type	PCI_FOUND_DEVICES, @object
	.size	PCI_FOUND_DEVICES, 8
PCI_FOUND_DEVICES:
	.quad	1073152
	.section	.rodata
.LC0:
	.string	"h"
	.text
	.globl	C_main
	.type	C_main, @function
C_main:
.LFB9:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	$2, -8(%rbp)
	movl	-8(%rbp), %eax
	leaq	.LC0(%rip), %rdx
	movl	%eax, %esi
	movq	%rdx, %rdi
	call	_Z6printfPKci
#APP
# 14 "BIOS_x86_64_Bootloader/main.cpp" 1
	hlt
# 0 "" 2
#NO_APP
	movq	PCI_FOUND_DEVICES(%rip), %rax
	movl	$512, %esi
	movq	%rax, %rdi
	call	_Z16scan_pci_devicesPji
	movl	%eax, -4(%rbp)
	cmpl	$0, -4(%rbp)
	jle	.L33
#APP
# 20 "BIOS_x86_64_Bootloader/main.cpp" 1
	hlt
# 0 "" 2
#NO_APP
.L33:
#APP
# 22 "BIOS_x86_64_Bootloader/main.cpp" 1
	hlt
# 0 "" 2
#NO_APP
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	C_main, .-C_main
	.ident	"GCC: (GNU) 15.2.1 20260209"
	.section	.note.GNU-stack,"",@progbits
