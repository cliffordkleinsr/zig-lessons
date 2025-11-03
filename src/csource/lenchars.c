#include <stdio.h>
#include <string.h>
int main() {
    char array []= "An example of string in C";
    // int index = 0;
    // while (1) {
    //     if (array[index] == '\0') {
    //         break;
    //     }
    //     index++;
    // }
    // printf("Number of elements in the array: %d\n", index);
    printf("Number of elements in the array: %zu\n", strlen(array));
}