#include "../../include/kernel/drivers/kbd_scancode_set.h"
#include "../../include/kernel/drivers/keyboard.h"
#include "../../include/kernel/drivers/keycodes.h"
#include "../../include/kernel/pic.h"
#include <stdio.h>

// Buffer size for the keyboard
#define KBD_BUFFER_SIZE 256

// Queue
static enum normal_keys_e kbd_buffer[KBD_BUFFER_SIZE];
// Queue head
static int buffer_head;
// Queue tail
static int buffer_tail;

// Modifiers
// For now, I'm keeping track of modifiers (shift, ctrl, alt, fn etc) internally
// 0 indicates not pressed
static int shift_state = 0;
static int ctrl_state = 0;
static int alt_state = 0;
static int fn_state = 0;

// Helper functions must be hidden


static char scancode_to_ascii(char scancode){
    // Release bounds indicates if a scancode was a key make or break
    char release_bounds = 0;
    // printf("Scancode : %d\n", scancode);
    // If this is the case, this was a key break
    if(scancode < release_bounds){
        return 0;
    }
    return get_ascii(scancode, shift_state);
}

// Returns the keycode of the key that was pressed
static enum normal_keys_e scancode_to_keycode(char scancode){
    return get_keycode(scancode);
}

// Enqueue a keycode into the buffer
static int enqueue_keycode(enum normal_keys_e keycode){
    int next_head = (buffer_head + 1) % KBD_BUFFER_SIZE;

    // If this is true, our buffer is full
    if(next_head == buffer_tail){
        return -1;
    }

    kbd_buffer[buffer_head] = keycode;
    buffer_head = next_head;
    return 0;
}

// Handle a key input
static void handle_key(char scancode){
    // Check if this is a break (key releaes)
    int is_break = scancode & 0x80;

    // If it is a break event, let's check if it's any of the modifier keys
    if(is_break){
        // Strip off leading break flag
        scancode &= 0x7F;

        // If it's a shift key, we can set the shift state to 0
        if(scancode_to_keycode(scancode) == KEYCODE_LSHIFT || scancode_to_keycode(scancode) == KEYCODE_RSHIFT){
            shift_state = 0;
        }
        // If it's a ctrl key, we can set the ctrl state to 0
        else if(scancode_to_keycode(scancode) == KEYCODE_LCTRL || scancode_to_keycode(scancode) == KEYCODE_RCTRL){
            ctrl_state = 0;
        }

        // Return here, we don't want to push break evets to the queue
        return;
    }
    
    // Handle modifier events
    if(scancode_to_keycode(scancode) == KEYCODE_LSHIFT || scancode_to_keycode(scancode) == KEYCODE_RSHIFT){
        shift_state = 1;
        // Don't push modifier events to queue
        return;
    }
    // If it's a ctrl key, we can set the ctrl state to 0
    else if(scancode_to_keycode(scancode) == KEYCODE_LCTRL || scancode_to_keycode(scancode) == KEYCODE_RCTRL){
        ctrl_state = 1;
        return;
    }
    // Push everything else (non-modifier / non-break)to queue
    if(enqueue_keycode(scancode_to_keycode(scancode)) == -1){
        printf("Keyboard buffer full!\n");
    }
}

// Functions for the public Keyboard API

// Handles the keyboard interrupt
void handle_keyboard_interrupt(){
    // Handle key here
    unsigned char scancode = inb(0x60);
    // This will push to queue or handle modifier state
    handle_key(scancode);

    // Test only! Comment out this part!!!
    // enum normal_keys_e keycode;
    // if(dequeue_keycode(&keycode) == 0){
    //     unsigned char character = keycode_to_ascii(keycode, shift_state);

    //     if(character > 0){
    //         printf("%c", character);
    //     }
    // }

    // Send EOI here (IRQ line 1 = keyboard)
    PIC_send_EOI(1);
}

// This function will only decode keycodes that were queued
char kbd_get_ascii(enum normal_keys_e keycode){
    return keycode_to_ascii(keycode, shift_state);
}

// Dequeue / consume a keycode
int dequeue_keycode(enum normal_keys_e * keycode_out){
    // If this is the case, the buffer is empty
    if(buffer_head == buffer_tail){
        return -1;
    }

    * keycode_out = kbd_buffer[buffer_tail];
    buffer_tail = (buffer_tail + 1) % KBD_BUFFER_SIZE;
    return 0;
}

// API to check if the buffer is empty
int is_kbd_buffer_empty(){
    return buffer_head == buffer_tail;
}