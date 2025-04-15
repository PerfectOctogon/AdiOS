#include "../../include/kernel/drivers/kbd_scancode_set.h"
#include "../../include/kernel/drivers/keycodes.h"

char scancode_set_one[256]={
    0,
    KEYCODE_ESC,
    KEYCODE_1,          // 02
    KEYCODE_2,          // 03
    KEYCODE_3,          // 04
    KEYCODE_4,          // 05
    KEYCODE_5,          // 06
    KEYCODE_6,          // 07
    KEYCODE_7,          // 08
    KEYCODE_8,          // 09
    KEYCODE_9,          // 0A
    KEYCODE_0,          // 0B
    KEYCODE_MINUS,      // 0C
    KEYCODE_EQUAL,      // 0D
    KEYCODE_BACKSPACE,  // 0E
    KEYCODE_TAB,        // 0F
    KEYCODE_Q,          // 10
    KEYCODE_W,          // 11
    KEYCODE_E,          // 12
    KEYCODE_R,          // 13
    KEYCODE_T,          // 14
    KEYCODE_Y,          // 15
    KEYCODE_U,          // 16
    KEYCODE_I,          // 17
    KEYCODE_O,          // 18
    KEYCODE_P,          // 19
    KEYCODE_LBRACKET,   // 1A
    KEYCODE_RBRACKET,   // 1B
    KEYCODE_ENTER,      // 1C
    KEYCODE_LCTRL,      // 1D
    KEYCODE_A,          // 1E
    KEYCODE_S,          // 1F
    KEYCODE_D,          // 20
    KEYCODE_F,          // 21
    KEYCODE_G,          // 22
    KEYCODE_H,          // 23
    KEYCODE_J,          // 24
    KEYCODE_K,          // 25
    KEYCODE_L,          // 26
    KEYCODE_SEMICOLON,  // 27
    KEYCODE_QUOTE,      // 28
    KEYCODE_BACKTICK,   // 29
    KEYCODE_LSHIFT,     // 2A
    KEYCODE_BACKSLASH,  // 2B
    KEYCODE_Z,          // 2C
    KEYCODE_X,          // 2D
    KEYCODE_C,          // 2E
    KEYCODE_V,          // 2F
    KEYCODE_B,          // 30
    KEYCODE_N,          // 31
    KEYCODE_M,          // 32
    KEYCODE_COMMA,      // 33
    KEYCODE_DOT,        // 34
    KEYCODE_SLASH,      // 35
    KEYCODE_RSHIFT,     // 36
    KEYCODE_KP_MULT,    // 37
    KEYCODE_LALT,       // 38
    KEYCODE_SPACE,      // 39
    KEYCODE_CAPS,       // 3A
    KEYCODE_F1,         // 3B
    KEYCODE_F2,         // 3C
    KEYCODE_F3,         // 3D
    KEYCODE_F4,         // 3E
    KEYCODE_F5,         // 3F
    KEYCODE_F6,         // 40
    KEYCODE_F7,         // 41
    KEYCODE_F8,         // 42
    KEYCODE_F9,         // 43
    KEYCODE_F10,        // 44
    KEYCODE_NUM,        // 45
    KEYCODE_SCROLL,     // 46
    KEYCODE_KP_7,       // 47
    KEYCODE_KP_8,       // 48
    KEYCODE_KP_9,       // 49
    KEYCODE_KP_MINUS,   // 4A
    KEYCODE_KP_4,       // 4B
    KEYCODE_KP_5,       // 4C
    KEYCODE_KP_6,       // 4D
    KEYCODE_KP_PLUS,    // 4E
    KEYCODE_KP_1,       // 4F
    KEYCODE_KP_2,       // 50
    KEYCODE_KP_3,       // 51
    KEYCODE_KP_0,       // 52
    KEYCODE_KP_DOT,     // 53
    0,
    0,
    0,
    KEYCODE_F11,        // 57
    KEYCODE_F12,        // 58
    0,
};

char keycodes[] =
{
      0, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2',
    '3', '4', '5', '6', '7', '8', '9', '`', '-', '=', '\\', '\b', ' ', '\t',
    '\n', '\033', '[', ']', ';', '\'', ',', '.', '/',
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,       // caps, shift, ctrl, alt, gui, apps
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', // function keys
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   // prntscrn, scroll, ...
    '/', '*', '\n',                      // keypad
    '7', '8', '9', '-', '4', '5', '6', '+', '1', '2', '3', '0', '.',    // keypad
};


char shift_keycodes[] =
{
      0, 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
    'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', ')', '!', '@',
    '#', '$', '%', '^', '&', '*', '(', '~', '_', '+', '|', '\b', ' ', '\t',
    '\n', '\033', '{', '}', ':', '"', '<', '>', '?',
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,       // caps, shift, ctrl, alt, gui, apps
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', // function keys
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,   // prntscrn, scroll, ...
    '/', '*', '\n',                      // keypad
    '7', '8', '9', '-', '4', '5', '6', '+', '1', '2', '3', '0', '.',    // keypad
};

enum normal_keys_e get_keycode(char scancode){
    return scancode_set_one[scancode];
}

char get_ascii(char scancode){
    return keycodes[scancode_set_one[scancode]];
}
