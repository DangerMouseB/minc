int printf(const char*, ...);
int fprintf(void *stream, const char *format, ...);
//void *stdout;
void *calloc(unsigned long nitems, unsigned long size);
//int printf(const char*, ...);
int atoi(const char*);

//<:i32> LF() {return 255 * 256 + 10;}
//unsigned char LF2() {return 255 * 256 + 10;}  // OPEN: make return value conform to return type

//int main(<:i32> argc, <:N**cstr> argv) {
int main(int argc, char*argv[]) {
    short a='h', b='d';
    b++;
    printf("%c%cllo %d\n", a++, b, a + b);
    return 0;
}
