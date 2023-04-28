#include "minc.h"

int main(int argc, char*argv[]) {
//    if (argc == 2) {
//        const char *ffn = argv[1];
//        FILE *file = fopen(ffn, "r");
//        if (!file) {
//            perror("Error opening file");
//            return EXIT_FAILURE;
//        }
//        inf = file;
//    }
//    else
//        inf = stdin;
    Arena a;
    initArena(&a, 1);
    char *p0 = a.next;
    char *p1 = (char*) allocInArena(&a, 4000, 64);
    char *p1_2 = (char*) reallocInArena(&a, p1, 4002, 64);
    char *p2 = (char*) allocInArena(&a, 4000, 64);
    int n1 = numChunks(&a);
    resetArena(&a);
    char *p3 = (char*) allocInArena(&a, 4000, 64);
    char *p4 = (char*) allocInArena(&a, 4000, 64);
    char *p5 = (char*) allocInArena(&a, 2000, 64);
    char *p6 = (char*) allocInArena(&a, 100, 64);
    char *p6_2 = (char*) reallocInArena(&a, p6, 8000, 64);
    char *p6_3 = (char*) reallocInArena(&a, p6, 4000, 64);
    int n2 = numChunks(&a);
}