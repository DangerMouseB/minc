#include <stdio.h>

// OPEN: add static keyword
FILE * f;
int (*p) (void *, const char *, ...);

char lf() {return 10;}

int main() {
    int i;
    i = 1;
    int (*p2) (void *, const char *, ...);
    p = fprintf;
    f = stdout;
    p2 = p;
    p2(f, "hello %d%c", i, lf());
}

// OPEN: to test
// char (*(*x())[5])()  - declare x as function returning pointer to array 5 of pointer to function returning char
// int *p(void *, const char *) - declare p as function (pointer to void, pointer to const char) returning pointer to int
// int *(p)(void *, const char *) - declare p as function (pointer to void, pointer to const char) returning pointer to int
// int (*p)(void *, const char *) - declare p as pointer to function (pointer to void, pointer to const char) returning int

