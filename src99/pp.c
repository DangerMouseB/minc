#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>


static void die_(char *preamble, char *msg, va_list args) {
//    fprintf(stderr, "\nbefore end of line %d: ", isrcline);
    fprintf(stderr, "%s", preamble);
    vfprintf(stderr, msg, args);
//    fprintf(stderr, "\nin %s\n\n", srcFfn);
    // OPEN: use setjmp and longjmp with deallocation of linked list of arenas
    exit(1);
}

void die(char *msg, ...) {
    va_list args;
    va_start(args, msg);
    die_("", msg, args);
    va_end(args);
}

void nyi(char *msg, ...) {
    va_list args;
    va_start(args, msg);
    die_("nyi: ", msg, args);
    va_end(args);
}

void bug(char *msg, ...) {
    va_list args;
    va_start(args, msg);
    die_("bug: ", msg, args);
    va_end(args);
}
