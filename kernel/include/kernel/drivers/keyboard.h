#ifndef __KBD__
#define __KBD__

// source : https://wiki.osdev.org/PS/2_Keyboard

// Returns the ascii value of the scancode
char scancode_to_ascii(char scancode);

// Decode keycode that was pressed
char scancode_to_keycode(char scancode);

// Handle a key that was pressed
char handle_key(char scancode);

// Handle the keyboard interrupt
char handle_keyboard_interrupt();
#endif