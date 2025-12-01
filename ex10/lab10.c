#include <stdio.h>
#include <stdlib.h>

#define MAX 9

struct tree_node {
    int val;
    struct tree_node *left;
    struct tree_node *right;
};

struct list_node {
    int val;
    struct list_node *next;
};

void insert_tree_node(struct tree_node **root, int n);
void load_and_free(struct tree_node **root, struct list_node **head);
void print_list(struct list_node *head);
void free_list(struct list_node *head);

int main() {
    struct tree_node *root = NULL;
    struct list_node *head = NULL;

    FILE *inp_fptr;
    inp_fptr = fopen("input.txt", "r");

    int i;
    int line_count = 0;
    while (1) {
        if (line_count == MAX) break;
        int result = fscanf(inp_fptr, "%i", &i);
        if (result == EOF) break;
        line_count++;

        insert_tree_node(&root, i);
    }
    load_and_free(&root, &head);
    print_list(head);
    free_list(head);

    fclose(inp_fptr);
    return 0;
}

void load_and_free(struct tree_node **root, struct list_node **head) {
    if (*root == NULL) return;

    load_and_free(&(*root)->right, head);

    struct list_node *new_node = malloc(sizeof(struct list_node));
    new_node->val = (*root)->val;
    new_node->next = NULL;

    while (*head != NULL)
        head = &((*head)->next);

    *head = new_node;

    load_and_free(&(*root)->left, head);
    free(*root);
    *root = NULL;
}

void insert_tree_node(struct tree_node **root, int n) {
    if (!(*root)) {
        *root = malloc(sizeof(struct tree_node));
        (*root)->val = n;
        (*root)->left = NULL;
        (*root)->right = NULL;
        return;
    }

    if (n < (*root)->val) insert_tree_node(&((*root)->left), n);
    else insert_tree_node(&((*root)->right), n);
}

void print_list(struct list_node *head) {
    while (head) {
        printf("%d ", head->val);
        head = head->next;
    }
}

void free_list(struct list_node *head) {
    struct list_node *tmp;
    while (head != NULL) {
        tmp = head->next;
        free(head);
        head = tmp;
    }
}
