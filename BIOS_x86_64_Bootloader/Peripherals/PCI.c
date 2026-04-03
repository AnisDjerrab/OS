#include <cstdint>
#include <stdint.h>
#include "PCI.h"
#include "../internal_API/standard_functions_def.h"

static inline void outl(uint16_t port, uint32_t value) {
    asm volatile("outl %0, %w1" : : "a"(value), "Nd"(port));            // output IO
}
static inline uint32_t inl(uint16_t port) {
    uint32_t value;
    asm volatile("inl %w1, %0" : "=a"(value) : "Nd"(port));             // input IO
    return value;
}

static inline uint32_t pci_read32(uint8_t bus, uint8_t slot, uint8_t func, uint8_t offset) {
    uint32_t addr = (1u   << 31)
                  | (bus  << 16)
                  | (slot << 11)
                  | (func <<  8)
                  | (offset & 0xFC);
    outl(0xCF8, addr);
    return inl(0xCFC);
}

int scan_pci_devices(uint32_t* device_IDs_array, int MAX_PCI_DEVICES) {
    int number_of_pci_devices = 0;                                  // if the max number of devices is reached, exit
    int ptr = 0;
    for (uint16_t bus = 0; bus < 256; bus++) {
        for (uint8_t slot = 0; slot < 32; slot++) {
            for (uint8_t func = 0; func < 8; func++) {
                // first check if the max number of devices was reached
                if (number_of_pci_devices >= MAX_PCI_DEVICES) {
                    bus = 512;                                         // to break from the main loop

                    break;                                             // exit the third loop
                }
                // try out with func = 0
                uint32_t value = pci_read32(bus, slot, func, 0x00);
                // now, check if the device exists or not
                if ((value & 0xFFFF) == 0xFFFF) {
                    continue;                                          // the pci device does not exist
                }
                // the pci device exists.
                number_of_pci_devices++;
                device_IDs_array[ptr] = ((uint32_t)bus << 16) | ((uint32_t)slot << 8) | func;
            }
        }
    }
    return number_of_pci_devices;
}

void populate_pci_devices_metadata(uint32_t* device_IDs_array, int number_of_pci_devices, pci_device* pci_devices_metadata) {
    int number_of_ahci_devices = 0;
    for (int i = 0; i < number_of_pci_devices; i++) {
        // we extract the bus, slot and function numbers from the device ID
        uint8_t bus = (device_IDs_array[i] >> 16);
        uint8_t slot = (device_IDs_array[i] >> 8) & 0xFF;
        uint8_t func = device_IDs_array[i] & 0xFF;
        // now, these header fields are guarenteed to be present by the PCI spec
        uint32_t dWord1 = pci_read32(bus, slot, func, 0x00);
        pci_devices_metadata[i].vendorID = dWord1;
        pci_devices_metadata[i].deviceID = (dWord1 >> 16);
        uint32_t dWord2 = pci_read32(bus, slot, func, 0x04);
        pci_devices_metadata[i].command = dWord2;
        pci_devices_metadata[i].status = (dWord2 >> 16);
        uint32_t dWord3 = pci_read32(bus, slot, func, 0x08);
        pci_devices_metadata[i].ProgIF = (dWord2 >> 8);
        pci_devices_metadata[i].subClass = (dWord3 >> 16);
        pci_devices_metadata[i].classCode = (dWord3 >> 24);
        uint32_t dWord4 = pci_read32(bus, slot, func, 0x0C);
        pci_devices_metadata[i].cacheLineSize = dWord4;
        pci_devices_metadata[i].latencyTimer = (dWord4 >> 8);
        pci_devices_metadata[i].headerType = (dWord4 >> 16);
        pci_devices_metadata[i].bist = (dWord4 >> 24);
        // however, ABAR is optional and may not be present for all devices
        // we need to check if the PCI device is specifically an AHCI device before reading the BAR5 field
        // to check fot AHCI, we need to check that class code is 0x01 (storage) and subclass is 0x06 (ATA controller) and ProgIF is 0x01 (AHCI)
        // for now, we put a placeholder value of 0xFFFFFFFF
        pci_devices_metadata[i].ABAR = 0xFFFFFFFF;
        if (pci_devices_metadata[i].classCode == 0x01 && pci_devices_metadata[i].subClass == 0x06 && pci_devices_metadata[i].ProgIF == 0x01) {
            pci_devices_metadata[i].ABAR = pci_read32(bus, slot, func, 0x24);
            number_of_ahci_devices++;
        }
        char converted_number[9];
        *line = printf(itoa(pci_devices_metadata[i].classCode, converted_number, 16), *line);
    }
    char converted_number[9];
    char* table[] = {(char*)"found ", itoa(number_of_ahci_devices, converted_number, 10), (char*)" AHCI devices..."};
    *line = printf(merge(tmp_buffer, 3, table), *line);
}
