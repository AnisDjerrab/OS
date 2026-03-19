// this is the file reponsible to scan the differents disks and parse the ext2 partition in order to load the kernel
// the function C_main is directly called by the Assembly code and launched in long mode
extern "C" void C_main() {
    // now, we first need to scan all the peripherals to find the different disks connected via USB, SATA or IDE
    // we don't need to parse the AML tables just yet -- the operating system will do it later on
    asm("hlt");
}