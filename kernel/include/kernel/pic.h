/* Source : https://wiki.osdev.org/8259_PIC */
#include <cstdint>
#include <stdint.h>
#include <sys/types.h>

// Define master and slave PIC offsets

#define MASTER  0x20
#define SLAVE   0xA0

// Command ports
#define MASTER_COMMAND MASTER
#define SLAVE_COMMAND SLAVE

// Data ports
#define MASTER_DATA (MASTER + 1)
#define SLAVE_DATA (SLAVE + 1)

// End of interrupt command code
#define PIC_EOI 0x20

// Commands to read status of the PIC
#define READ_IRR    0x0a // operation command word to read the IRR(interrupt request register) (pending interrupts)
#define READ_ISR    0x0b // OCW3 to read the ISR(in-service register) to see which interrupt is being processed

// Initialization command word 1
#define ICW1_ICW4   0x01 // Indicates that there is an initialization command word 4
#define ICW1_SINGLE 0x02    // Doesn't cascade if set
#define ICW1_INTERVAL4  0x04    // If set, interrupt vectors(the IRQ's) are spaces 4 bytes apart
#define ICW1_LEVEL  0x08 // Level-triggered mode, instead of default edge=triggered mode
#define ICW1_INIT   0x10 // Required! tells the PIC to begin initialization

// Initialization command word 4
#define ICW4_8086   0x01 // Sets the PIC to 8086 mode (default)
#define ICW4_AUTO_EOI   0x02 // Enables automatic EOI
#define ICW4_BUF_SLAVE  0x08 // Enables buffered mode for the slave PIC
#define ICW4_BUF_MASTER 0x0C // Enables buffered mode for the master PIC
#define ICW4_SFNM   0x10 // Enables Special Fully Nested Mode (SFNM) (used in large systems)

// Sends an end of interrupt command to the PIC
// Tells the PIC that the interrupt(irq) has been handled
void PIC_send_EOI(uint8_t irq);

// Remap/initialize the PIC
void PIC_initialize(int master_offset, int slave_offset);

// Disable the PIC
void PIC_disable();

// Masking an irq channel
void PIC_mask_irq_channel(uint8_t irq_channel);

// Unmasking an irq channel
void PIC_unmask_irq_channel(uint8_t irq_channel);

// Get the value inside the IRR
uint16_t PIC_get_irr();

// Get the value inside ISR
uint16_t PIC_get_isr();

// Send byte to command port
uint16_t outb(uint8_t port, u_char byte);

// Receive byte from port
char inb(u_char port);

// Waits for an IO operation to finish
void io_wait();