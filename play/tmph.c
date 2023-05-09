#define	stderr	__stderrp

where

extern FILE *__stderrp;

typedef struct __sFILE {
    ...
} FILE;

int fprintf(FILE * restrict, const char * restrict, ...) __attribute__((__format__ (__printf__, 2, 3)));
