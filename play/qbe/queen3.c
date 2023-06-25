#include <stdio.h>
#include <stdlib.h>

void print(int **board, int Q) {
    int i, j;
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

int chk(int i, int j, int **board, int Q) {
    int k, r;
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

int go(int j, int **board, int nSolutions, int Q) {
    int i;
    if (j == Q) {
        print(board, Q);
        return nSolutions + 1;
    }
    for (i=0; i<Q; i++)
        if (chk(i, j, board, Q) == 0) {
            board[i][j]++;
            nSolutions = go(j+1, board, nSolutions, Q);
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
    nSolutions = go(0, board, 0, Q);
    printf("found %d solutions\n", nSolutions);
}
