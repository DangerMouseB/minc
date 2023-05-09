#include "fred.h"

int main() {
	int n, t, c, p;
	c = 0;
	n = 2;
	while (n < 5000) {
		t = 2;
		p = 1;
		while (t*t <= n) {
			if (n % t == 0)
				p = 0;
			t++;
		}
		if (p) {
			if (c && c % 10 == 0)
				printf("\n");
			printf("%4d ", n);
			c++;
		}
		n++;
	}
	printf("\n");
}
