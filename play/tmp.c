int Q;  int nSolutions;

void go(int j, int **board) {
    int i;
    if (j == Q) {
        print(board);
        nSolutions++;
        return;
    }
    for (i=0; i<Q; i++)
        if (chk(i, j, board) == 0) {
            board[i][j]++;
            go(j+1, board);
            board[i][j]--;
        }
}
