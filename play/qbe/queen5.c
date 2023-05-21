#include <stdio.h>
#include <stdlib.h>


void print(int **board, int Q, FILE *s) {
	int i, j;
	for (j=0; j<Q; j++) {
		for (i=0; i<Q; i++)
			if (board[i][j])
				fprintf(s, " Q");
			else
				fprintf(s, " .");
		fprintf(s, "\n");
	}
	fprintf(s, "\n");
}

int chk(int i, int j, int **board, int Q) {
	int k, r;
	for (r=k=0; k<Q; k++) {
		r += board[i][k];
		r += board[k][j];
		if (i+k < Q & j+k < Q)
			r += board[i+k][j+k];
		if (i+k < Q & j-k >= 0)
			r += board[i+k][j-k];
		if (i-k >= 0 & j+k < Q)
			r += board[i-k][j+k];
		if (i-k >= 0 & j-k >= 0)
			r += board[i-k][j-k];
	}
	return r;
}

int go(int j, int **board, int Q, FILE *s) {
	int i, nSolutions = 0;
	if (j == Q) {
		print(board, Q, s);
		return 1;
	}
	for (i=0; i<Q; i++)
		if (chk(i, j, board, Q) == 0) {
			board[i][j]++;
			nSolutions += go(j+1, board, Q, s);
			board[i][j]--;
		}
    return nSolutions;
}

int **newBoard(int N) {
    int **answer, i;
    answer = calloc(N, sizeof(int *));
    for (i=0; i<N; i++)
        answer[i] = calloc(N, sizeof(int));
    return answer;
}

int main(int ac, char *av[]) {
	int **board, nSolutions, Q;
	Q = 8;
	if (ac >= 2)
		Q = atoi(av[1]);
	board = newBoard(Q);
    nSolutions = go(0, board, Q, stdout);
	fprintf(stdout, "found %d solutions\n", nSolutions);
}
