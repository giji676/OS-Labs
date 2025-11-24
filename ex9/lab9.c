#include <stdio.h>
#include <stdlib.h>

struct node {
    char letter;
    struct node *next;
};

void reverse_list(struct node **head) {
    struct node *prev = NULL;
    struct node *curr = *head;
    struct node *next = NULL;

    while (curr) {
        next = curr->next;
        curr->next = prev;
        prev = curr;
        curr = next;
    }
    *head = prev;
}

void print_list(struct node *head) {
    while (head) {
        printf("%c ", head->letter);
        head = head->next;
    }
}

void free_structs(struct node *head) {
    while (head) {
        struct node *next = head->next;
        free(head);
        head = next;
    }
}

int main() {
    struct node *head = NULL;
    char c;
    while ((c = getchar()) != '\n') {
        struct node *new = malloc(sizeof(struct node));
        new->letter = c;
        new->next = head;
        head = new;
    }

    reverse_list(&head);
    print_list(head);

    free_structs(head);

    return 0;
}
