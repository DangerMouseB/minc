#include "fred.h"

double scalarProduct(double *rowA, double **B, int mA, int j) {
    // A and B are n x m
    double answer = 0;
    for (int k=0; k < mA; k++){
        answer += rowA[k] * B[k][j];
    }
    return answer;
}

int mmul(double **A, double **B, int nA, int mA, int mB, double **out) {
    for (int i=0; i < nA; i++) {
        for (int j=0; j < mB; j++) {
            out[i][j] = scalarProduct(A[i], B, mA, j);
        }
    }
    return 0;
}

int mmul2(double **A, double **B, int nA, int mA, int mB, double **out) {
    for (int i=0; i < nA; i++) {
        for (int j=0; j < mB; j++) {
            out[i][j] = 0;
            double *rowA = A[i];
            for (int k=0; k < mA; k++){
                out[i][j] += rowA[k] * B[k][j];
            }
        }
    }
    return 0;
}

int main(int ac, void **av) {
	int i;
    int **board;

	Q = 8;
	if (ac >= 2)
		Q = atoi(av[1]);
	board = calloc(Q, sizeof(int *));
	for (i=0; i<Q; i++)
		board[i] = calloc(Q, sizeof(int));
	go(0, board);
	printf("found %d solutions\n", N);
}

