#define FILE void

void *calloc(unsigned long nitems, unsigned long size);

// https://stackoverflow.com/questions/73751533/how-can-i-get-a-reference-to-standard-input-from-assembly-on-a-mac
//extern FILE * __stdoutp;
//int fprintf(FILE *stream, const char *format, ...);
int printf(const char *format, ...);
int atoi(const char*);
int abs(int x);
void exit(int status);
void *malloc(long size);

//#include <stdio.h>
//extern FILE *__stdinp;
//extern FILE *__stdoutp;
//extern FILE *__stderrp;

//void *__stdinp;
//void *__stdoutp;
//void *__stderrp;


//int* fredjoe();
//int* fredjoe2(...);
//int* fredjoe3(int);
//int* fredjoe4(int, ...);

