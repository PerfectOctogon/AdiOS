#ifndef __KBD__
#define __KBD__

// source : https://wiki.osdev.org/PS/2_Keyboard

// Returns the ascii value of the scancode
#include "keycodes.h"
char scancode_to_ascii(char scancode);

// Decode keycode that was pressed
enum normal_keys_e scancode_to_keycode(char scancode);

// Handle a key that was pressed
void handle_key(char scancode);

// Handle the keyboard interrupt
void handle_keyboard_interrupt();

// Enqueue a keycode
int enqueue_keycode(enum normal_keys_e keycode);

// Public keycode consume API
int dequeue_keycode(enum normal_keys_e * keycode_out);

// Public API to check if the buffer is empty before dequeing
int is_kbd_buffer_empty();
#endif