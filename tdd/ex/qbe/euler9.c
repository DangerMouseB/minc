#include <stdio.h>

int main() {
    int i, a, b, c, d;

    for (a = 1; a < 1000; a++) {
        for (b = a + 1; b < 1000; b++) {
            d = a*a + b*b;
            for (i = 0; i < 1000; i++) {
                if (i * i == d) {
                    c = i;
                    if (b < c && a+b+c == 1000) {
                        printf("%d\n", a*b*c);
                        return 0;
                    }
                    break;
                }
            }
        }
    }
}

