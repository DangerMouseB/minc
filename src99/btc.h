#include "Python.h"
#include "structmember.h"       // https://github.com/python/cpython/blob/main/Include/structmember.h


// char op;
// PyObject *tRet;
// l, r


// for loop
// while loop
// gosub
// apply
// bind locl, global, contexual, module
// get
// funcdef

// OPEN: I am mildly concerned that it is inefficient to use PyObject as the basis of my struct. They are unmoveable,
// and I don't yet know if I can manage the memory or if I have to use Python - if Python has a handle I can't empty
// a bucket. Alternatively I could keep python proxies with pointers either directly to tcnodes and an object table
// so I can move them (i.e. rebucket them). I can tombstone the links by setting the ref to Python's None (although
// that involves a ref count on None (which I can do as a batch).
//
// I want Python bindings so I can prototype quickly, and do my unit testing in Python. Also it should improve the
// dog food.

// OPEN: naming bst bone syntax tree, tc tree code, bones intermediate representation

// TODO: emit BTC -> BIR, parse BIR -> BTC, emit BTC -> QBE IR, emit BTC -> MIR

// ---------------------------------------------------------------------------------------------------------------------
// B OP
// ---------------------------------------------------------------------------------------------------------------------

#define _t 0

enum bop {

    MISSING = 0,

    b_snippet = _t+1,
    b_apply = _t+2,
    b_block = _t+3,
    b_func = _t+4,
    b_bind = _t+5,
    b_get = _t+6,
    b_bind_fn = _t+7,
    b_get_overlaod = _t+8,
    b_get_family = _t+9,
    b_lit = _t+10,
    b_lit_tup = _t+11,
    b_lit_struct = _t+12,
    b_lit_frame = _t+13,

};


//typedef struct {
//    PyObject_VAR_HEAD;
//} Base;
//
//typedef struct {
//    Base Base;
//    PyObject *name;
//    PyObject *bmod;
//    PyObject *d;            // dispatcher
//    PyObject *TBCSentinel;
//} Fn;
//
//typedef struct {
//    Fn Fn;
//    ju8 num_tbc;            // the number of arguments missing in the args array
//    // pad48
//    PyObject *pipe1;        // 1st piped arg for binaries and ternaries
//    PyObject *pipe2;        // 2nd piped arg for ternaries
//    PyObject *args[];
//} Partial;


struct btc {
    struct btc *l;      // 8
    struct btc *r;      // 8
    enum bop op;        // 4 OPEN: can we specify the size of an enum in CLang / CLion (only using an enum for debugging niceness in CLion)
};


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