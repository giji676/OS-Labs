#include <stdio.h>
#include <stdlib.h>

struct rectangle {
    int width;
    int height;
};

int findLargestArea(struct rectangle *arr, int n) {
    int largest = 0;
    for (int i = 0; i < n; i++) {
        int area = arr[i].width * arr[i].height;
        if (area > largest) {
            largest = area;
        }
    }
    return largest;
}

int main() {
    int n;
    scanf("%d", &n);
    struct rectangle *rectangles = malloc(sizeof(struct rectangle) * n);
    int w, h;
    for (int i = 0; i < n; i++) {
        scanf("%d %d", &w, &h);
        rectangles[i].width = w;
        rectangles[i].height = h;
    }
    int area = findLargestArea(rectangles, n);
    printf("Largest area=%d\n", area);

    free(rectangles);

    return 0;
}
