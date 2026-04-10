// this is the file reponsible to scan the differents disks and parse the ext2 partition in order to load the kernel
// the function C_main is directly called by the Assembly code and launched in long mode

#include "Peripherals/PCI.h"
#include "internal_API/standard_functions_def.h"
#include <stdint.h>

#define MAX_PCI_DEVICES 512                     // the max of PCI devices supported by this bootloader
pci_device* PCI_DEVICES = (pci_device*)0x104000;// we'll write all the PCI devices metadata right in this array -- hard coded adress right after the VGA memory
uint32_t* PCI_FOUND_DEVICES = (uint32_t*)(0x104000 + sizeof(pci_device)* MAX_PCI_DEVICES);     // and we'll store the device IDs in this array right here. as always, hard coded adress -- no malloc or smart memory management yet!

char* tmp_buffer = (char*)0x3000;
int64_t* line = (int64_t*)0x2992;


extern "C" void C_main() {
    setCursorPos(0);
    char converted_number[9];
    *line = 1;
    *line = printf("succesfully entered the bootloader C kernel...", *line);
    // now, we first need to scan all the peripherals to find the different disks connected via USB, SATA or IDE
    // we don't need to parse the AML tables just yet -- we can scan the PCI devices directly
    // first : enumerate the PCI devices
    auto number_of_found_pci_devices = scan_pci_devices(PCI_FOUND_DEVICES, MAX_PCI_DEVICES);   // now, the number of found pci devices is contained in this variable. we'll use it later on.
    char* table[] = {(char*)"found ", itoa(number_of_found_pci_devices, converted_number, 10), (char*)" pci devices..."};
    *line = printf(merge(tmp_buffer, 3, table), *line);
    // now, we need to fill the PCI_DEVICES array with the device metadata
    populate_pci_devices_metadata(PCI_FOUND_DEVICES, number_of_found_pci_devices, PCI_DEVICES);
    struct memory_space_map_virtual memory_struct;
    memory_struct.flat_strct.real_addr = 0x200000;                // the used ram amount
    memory_struct.flat_strct.number_of_pages = 3;
    // these page addresses are defined in the Assembly early_boot.s file
    memory_struct.flat_strct.PML4_table_index = 0x13000;
    memory_struct.flat_strct.PDPT_table_index = 0x12000;
    memory_struct.flat_strct.PDT_table_index = 0x11000;
    memory_struct.flat_strct.PT_table_index = 0x10000;
    memory_struct.flat_strct.used_space = 0;
    memory_space_map_flat* ptr1 = &memory_struct.flat_strct;
    asm("hlt");
    map_memory_space_flat(ptr1);
    volatile char* dangerous_ptr = (char*)0x200004;
    dangerous_ptr[0] = '\0';
    asm("hlt");
}
