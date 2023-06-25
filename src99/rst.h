//#include "Python.h"
//#include "structmember.h"       // https://github.com/python/cpython/blob/main/Include/structmember.h
#include "buckets.c"
#include <stdalign.h>
#include <stdarg.h>


// for loop
// while loop
// gosub
// apply
// bind locl, global, contexual, module
// get
// funcdef

// OPEN: I am mildly concerned that it is inefficient to use PyObject as the basis of my struct. They are unmoveable,
// and I don't yet know if I can manage the memory or if I have to use Python - if Python has a handle I can't empty
// a bucket. Alternatively I could keep python proxies with pointers either directly to rstnodes and an object table
// so I can move them (i.e. rebucket them). I can tombstone the links by setting the ref to Python's None (although
// that involves a ref count on None (but I can do refcnt += N for N tombstones, maybe use weakref).
//
// I want Python bindings so I can prototype quickly, and do my unit testing in Python. Also it should improve the
// dog food.

// OPEN: naming bst bone syntax tree, tc tree code, bones intermediate representation

// TODO: emit BTC -> BIR, parse BIR -> BTC, emit BTC -> QBE IR, emit BTC -> MIR

// ---------------------------------------------------------------------------------------------------------------------
// B OP
// ---------------------------------------------------------------------------------------------------------------------

#define _t 0


// variables in a module (especially the scratch module) are open - i.e. their type can be extended - global variables are not open

enum rstop {

    MISSING = 0,

    rst_seq = _t+1,
    rst_apply = _t+2,
    rst_block = _t+3,
    rst_func = _t+4,
    rst_bindto = _t+5,
    rst_get = _t+6,
    rst_bindtofn = _t+7,        // can we infer this from the type?
    rst_getoverload = _t+8,
    rst_getfamily = _t+9,
    rst_ret = _t+10,
    rst_signal = _t+11,
    rst_cast = _t+12,

    rst_int = _t+20,            // signed long
    rst_xldate = _t+21,         // stored as a f64
    rst_sym = _t+22,
    rst_txt = _t+23,            // utf8 (length prefixed?)
};

enum scope {
    local = 1,
    global = 2,
    module = 3,
    contexual = 4,
    consts = 5,
    fn = 6,
};



// scope structs

typedef struct {
    enum scope scope;
    // OPEN: locals needs to remember which variables have been allocated on the stack and where (lazy initially then preallocated later)
} bscope;



// rst node structs

typedef struct {
    // OPEN: for stepping / debugging and error reporting - need to have references to the source code (rstsrc*?)
    enum rstop op;  // 4
    int tRet;       // 4
} rst;

typedef struct {
    rst base;
    rst *fn;
    int nargs;
    rst **args;     // OPEN: could remove one level of indirection by making this variable size
} rstapply;

typedef struct {
    rst base;
    rst *n;
    char *name;
    bscope *scope;
} rstbind;

typedef struct {
    rst base;
    char *name;
    bscope *scope;
} rstget;

typedef struct {
    rst base;
    char *name;
    bscope *scope;
    int nargs;
} rstgetoverload;

typedef struct {
    rst base;
    union {
        long i64;
        double f64;
    } v;
} rstlit;

typedef struct {
    rst base;
    rst *n;
    bscope *scope;
} rstret;

typedef struct {
    rst base;
    rst *n1;
    rst *n2;
} rstseq;



// scope creation

bscope* mklocalscope(Buckets* buckets) {
    bscope* answer = allocInBuckets(buckets, sizeof(bscope), alignof(bscope));
    answer->scope = local;
    return answer;
}

bscope* mkfnscope(Buckets* buckets) {
    bscope* answer = allocInBuckets(buckets, sizeof(bscope), alignof(bscope));
    answer->scope = fn;
    return answer;
}


// node creation

rst* mkapply(Buckets* buckets, rst *fn, int nargs, ...) {
    rstapply* answer = allocInBuckets(buckets, sizeof(rstapply), alignof(rstapply));
    answer->base.op = rst_apply;
    answer->fn = fn;
    answer->nargs = nargs;
    answer->args = (rst **) allocInBuckets(buckets, sizeof(rst*) * nargs, alignof(rst*));
    va_list args;
    va_start(args, nargs);
    for (int i=0; i < nargs; i++) answer->args[i] = va_arg(args, rst*);
    va_end(args);
    return (rst*) answer;
}

rst* mkbindto(Buckets* buckets, rst *n, bscope *scope, char *name) {
    rstbind* answer = allocInBuckets(buckets, sizeof(rstbind), alignof(rstbind));
    answer->base.op = rst_bindto;
    answer->n = n;
    answer->scope = scope;
    answer->name = name;
    return (rst*) answer;
}

rst* mkget(Buckets* buckets, bscope *scope, char *name) {
    rstget* answer = allocInBuckets(buckets, sizeof(rstget), alignof(rstget));
    answer->base.op = rst_get;
    answer->scope = scope;
    answer->name = name;
    return (rst*) answer;
}

rst* mkgetoverload(Buckets* buckets, bscope *scope, char *name, int nargs) {
    rstgetoverload* answer = allocInBuckets(buckets, sizeof(rstgetoverload), alignof(rstgetoverload));
    answer->base.op = rst_getoverload;
    answer->scope = scope;
    answer->name = name;
    answer->nargs = nargs;
    return (rst*) answer;
}

rst* mkret(Buckets* buckets, rst *n, bscope *scope) {
    rstret* answer = allocInBuckets(buckets, sizeof(rstret), alignof(rstret));
    answer->base.op = rst_get;
    answer->n = n;
    answer->scope = scope;
    return (rst*) answer;
}

rst* mkseq(Buckets* buckets, rst *n1, rst *n2) {
    rstseq* answer = allocInBuckets(buckets, sizeof(rstseq), alignof(rstseq));
    answer->base.op = rst_seq;
    answer->n1 = n1;
    answer->n2 = n2;
    return (rst*) answer;
}



// literal creation

rst* mklitint(Buckets* buckets, long x) {
    rstlit* answer = allocInBuckets(buckets, sizeof(rstlit), alignof(rstlit));
    answer->base.op = rst_int;
    answer->v.i64 = x;
    return (rst*) answer;
}





// lit integers, decimals, strings, symbols and datetime
// bind and get need to understand the languages memory model?
// addressof(&) and deref(*) can be functions
// as can object(.) and pointer(->) access, both for lvals and rvals



//    op rettype details (l, r, )
//    litint -> 8 byte
//    litf64 -> double
//    littext -> txt*
//    litsym -> id
//    apply -> overload* | family*, numargs, args**, functype (inline etc)
//    func -> args, snippet, functype (nothrow etc)
//        if template will be instantiate
//        if generic will plumb types - for the specific apply
//    get_overload -> name, num_args
//    get_family -> name
//    snippet -> rst** (null terminated? or size prefixed)



// certain types can be held in registers
// if a struct is only simple register types then it could be held in QBE registers - but debugging would be hellish
// debug mode - mirror to memory
// release mode - just use registers - however it's getting nasty


