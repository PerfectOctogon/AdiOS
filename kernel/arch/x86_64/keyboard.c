#include "../../include/kernel/drivers/kbd_scancode_set.h"

char scancode_to_keycode(char scancode){
    return get_ascii(scancode);
};