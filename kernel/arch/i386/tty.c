#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include <kernel/tty.h>
#include "vga.h"

// Width of the screen
static const size_t VGA_WIDTH = 80;
// Height of the screen
static const size_t VGA_HEIGHT = 25;
// Where the VGA memory starts
static uint16_t* const VGA_MEMORY = (uint16_t*) 0xB8000;

// Current terminal row, column and color
static size_t terminal_row;
static size_t terminal_column;
static uint8_t terminal_color;
// Current pointer to the VGA buffer in memory
static uint16_t* terminal_buffer;

// Initialize the terminal
void terminal_initialize(void){
    terminal_row = 0;
    terminal_column = 0;
    // Terminal color is set to light green on black, can change this any time
    terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK);
    // Start pointing to the beginning of VGA memory
    terminal_buffer = VGA_MEMORY;

    //Go over and set all the characters in the buffer to spaces
    for(size_t y = 0; y < VGA_HEIGHT; y++){
        for(size_t x = 0; x < VGA_WIDTH; x++){
            const size_t index = y * VGA_HEIGHT + VGA_WIDTH + x;
            terminal_buffer[index] = vga_entry(' ', terminal_color);
        }
    }
}

// Change the color of the terminal
void terminal_setcolor(enum vga_color foreground, enum vga_color background){
    terminal_color = vga_entry_color(foreground, background);
}

// Put a character of color at (x,y) of the terminal buffer
void terminal_putentryat(unsigned char character, uint8_t character_color, size_t x, size_t y){
    const size_t index = y * VGA_WIDTH + x;
    terminal_buffer[index] = vga_entry(character, character_color);
}

// Scroll on the terminal
void terminal_scroll(int line){
    uint16_t * video_memory = VGA_MEMORY;

    // Move each row up by one line
    for(int y = line; y < VGA_HEIGHT - 1; y++){
        for(int x = 0; x < VGA_WIDTH; x++){
            video_memory[y * VGA_WIDTH + x] = video_memory[(y + 1) * VGA_WIDTH + x];
        }
    }

    //We might want to delete the last line, but I'll leave it commented out for now
    //terminal_delete_last_line();
}

void terminal_delete_last_line(){
    uint16_t * video_memory = VGA_MEMORY;

    // Clear the last line
    for(int x = 0; x < VGA_WIDTH; x++){
        video_memory[(VGA_HEIGHT - 1) * VGA_WIDTH + x] = vga_entry(' ', terminal_color);
    }
}

// Write a character to the terminal
void terminal_putchar(char c){
    int line;
    unsigned char character = c;

    if (c == '\n') {
        terminal_column = 0;
        if (++terminal_row == VGA_HEIGHT) {
            terminal_scroll(1);
            terminal_delete_last_line();
            terminal_row = VGA_HEIGHT - 1;
        }
        return;
    }

    // Write the character at the current cursor
    terminal_putentryat(character, terminal_color, terminal_column, terminal_row);

    // If we went over the width of the terminal, then go down a line
    if(++terminal_column == VGA_WIDTH){
        terminal_column = 0;
        // If we went over the height of the terminal, then scroll up
        if(++terminal_row == VGA_HEIGHT){
            for(line = 1; line < VGA_HEIGHT; line++){
                terminal_scroll(line);
            }
            // Delete the last line of the terminal so we can write more stuff there
            terminal_delete_last_line();
            terminal_row = VGA_HEIGHT - 1;
        }
    }
}

// Use to write some data of size to the terminal in ASCII rep
void terminal_write(const char * data, size_t size){
    // Write some characters to the VGA buffer
    for(size_t i = 0; i < size; i++){
        terminal_putchar(data[i]);
        
    }
}

// Use to write a string to the terminal
void terminal_writestring(const char * string){
    terminal_write(string, strlen(string));
}