int printf(const char*, ...);

//<:i32> LF() {return 255 * 256 + 10;}
int LF() {return 255 * 256 + 10;}

//int main(<:i32> argc, <:N**cstr> argv) {
int main(int argc, char*argv[]) {
    printf("hello%c", LF());
    return 0;
}

