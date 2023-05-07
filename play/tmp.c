int printf(const char*, ...);

int LF() {return 255 * 256 + 10;}

int main(int argc, char*argv[]) {
    printf("hello%c", LF());
    return 0;
}

