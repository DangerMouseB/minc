
double scalarProduct(double *A, double *B, int strideA, int strideB, int n) {
    int i, oA, oB;  double sum;
    oA = 0;
    oB = 0;
    sum = 0;
    for (i=0; i < n; i++) {
        sum += *(A + oA) * *(B + oB);
        oA += strideA;
        oB += strideB;
    }
    return sum;
}