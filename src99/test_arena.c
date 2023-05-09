#include "minc.h"

void checkIEq(long act, long exp, unsigned long lineno, char *msg, ...) {
    if (act != exp) {
        fprintf(stderr, "%lu: %ld != %ld, %s", lineno, act, exp, msg);
        exit(0);
    }
}

void checkPEq(void *act, void *exp, unsigned long lineno, char *msg, ...) {
    if (act != exp) {
        fprintf(stderr, "%lu: %ld != %ld, %s", lineno, (unsigned long)act, (unsigned long)exp, msg);
        exit(0);
    }
}

void checkPNeq(void *act, void *exp, unsigned long lineno, char *msg, ...) {
    if (act == exp) {
        fprintf(stderr, "%lu: %ld == %ld, %s", lineno, (unsigned long)act, (unsigned long)exp, msg);
        exit(0);
    }
}

void reportPassed() {
    fprintf(stdout, "passed");
}


int main(int argc, char*argv[]) {
    int i;
    i = 1;
    for (int j=0; j < 5; j++) {
        int i;
        i = j;
        fprintf(stdout, "%d ", i);
    };
    {
        int i;
        i = 5;
        fprintf(stdout, "  %d ", i);
    };
    fprintf(stdout, "%d ", i);
    Buckets a;
    BucketsCheckpoint s;
    void *p = initBuckets(&a, 1);
    checkPNeq(p, 0, __LINE__, "0 indicates allocation failure");
    checkpointBuckets(&a, &s);
    char *p0 = a.next;
    char *p1 = (char*) allocInBuckets(&a, 4000, 64);
    checkPNeq(p1, p0, __LINE__, "should be diff because of alignment");
    char *p1_2 = (char*) reallocInBuckets(&a, p1, 4002, 64);
    checkPEq(p1_2, p1, __LINE__, "realloc should not trigger change of pointer in this case");
    char *p2 = (char*) allocInBuckets(&a, 4000, 64);
    int n1 = numBuckets(a.first_bucket);
    checkIEq(n1, 2, __LINE__, "should be diff because of alignment");
    resetToCheckpoint(&a, &s);
    char *p3 = (char*) allocInBuckets(&a, 4000, 64);
    checkPEq(p3, p1, __LINE__, "should reuse chunk");
    char *p4 = (char*) allocInBuckets(&a, 4000, 64);
    checkPEq(p4, p2, __LINE__, "should reuse chunk");
    char *p5 = (char*) allocInBuckets(&a, 2000, 64);
    char *p6 = (char*) allocInBuckets(&a, 100, 64);
    char *p6_2 = (char*) reallocInBuckets(&a, p6, 8000, 64);
    checkPNeq(p6_2, p6, __LINE__, "should allocate new chunk");
    char *p6_3 = (char*) reallocInBuckets(&a, p6_2, 1, 64);
    checkPEq(p6_3, p6_2, __LINE__, "should reuse chunk");
    char *p6_4 = (char*) reallocInBuckets(&a, p6, 1, 1);
    checkPNeq(p6_4, p6, __LINE__, "since p6_2 is not p6 it is not possible to realloc p6");
    int n2 = numBuckets(a.first_bucket);
    checkIEq(n2, 4, __LINE__, "4096, 4096, 4096, 8192");
    reportPassed();
}
