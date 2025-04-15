#include "../../include/kernel/drivers/kbd_scancode_set.h"
#include "../../include/kernel/drivers/keycodes.h"
#include "../../include/kernel/pic.h"
#include <stdio.h>

// 256 keys can be pressed at one time
#define KBD_BUFFER 256

char scancode_to_ascii(char scancode){
    char release_bounds = 0;
    // printf("Scancode : %d\n", scancode);
    if(scancode < release_bounds){
        return 0;
    }
    return get_ascii(scancode);
}

char scancode_to_keycode(char scancode){
    return get_keycode(scancode);
}

void handle_key(char scancode){

}

void handle_keyboard_interrupt(){
    unsigned char scancode = inb(0x60);
    unsigned char character = scancode_to_ascii(scancode);
    if(character > 0){
        printf("%c", character);
    } 
}