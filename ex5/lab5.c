#include <stdio.h>

#define MAXLINES 3
#define MAXLENGTH 24

long unsigned int parseString(char *s) {
    long unsigned int out = 0;
    for (int i = 0; s[i] != '\0'; i++) {
        // printf("%c", s[i]);
        if (s[i] >= '0' && s[i] <= '9') {
            out = out * 10 + (s[i] - '0');
        }
    }
    // printf("\n");
    return out;
}

int main() {
    double average;

    FILE *file = fopen("input.txt", "r");
    if (file == NULL) {
        printf("Failed to open file\n");
        return 1;
    }

    char line[MAXLENGTH + 2]; // +2 for terminator
    int line_count = 0;
    long unsigned int sum = 0;

    while (line_count < MAXLINES && fgets(line, sizeof(line), file) != NULL) {
        if (line[MAXLENGTH] != '\0' && line[MAXLENGTH] != '\n') {
            line[MAXLENGTH] = '\0';

            // Discard the rest of the line
            int c;
            while ((c = fgetc(file)) != '\n' && c != EOF);
        }

        for (int i = 0; line[i] != '\0'; i++) {
            if (line[i] == '\n') {
                line[i] = '\0';
                break;
            }
        }
        printf("%s\n", line);
        sum += parseString(line);
        line_count++;
    }
    fclose(file);
    average = (double)sum / line_count;
    printf("average=%f\n", average);
    return 0;
}
