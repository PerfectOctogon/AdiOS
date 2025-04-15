#ifndef __KBD_SCANCODE__
#define __KBD_SCANCODE__
#include "keycodes.h"

// Source : https://wiki.osdev.org/PS/2_Keyboard

char get_ascii(char scancode, int shift_state);

enum normal_keys_e get_keycode(char scancode);

char keycode_to_ascii(enum normal_keys_e keycode, int shift_state);
#endif