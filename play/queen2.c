#include "fred.h"
//int printf(char*, ...);
//int **newBoard();

#define FMT_FLOAT "%f"

int Q;  int nSolutions;

print(int **board) {
	int i;  int j;
	for (j=0; j<Q; j++) {
		for (i=0; i<Q; i++)
			if (board[i][j])
				printf(" Q");
			else
				printf(" .");
		printf("\n");
	}
	printf("\n");
}

chk(int i, int j, int **board) {
	int k;  int r;
	for (r=k=0; k<Q; k++) {
		r = r + board[i][k];
		r = r + board[k][j];
		if (i+k < Q & j+k < Q)
			r = r + board[i+k][j+k];
		if (i+k < Q & j-k >= 0)
			r = r + board[i+k][j-k];
		if (i-k >= 0 & j+k < Q)
			r = r + board[i-k][j+k];
		if (i-k >= 0 & j-k >= 0)
			r = r + board[i-k][j-k];
	}
	return r;
}

go(int j, int **board) {
	int i;
	if (j == Q) {
		print(board);
		nSolutions++;
		return 0;
	}
	for (i=0; i<Q; i++)
		if (chk(i, j, board) == 0) {
			board[i][j]++;
			go(j+1, board);
			board[i][j]--;
		}
}


//newBoard(int N) {
//    void *answer;
//    answer = calloc(N, sizeof(int *));
//    return answer;
//}

main(int ac, void **av) {
	int i;  int **board;  double a;
    a = 3;          // line comments work now
    a = a + 1;

	Q = 8;
	if (ac >= 2)
		Q = atoi(av[1]);
//	board = newBoard(Q);
    board = calloc(Q, sizeof(int *));
	for (i=0; i<Q; i++)
		board[i] = calloc(Q, sizeof(int));
	go(0, board);
	printf("found %d solutions\n", nSolutions);
    printf("my float " "%f" "\n", a);
}
