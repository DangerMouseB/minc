#include <stdlib.h>
#include <stdalign.h>
#include "../rst.h"


/*

+ => add(lhs, rhs)
 lhs is ptr, rhs is int
 lhs is int, rhs is ptr
 lhs is int, rhs is int

 t3 = add(t1, t2)

 %t3 =w add %t1, %t2
 %t3 =l add %t1, %t2
 %t3 =s add %t1, %t2
 %t3 =d add %t1, %t2

 + will need to zero or sign extend

 */


int main(int argc, char*argv[]) {
    Buckets a;
    rst *n1, *n2, *n3, *n4, *n5, *n6, *n7, *n8, *n9, *n10, *n11, *n12; bscope *locals; bscope *fns;

    locals = mklocalscope(&a);
    fns = mkfnscope(&a);

    // C source
    //
    // int main() {
    //     int a;
    //     a = 1;
    //     a += 1;
    //     return a;
    // }

    // target QBE
    //
    // export function w $main() {
    // @start.1
    // @body.2
    //     %_a =l alloc4 4
    //     storew 1, %_a
    //     %.5 =w loadw %_a
    //     %.4 =w add %.5, 1
    //     storew %.4, %_a
    //     %.7 =w loadw %_a
    //     ret %.7
    // }

    // reduced syntax tree
    //                        ____________________ seq ____________________
    //                       /                                             \
    //          __________ seq _____________________                       ret
    //         /                                    \                       |
    //        /                                 bindto(locals, "a")     get(locals, "a")
    //       /                                       |
    //  bindto(locals, "a")          _____________ apply ____
    //      |                       /        |               \
    //  litint(1)        get(locals, "a")   litint(1)     getoverload("add", 2)

    // fns
    // add_2; litint*litint ^ litint


    n1 = mklitint(&a, 1);
    n2 = mkbindto(&a, n1, locals, "a");

    n3 = mkget(&a, locals, "a");
    n4 = mklitint(&a, 1);
    n5 = mkgetoverload(&a, fns, "add", 2);
    n6 = mkapply(&a, n5, 2, n3, n4);
    n7 = mkbindto(&a, n6, locals, "a");

    n8 = mkseq(&a, n2, n7);

    n9 = mkget(&a, locals, "a");
    n10 = mkret(&a, n9, locals);

    n11 = mkseq(&a, n8, n10);


    // next - QBE emission

}
