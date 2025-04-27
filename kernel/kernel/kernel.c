#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/kernel/tty.h"
#include "../include/kernel/idt.h"
#include "../include/kernel/pic.h"

int word_game();
void help();

void kernel_main(void){
    terminal_initialize();
    printf("Welcome to the 64-bit AdiOS kernel\n");
    printf("Initializing PIC...\n");
    // Initialize PIC
    PIC_initialize(0x20, 0x28);
    // Masking channel 0 so we don't trigger system timer interrupt
    PIC_mask_irq_channel(0);
    printf("Initializing Interrupt Descriptor Table...\n");
    // Initialize the IDT
    idt_full_initialize();
    char * user_entry = (char *)malloc(25);
    printf("Use help for available commands");

    while(1){
        printf("Enter command : \n");
        scanf("%s", user_entry);
        if(!strcmp(user_entry, "word-game")){
            word_game();
        }
        else if(!strcmp(user_entry, "help")){
            help();
        }
    };
}

void help(){
    printf("Available commands:\n1) word-game\n2) help\n");
}
int word_game(){
    const char *secret_word = "apple";
    int max_attempts = 5;

    printf("=== Welcome to Guess The Word! ===\n");
    printf("You have %d attempts to guess the secret word.\n", max_attempts);

    // Allocate memory for user input
    char *guess = (char *)malloc(100 * sizeof(char));
    if (guess == NULL) {
        printf("Memory allocation failed!\n");
        return 1;
    }

    for (int attempt = 1; attempt <= max_attempts; attempt++) {
        printf("Attempt %d: Enter your guess: ", attempt);
        scanf("%99s", guess); // Read up to 99 characters

        if (strcmp(guess, secret_word) == 0) {
            printf("Congratulations! You guessed the word correctly!\n");
            free(guess);
            return 0;
        } else {
            printf("Wrong guess. Try again!\n");
        }
    }

    printf("Sorry, you're out of attempts. The word was: %s\n", secret_word);

    // Free allocated memory
    free(guess);

    return 0;
}