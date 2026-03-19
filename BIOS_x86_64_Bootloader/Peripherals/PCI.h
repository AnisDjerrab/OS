#include <stdint.h>

#define MAX_PCI_DEVICES 512         // the max of PCI devices supported by this bootloader


// this is the struct responsible for holding information concerning individual PCI devices
typedef struct pci_device {
    uint16_t deviceID;              // identifies a particular device
    uint16_t vendorID;              // identifies the vendor of a device -> ignored for now
    uint16_t status;                // used to record status infos for PCI bus related events -> ignored for now
    uint16_t command;               // wether a device is connected and can respond to PCI cycles (disconnected when 0)
    uint8_t classCode;              // most important information here : this is what lets us identify the peripheral type
    uint8_t subClass;               // peripheral sub-type : for example : storage AHCI or storage FLOPPY
    uint8_t ProgIF;                 // if the peripheral has a programming interface
    uint8_t bist;                   // represents a status and allows control over a device's self test -> ignored for now
    uint8_t headerType;             // identifies the layout of the rest of the header : 0x0 for general device, 0x1 for PCI-to-PCI bridge & 0x2 for PCI-to-CardBus bridge
    uint8_t latencyTimer;           // specifies the latency timer in units of PCI bus clocks
    uint8_t cacheLineSize;          // specifies the devices cache size in 32 bit units. A device can limit the number of cacheline sizes it can support.
};