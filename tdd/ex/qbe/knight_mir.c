extern int atoi(const char*);
extern void *calloc(unsigned long nitems, unsigned long size);
extern void *malloc(unsigned long size);
extern int abs(int x);
extern void exit(int status);

extern int printf(const char *format, ...);
// https://stackoverflow.com/questions/73751533/how-can-i-get-a-reference-to-standard-input-from-assembly-on-a-mac

#define FILE void
#define stdout __stdoutp
extern FILE * __stdoutp;
extern int fprintf(FILE *stream, const char *format, ...);


#define time_t void
#define SIZEOF_TIME_T 8
extern time_t time(time_t *t);
extern char *ctime(time_t *timer);


int N = 0;
int **b;
time_t *t;

int board() {
    int x, y;
    time(t);
    printf("t: %s\n", ctime(t));
    for (y=0; y<8; y++) {
        for (x=0; x<8; x++)
            printf(" %02d", b[x][y]);
        printf("\n");
    }
    printf("\n");
    return 0;
}

int chk(int x, int y) {
    if (x < 0 || x > 7 || y < 0 || y > 7) return 0;
    return b[x][y] == 0;
}

int go(int k, int x, int y) {
    int i, j, no, x1, y1;
    b[x][y] = k;
    if (k == 64) {
        if (x!=2 && y!=0 && (abs(x-2) + abs(y) == 3)) {
            board();
            N++;
            if (N==1) exit(0);
        }
    }
    else {
        for (i=-2; i<=2; i++)
            for (j=-2; j<=2; j++) {
                if (abs(i) + abs(j) == 3 && chk(x+i, y+j))
                    go(k+1, x+i, y+j);
            }
    }
    b[x][y] = 0;
    return 0;
}

int main() {
    int i;
    t = malloc(8);
    time(t);
    printf("t: %s\n", ctime(t));
    b = calloc(8, sizeof (int *));
    for (i=0; i<8; i++)
        b[i] = calloc(8, sizeof (int));
    go(1, 2, 0);
    // never gets this far
}
