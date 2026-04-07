all: qemu

bootloader := BIOS_x86_64_Bootloader
bootloader_flags := -ffreestanding -O2 -mno-red-zone -fno-exceptions -fno-rtti -fno-stack-protector -fno-pic -m64

UNAME := $(shell uname)

ifeq ($(UNAME), Darwin)
	AS = x86_64-elf-as
	LD = x86_64-elf-ld
	CC = x86_64-elf-gcc
	CXX = x86_64-elf-g++
	DD = gdd
	DISPLAY := -display cocoa
else ifeq ($(UNAME), Linux)
	AS = as
	LD = ld
	CC = gcc
	CXX = g++
	DD = dd
	DISPLAY := -display gtk
else
	AS = x86_64-elf-as
	LD = x86_64-elf-ld
	CC = x86_64-elf-gcc
	CXX = x86_64-elf-g++
	DD = dd
	DISPLAY := -display sdl
endif

REQUIRED_TOOLS := $(AS) $(LD) $(CXX) $(DD) qemu-system-x86_64
check_tools:
	@for tool in $(REQUIRED_TOOLS); do \
		if ! command -v $$tool >/dev/null 2>&1; then \
			echo "error : missing tool: $$tool. cannot proceed with compilation."; \
			exit 1; \
		fi; \
	done

bootloader: check_tools
	$(AS) "${bootloader}/bootloader.s" -o "${bootloader}/bootloader.o"
	$(LD) -T "${bootloader}"/bootloader_linker_script.ld "${bootloader}/bootloader.o" -o "${bootloader}/bootloader.bin"
	$(AS) "${bootloader}/early_boot.s" -o "${bootloader}/early_boot.o"
	$(AS) "${bootloader}"/internal_API/memory_mapping.s -o "${bootloader}"/internal_API/memory_mapping.o
	$(CXX) $(bootloader_flags) -c -o "${bootloader}"/internal_API/standard_functions.o "${bootloader}"/internal_API/standard_functions.cpp
	$(CXX) $(bootloader_flags) -c -o "${bootloader}"/main.o "${bootloader}"/main.cpp
	$(CXX) $(bootloader_flags) -c -o "${bootloader}"/Peripherals/PCI.o "${bootloader}"/Peripherals/PCI.c
	$(LD) -r "${bootloader}"/main.o "${bootloader}"/internal_API/standard_functions.o "${bootloader}"/Peripherals/PCI.o "${bootloader}"/internal_API/memory_mapping.o -o "${bootloader}"/c_combined.o
	$(LD) -T "${bootloader}"/main_linker_script.ld "${bootloader}"/early_boot.o "${bootloader}"/c_combined.o --oformat binary -o "${bootloader}"/early_boot.bin

bootdisk: bootloader
	$(DD) if=/dev/zero of=disk.img bs=512 count=2880
	$(DD) conv=notrunc if="${bootloader}"/bootloader.bin of=disk.img bs=512 count=1 seek=0
	$(DD) conv=notrunc if="${bootloader}"/early_boot.bin of=disk.img bs=512 count=8 seek=1

qemu: bootdisk
	qemu-system-x86_64 -vga cirrus $(DISPLAY) -machine pc -m 5G -serial stdio -fda disk.img -no-reboot -d int,guest_errors,cpu_reset,mmu -device ich9-ahci,id=ahci

debug: bootdisk
	qemu-system-x86_64 -vga cirrus $(DISPLAY) -machine pc -m 5G -fda disk.img -device ich9-ahci,id=ahci -gdb tcp::26000 -S &
	gdb -ex "target remote localhost:26000"
