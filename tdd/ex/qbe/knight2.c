#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "jones.h"

int N = 0;
int *b;
time_t *t;

Buckets * gen;

int board() {
    int x, y;
    time(t);
    printf("t: %s\n", ctime(t));
    for (y=0; y<8; y++) {
        for (x=0; x<8; x++)
            printf(" %02d", b[8 * x + y]);
        printf("\n");
    }
    printf("\n");
    return 0;
}

int chk(int x, int y) {
    if (x < 0 || x > 7 || y < 0 || y > 7) return 0;
    return b[8 * x + y] == 0;
}

int go(int k, int x, int y) {
    int i, j;
    b[8 * x + y] = k;
    if (k == 64) {
        if (x!=2 && y!=0 && (abs(x-2) + abs(y) == 3)) {
            board();
            N++;
            if (N==10) exit(0);
        }
    }
    else {
        for (i=-2; i<=2; i++)
            for (j=-2; j<=2; j++) {
                if (abs(i) + abs(j) == 3 && chk(x+i, y+j))
                    go(k+1, x+i, y+j);
            }
    }
    b[8 * x + y] = 0;
    return 0;
}

int main() {
    int i;
    gen = malloc(SIZEOF_BUCKETS);
    initBuckets(gen, 4096);
    t = malloc(8);
    time(t);
    printf("t: %s\n", ctime(t));
    b = allocInBuckets(gen, 64 * sizeof (int), 8);
    go(1, 2, 0);
    // never gets this far
}
