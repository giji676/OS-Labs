#include <stdio.h>

#define MAXLINES 6
#define LETTER 'g'

int main() {
    FILE *inp_fptr;
    inp_fptr = fopen("input.txt", "r");
    FILE *out_fptr;
    out_fptr = fopen("output.txt", "w");

    char c;
    int g_count = 0;
    int line_count = 0;

    while (1) {
        if (line_count == MAXLINES) { break; }
        int result = fscanf(inp_fptr, "%c", &c);
        if (result == EOF) break;
        if (c == 'g' || c == 'G') {
            g_count++;
        } else if (c == '\n') {
            fprintf(out_fptr, "%d\n", g_count);
            g_count = 0;
            line_count++;
        }
    }

    fclose(inp_fptr);
    fclose(out_fptr);
    return 0;
}
