#include <string.h>

char *strcpy(char *dest, const char *src){
    char *original = dest;
    while((*dest++ = *src++));
    return original;
}