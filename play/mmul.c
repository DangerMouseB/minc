mmul()


void *calloc();

int Q;
int N;

print(int **board) {
	int x;
	int y;

	for (y=0; y<Q; y++) {
		for (x=0; x<Q; x++)
			if (board[x][y])
				printf(" Q");
			else
				printf(" .");
		printf("\n");
	}
	printf("\n");
}

chk(int x, int y, int **board) {
	int i;
	int r;

	for (r=i=0; i<Q; i++) {
		r = r + board[x][i];
		r = r + board[i][y];
		if (x+i < Q & y+i < Q)
			r = r + board[x+i][y+i];
		if (x+i < Q & y-i >= 0)
			r = r + board[x+i][y-i];
		if (x-i >= 0 & y+i < Q)
			r = r + board[x-i][y+i];
		if (x-i >= 0 & y-i >= 0)
			r = r + board[x-i][y-i];
	}
	return r;
}

go(int y, int **board) {
	int x;

	if (y == Q) {
		print(board);
		N++;
		return 0;
	}
	for (x=0; x<Q; x++)
		if (chk(x, y, board) == 0) {
			board[x][y]++;
			go(y+1, board);
			board[x][y]--;
		}
}

main(int ac, void **av) {
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



