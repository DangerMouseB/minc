#include <stdlib.h>
#include <stdio.h>

void putb_(unsigned long n, int depth, FILE *f) {
    if (n >> 1 || depth < 63) putb_(n >> 1, ++depth, f);
    if (depth % 4 == 0) putc(' ', f);
    if (depth % 16 == 0) putc(' ', f);
    putc((n & 1) ? '1' : '0', f);
}

void putb(unsigned long n, FILE *f) {putb_(n, 0, f);}

void fred(unsigned long n, int i) {
    printf("%3d: ", i);
    putb(n, stdout);
    fprintf(stdout, " : %d \n", n);
}


// "In C programming language, a computation of unsigned integer values can never overflow, this means that
// UINT_MAX + 1 yields zero. More precise, according to the C standard unsigned integer operations do wrap
// around, the C Standard, 6.2."

// "In contrast, the C standard says that signed integer overflow leads to undefined behavior where a
// program can do anything, including dumping core or overrunning a buffer."


int main() {
    unsigned char a, b; signed char c, d;  unsigned short e, f; signed short g, h;
    unsigned int i, j; signed int k, l;  unsigned long m, n; signed long o, p;
    int ex;

    // out of range assignment
    printf("out of range assignment play\n\nunsigned char - MAX + 1 = 0\n", 1);
    ex = 1;
    a = 0x00000101;  fred(a, ex++);     // uchar
    a = 0x00010001;  fred(a, ex++);     // ushort
    a = 0x100000001;  fred(a, ex++);    // uint
    a = -1;  fred(a, ex++);
    a = a + a;  fred(a, ex++);
    a++;  fred(a, ex++);
    k = 127;
    l = 1;
    a = k + l;  fred(a, ex++);

    printf("\nsigned char - MAX + 1 is UB\n", 1);
    ex = 1;
    c = 0x00000101;  fred(c, ex++);     // char
    c = 0x00010001;  fred(c, ex++);     // short
    c = 0x100000001;  fred(c, ex++);    // int
    c = -1;  fred(c, ex++);
    c = c + c;  fred(c, ex++);
    c++;  fred(c, ex++);
    k = 127;
    l = 1;
    c = k + l;  fred(c, ex++);

    printf("\nunsigned short - e = a + a\n", 1);
    ex = 1;
    a = -1;
    a = a + a;  fred(a, ex++);
    e = a + a;  fred(e, ex++);
    e = a; e = e + e;  fred(e, ex++);

    printf("\nsigned short - g = c + c\n", 1);
    ex = 1;
    c = -1;  fred(c, ex++);
    c = c + c;  fred(c, ex++);
    c = -1;
    g = -1;  fred(g, ex++);
    g = c;  fred(g, ex++);                      // -1
    g = c + c;  fred(g, ex++);                  // -2
    g = -1;
    g = g + g;  fred(g, ex++);                  // -2



}
