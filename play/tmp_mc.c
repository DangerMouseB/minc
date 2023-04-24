int Q;  int nSolutions;

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