#include <stdio.h>
#include <stdlib.h>

FILE _;

void PP(char *s) {
    fprintf(_.s, s);
}

void print(int **board) {
    int i, j;
    for (j=0; j<_.Q; j++) {
        for (i=0; i<_.Q; i++)
            if (board[i][j])
                PP(" Q");
            else
                PP(" .");
        PP("\n");
    }
    PP("\n");
}

int chk(int i, int j, int **board) {
    int k, r;
    for (r=k=0; k<_.Q; k++) {
        r = r + board[i][k];
        r = r + board[k][j];
        if (i+k < _.Q & j+k < _.Q)
            r = r + board[i+k][j+k];
        if (i+k < _.Q & j-k >= 0)
            r = r + board[i+k][j-k];
        if (i-k >= 0 & j+k < _.Q)
            r = r + board[i-k][j+k];
        if (i-k >= 0 & j-k >= 0)
            r = r + board[i-k][j-k];
    }
    return r;
}

void go(int j, int **board) {
    int i;
    if (j == _.Q) {
        print(board);
        _.nSolutions++;
        return;
    }
    for (i=0; i<_.Q; i++)
        if (chk(i, j, board) == 0) {
            board[i][j]++;
            go(j+1, board);
            board[i][j]--;
        }
}

int **newBoard(int N) {
    int **answer, i;
    answer = calloc(N, sizeof(int *));
    for (i=0; i<N; i++)
        answer[i] = calloc(N, sizeof(int));
    return answer;
}

int main(int ac, char *av[]) {
    int **board;
    int _.Q, _.nSolutions;  FILE *_.s;
    _.Q = 8;
    if (ac >= 2)
        _.Q = atoi(av[1]);
    _.nSolutions = 0;
    _.s = stdout;

    board = newBoard(_.Q);
    go(0, board);
    fprintf(_.s, "found %d solutions\n", _.nSolutions);
}
