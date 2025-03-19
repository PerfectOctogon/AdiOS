#include <stdio.h>
#include "../include/kernel/tty.h"

void kernel_main(void){
    while(1);
    terminal_initialize();
    printf("Welcome to the 64-bit adios kernel\n");
}