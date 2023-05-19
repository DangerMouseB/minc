int printf(const char *format, ...);
// https://stackoverflow.com/questions/73751533/how-can-i-get-a-reference-to-standard-input-from-assembly-on-a-mac

#define FILE void
#define stdout __stdoutp
extern FILE * __stdoutp;
extern int fprintf(FILE *stream, const char *format, ...);
