#include <stdio.h>
#include <stdlib.h>

#define CHAR ']'

char* buildString(char* s, char c, int n) {
    int s_len = 0;
    while (s[s_len] != '\0') {
        s_len++;
    }

    char *string = malloc(sizeof(char) * (n + s_len));
    for (int i = 0; i < s_len; i++) {
        string[i] = s[i];
    }

    for (int i = 0; i < n; i++) {
        string[s_len+i] = c;
    }
    return string;
}

int main() {
    char c;
    int n = 0;
    while ((c = getchar()) != '\n') {
        if (c >= '0' && c <= '9') {
            n = n * 10 + (c - '0');
        }
    }

    char *new_string = buildString("CS2850", CHAR, n);
    printf("%s\n", new_string);
    free(new_string);
    return 0;
}
