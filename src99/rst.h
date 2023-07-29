#include <stdalign.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include "bk/buckets.h"
#include "bk/btype.h"
#include "bk/common/pp.h"

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


FILE *of;                       // output stream, e.g. stdout


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
    rst_bindfnto = _t+7,        // can we infer this from the type?
    rst_getoverload = _t+8,
    rst_getfamily = _t+9,
    rst_ret = _t+10,
    rst_signal = _t+11,
    rst_cast = _t+12,
    rst_stalloc = _t+13,

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
    btype tRet;     // 4
    btype *t;
} rst;
char * rst_typelang = "rstop*i32*(btype&ptr) :rst";
btype * rst_btype;

typedef struct {
    int n;
    rst *nodes[];
} rstlist;

typedef struct {
    rst base;
    rst *fn;
    rstlist args;
} rstapply;
char * rstapply_typelang = "rst * rst&ptr * i32 * (N** rst&ptr)";
btype * rstapply_btype;
// how would a visitor know that nargs is the size of the pointer array?
// it can't so would either need a rstapply visitor that has the knowledge
// and if we want to reuse we need another mechanism - instead define:
// "rstptrs_ & (i32 * (N** rst&ptr) & ptr) :rstptrs"
// then we can do:
// char * rstapply_typelang = "rst * rst&ptr * rstptrs";
// it's not so much that we can't describe it, it is that we want to have more flexible behaviour
// but this flexability needs encoding and may not be worth it
// e.g. in C I need to write myRstApply.nargs so every rstptrs has to use nargs even if I use a record
// to make it not location dependent (additionally to peek the memory of the struct is getting into UB)
// to generalise we should probably define a rstptrs struct so the code
// in C we may hit UB if we allow a struct to be cast to a tuple (as C doesn't have tuples and to access memory is UB)

// => for type based GC our C structs have to have a bit more convention - which is mildly less efficient
// e.g.
// struct {
//     unsigned char n; // 1 with 7 padded
//     rst * nodes[];
// };

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
    rstlist nodes;
} rstseq;

typedef struct {
    rst base;
    int nvars;
    rst **nodes;
} rststalloc;


// in bones nodes[i] is bounds checked but nodes collect [[each] each + 1] isn't
// similarly for other iteration - additionally simple things such as + 1 could be SIMD'd


enum smtype {
    debug = 1,
    c_style = 2,            // 0b0000_0010      pass by value, mutable lvalues
    bones_style = 4,        // 0b0000_0100      pass by value or ref, immutable values, binding only, CoW optimised
};


// storage manage structs

typedef struct {
    enum smtype smtype; // 4
} smbase;


typedef struct {
    void *sig;
    void *tRet;
    int (*emitqbe)(rst *, smbase *);
    int (*emitmir)(rst *, smbase *);
} bonesfn;




// debug storage manages keep locals off the stack so an optimising compiler can't get in the way?


void putq(char *src, ...) {
    va_list args;
    va_start(args, src);
    vfprintf(of, src, args);
    va_end(args);
}


// scope creation

bscope * mklocalscope(Buckets *buckets) {
    bscope *answer = allocInBuckets(buckets, sizeof(bscope), alignof(bscope));
    answer->scope = local;
    return answer;
}

bscope * mkfnscope(Buckets *buckets) {
    bscope* answer = allocInBuckets(buckets, sizeof(bscope), alignof(bscope));
    answer->scope = fn;
    return answer;
}


// node creation

rst * mkapply (Buckets* buckets, rst *fn, int nargs, ...) {
    rstapply* answer = allocInBuckets(buckets, sizeof(rstapply) + sizeof (rst *) * nargs, alignof(rstapply));
    answer->base.op = rst_apply;
    answer->fn = fn;
    if (nargs > 0) {
        answer->args.n = nargs;
        va_list args;
        va_start(args, nargs);
        for (int i = 0; i < nargs; i++) answer->args.nodes[i] = va_arg(args, rst*);
        va_end(args);
    } else if (nargs == 0) {
        answer->args.n = 0;
    } else {
        nyi("nargs must be >= 0");
    }
    return (rst*) answer;
}

rst * mkbindto (Buckets* buckets, rst *n, bscope *scope, char *name) {
    rstbind* answer = allocInBuckets(buckets, sizeof(rstbind), alignof(rstbind));
    answer->base.op = rst_bindto;
    answer->n = n;
    answer->scope = scope;
    answer->name = name;
    return (rst*) answer;
}

rst * mkget (Buckets* buckets, bscope *scope, char *name) {
    rstget* answer = allocInBuckets(buckets, sizeof(rstget), alignof(rstget));
    answer->base.op = rst_get;
    answer->scope = scope;
    answer->name = name;
    return (rst*) answer;
}

rst * mkgetoverload (Buckets* buckets, bscope *scope, char *name, int nargs) {
    rstgetoverload* answer = allocInBuckets(buckets, sizeof(rstgetoverload), alignof(rstgetoverload));
    answer->base.op = rst_getoverload;
    answer->scope = scope;
    answer->name = name;
    answer->nargs = nargs;
    return (rst*) answer;
}

rst * mkret (Buckets* buckets, rst *n, bscope *scope) {
    rstret* answer = allocInBuckets(buckets, sizeof(rstret), alignof(rstret));
    answer->base.op = rst_get;
    answer->n = n;
    answer->scope = scope;
    return (rst*) answer;
}

rst * mkseq (Buckets* buckets, int nnodes, ...) {
    va_list args;
    rstseq* answer = allocInBuckets(buckets, sizeof(rstseq) + sizeof(rst *) * nnodes, alignof(rstseq));
    answer->base.op = rst_seq;
    if (nnodes > 0) {
        answer->nodes.n = nnodes;
        va_start(args, nnodes);
        for (int i = 0; i < nnodes; i++) answer->nodes.nodes[i] = va_arg(args, rst*);
        va_end(args);
    } else if (nnodes == 0) {
        bug("nnodes == 0");
    } else {
        nyi("args[0] is an array of size -nnodes");
    }
    return (rst*) answer;
}

rst * mkstalloc (Buckets* buckets, int nvars, ...) {
    va_list args;
    // args is a list of (varname, type) tuples stored as a map from varname to (offset, type)
    // do we look it up linearly or by hash?
    rststalloc* answer = allocInBuckets(buckets, sizeof(rststalloc), alignof(rststalloc));
    if (nvars > 0) {
        answer->nvars = nvars;
//        answer->nodes = (rst **) allocInBuckets(buckets, sizeof(rst *) * nvars, alignof(rst *));
        va_start(args, nvars);
//        for (int i = 0; i < nvars; i++) answer->nodes[i] = va_arg(args, rst*);
        va_end(args);
    } else if (nvars == 0) {
        bug("nvars == 0");
    } else {
        nyi("args[0] is an array of size -nvars");
    }
    return (rst*) answer;
}

//mark
//alloc
//realloc
//wipe
//clear
//
//buckets get cleared


// literal creation

rst * mklitint (Buckets* buckets, long x) {
    rstlit* answer = allocInBuckets(buckets, sizeof(rstlit), alignof(rstlit));
    answer->base.op = rst_int;
    answer->v.i64 = x;
    return (rst*) answer;
}



// the storage manager should handle the CoW, pass by value - need a memory manager to do that


int emitqbe (rst *n, smbase *sm) {
    int o;
    // returns 0 if no return statement
    switch (n->op) {
        case rst_seq:
            for (o = 0; o < ((rststalloc*)n)->nvars; o++){
                emitqbe(((rststalloc*)n)->nodes[o], sm);
            }
        case rst_apply:
            putq("%.4 =w add %.5, 1");
        case rst_block:
        case rst_func:
        case rst_bindto:
            // two options
            //   - has a sensible register representations - ints, doubles, dates, bools - values
            //   - pointer to a struct (inc literal strings, some dates, tuples, etc) - objects
            // TASK: check how small structs are passed via an ABI - do we need to worry about this here or
            //   is it handled by the backend (QBE, MIR, LLVM, BVM).

            // the storage manager is responsible for providing the pointer of where to save
            putq("storew 1, %_a");


            putq("storew %.4, %_a");


        case rst_get:
            putq("%.5 =w loadw %_a");
            putq("%.7 =w loadw %_a");
        case rst_bindfnto:
        case rst_getoverload:
        case rst_getfamily:
        case rst_ret:
            putq("ret %.7");
        case rst_signal:
        case rst_cast:
        case rst_stalloc:
            putq("%_a =l alloc4 4");
        case rst_sym:
        default:
            nyi("default");
            return 0;
    }
}

int emitmir (rst *n, smbase *sm) {
    int o;
    // returns 0 if no return statement
    switch (n->op) {
        case rst_seq:
            for (o = 0; o < ((rststalloc*)n)->nvars; o++){
                emitmir(((rststalloc*)n)->nodes[o], sm);
            }
        case rst_apply:
        case rst_block:
        case rst_func:
        case rst_bindto:
        case rst_get:
        case rst_bindfnto:
        case rst_getoverload:
        case rst_getfamily:
        case rst_ret:
        case rst_signal:
        case rst_cast:
        case rst_stalloc:
        case rst_sym:
        default:
            nyi("default");
            return 0;
    }
}


//Symb emitexpr(Node *n) {
//    Symb sr, s0, s1, st;  enum tok o;  int l;  char ty[2];
//
//    sr.styp = Tmp;
//    sr.u.n = reserve_tmp();
//    sr.btyp = 0;





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


