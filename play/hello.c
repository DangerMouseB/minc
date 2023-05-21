#include <stdio.h>

// OPEN: add static keyword
void * f;
int (*p) (void *, const char *, ...);
int (*p2) (void *, const char *, ...);

int main() {
    p = fprintf;
    f = stdout;
    p2 = p;
    p2(f, "hello\n");
}

// OPEN: to test
// char (*(*x())[5])()  - declare x as function returning pointer to array 5 of pointer to function returning char
// int *p(void *, const char *) - declare p as function (pointer to void, pointer to const char) returning pointer to int
// int *(p)(void *, const char *) - declare p as function (pointer to void, pointer to const char) returning pointer to int
// int (*p)(void *, const char *) - declare p as pointer to function (pointer to void, pointer to const char) returning int

