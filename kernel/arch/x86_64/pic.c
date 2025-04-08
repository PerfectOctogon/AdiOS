#include "../../include/kernel/pic.h"
#include <stdint.h>

void outb(uint16_t port, uint8_t byte) {
    asm volatile (
        "outb %0, %1"
        :
        : "a"(byte), "Nd"(port)
    );
}

uint8_t inb(uint16_t port) {
    uint8_t value;
    asm volatile (
        "inb %1, %0"
        : "=a"(value)
        : "Nd"(port)
    );
    return value;
}

void io_wait() {
    // This is a common technique to create a small delay.
    // Writing to an unused port (0x80) which is historically used for delays
    asm volatile (
        "outb %%al, $0x80"
        :
        : "a"(0)
    );
}


void PIC_send_EOI(uint8_t irq){
    // If the request is in the slave PIC
    if(irq >= 8){
        outb(SLAVE_COMMAND, PIC_EOI);
    }
    // Send EOI to master
    outb(MASTER_COMMAND, PIC_EOI);
}

void PIC_initialize(int master_offset, int slave_offset){
    // Start initialization and let the Master PIC know that there is a ICW4
    outb(MASTER_COMMAND, ICW1_INIT | ICW1_ICW4);
    // We need to wait for the IO operation to finish before we send more commands
    io_wait();
    // Start initialization on the Slave PIC and tell it that there is an ICW4
    outb(SLAVE_COMMAND, ICW1_INIT | ICW1_ICW4);
    io_wait();
    // Set the Master PIC vector offset
    outb(MASTER_DATA, master_offset);
    io_wait();
    // Set the Slave PIC vector offset
    outb(SLAVE_DATA, slave_offset);
    io_wait();
    // Tell the master PIC that there is a slave PIC at IRQ channel 2
    outb(MASTER_DATA, 4);
    io_wait();
    // Slave cascade nature
    outb(SLAVE_DATA, 2);
    io_wait();

    // Tell master and slave we are using 8086 mode
    outb(MASTER_DATA, ICW4_8086);
    io_wait();
    outb(SLAVE_DATA, ICW4_8086);
    io_wait();

    // Unmask master and slave
    outb(MASTER_DATA, 0);
    outb(SLAVE_DATA, 0);
}

void PIC_disable(){
    // Disable master and slave ports
    outb(MASTER_DATA, 0xff);
    outb(SLAVE_DATA, 0xff);
}

void PIC_mask_irq_channel(uint8_t irq_channel){
    // Master or slave port
    uint16_t port;
    // This is the value we will write back to the port
    uint8_t value;

    // If this is the case, then we need to mask something in the master port
    if(irq_channel < 8){
        port = MASTER_DATA;
    }
    // Mask something in the slave port
    else{
        port = SLAVE_DATA;
        // offset
        irq_channel -= 8;
    }

    // Get value from the port
    value = inb(port);
    // Set bit to 1 to mask
    value |= (1 << irq_channel);
    // Write back to the port
    outb(port, value);
}

void PIC_unmask_irq_channel(uint8_t irq_channel){
    // Master or slave port
    uint16_t port;
    // This is the value we will write back to the port
    uint8_t value;

    // If this is the case, then we need to unmask something in the master port
    if(irq_channel < 8){
        port = MASTER_DATA;
    }
    // Unask something in the slave port
    else{
        port = SLAVE_DATA;
        // offset
        irq_channel -= 8;
    }

    // Get value from the port
    value = inb(port);
    // Set bit to 0 to unmask
    value &= ~(1 << irq_channel);
    // Write back to the port
    outb(port, value);
}

// Helper function to get the irq registers
static uint16_t PIC_get_irq(int ocw3){
    outb(MASTER_COMMAND, ocw3);
    outb(SLAVE_COMMAND, ocw3);

    return(inb(SLAVE_COMMAND) << 8) | inb(MASTER_COMMAND);
}

uint16_t PIC_get_irr(){
    return PIC_get_irq(READ_IRR);
}

uint16_t PIC_get_isr(){
    return PIC_get_irq(READ_ISR);
}