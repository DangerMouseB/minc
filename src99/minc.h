#ifndef MINC_MINC_H
#define MINC_MINC_H

#include <stddef.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdalign.h>
#include "aj.h"


// compiler constants (enum so get in debugger)
enum {
    NGlo = 256,
    NVar = 512,
    SYM_NAME_MAX = 32,
    TMP_START = 1,
    LBL_START = 1,
};



// ---------------------------------------------------------------------------------------------------------------------
// FORWARD DECLARATIONS
// ---------------------------------------------------------------------------------------------------------------------

void PP(int level, char *msg, ...);
void die(char *msg, ...);
void bug(char *msg, ...);



// ---------------------------------------------------------------------------------------------------------------------
// btyp enum
// here just to allow CLion to make life easier when debugging - eventually will replace with BTYPE_ID
// encoding up to 3 pointers + a btyp can be capture in 4 bytes, bit 7 of btyp indicates extern
// pointer to a fn:     tRet, B_FN, B_PTR
// pointer:             BASE_TYPE, B_PTR
// ---------------------------------------------------------------------------------------------------------------------

#define _hc1 0
#define _hc2 20

enum btyp {
    B_CHAR = _hc1+5,        // B_I8 - implementation defined (poss with compiler flags)
    B_U8  = _hc1+1,         // unsigned char
    B_U16 = _hc1+2,         // unsigned short
    B_U32 = _hc1+3,         // unsigned int, unsigned
    B_U64 = _hc1+4,         // unsigned long, unsigned long int
    B_I8  = _hc1+5,         // char, signed char
    B_I16 = _hc1+6,         // short, signed short
    B_I32 = _hc1+7,         // int, signed int, signed
    B_I64 = _hc1+8,         // long, long int, signed long, signed long int

    B_F32 = _hc1+9,         // float
    B_F64 = _hc1+10,        // double

//    B_N_CHAR_STAR = _hc1+12,  // N**chars, char*argv[], char**
//    B_TXT = _hc1+13,        // txt (length prefixed, null terminated uft-8 array)
//    B_NN_I32 = _hc1+14,     // int **, signed int **
//    B_N_I32 = _hc1+15,      // int *, signed int *

    B_VOID = _hc2+1,
    B_VARARGS = _hc2+2,
    B_U8_S = _hc2+3,
    B_N_MEM = _hc2+4,       // N**MEM, implemented as void **
    B_PTR = _hc2+5,
    B_FN = _hc2+6,
    B_VOID_STAR = (B_VOID << 8) | B_PTR,
    B_CHAR_STAR = (B_CHAR << 8) | B_PTR,
    B_FN_PTR = (B_FN << 8) | B_PTR,

    B_EXTERN = 128,
    B_EXTERN_FN = B_EXTERN + B_FN,
    B_EXTERN_FN_PTR = B_EXTERN + B_FN_PTR,
};

static char *btyptopp[] = {
        [B_U8] = "B_U8",                [B_U16] = "B_U16",              [B_U32] = "B_U32",              [B_U64] = "B_U64",
        [B_I8] = "B_I8",                [B_I16] = "B_I16",              [B_I32] = "B_I32",              [B_I64] = "B_I64",
        [B_F32] = "B_F32",              [B_F64] = "B_F64",
        [B_VOID_STAR] = "B_VOID_STAR",  [B_CHAR_STAR] = "B_CHAR_STAR",
        [B_VOID] = "B_VOID",            [B_VARARGS] = "B_VARARGS",      [B_U8_S] = "B_U8_S",            [B_N_MEM] = "B_N_MEM",
};

#define IDIR(t) (((t) << 8) + B_PTR)
#define FUNC(t) (((t) << 8) + B_FN)
#define DREF(t) ((t) >> 8)
#define KIND(t) ((t) & 0xff)
#define SIZE(t) (                                   \
    t == T_VOID ? (die("void has no size"), 0) : (  \
	t == B_I32 ? 4 : (                              \
	8                                               \
)))


int fitsWithin(enum btyp a, enum btyp b) {
    // should answer a tuple {cacheID, doesFit, tByT, distance}
    // tByT can just be a T sorted list (not worth doing a hash)
    if (a == b) return 1;
    if ((b == B_EXTERN) && (a & B_EXTERN)) return 1;
    if ((b == B_FN) && ((a & 0x7f) == B_FN)) return 1;
    if ((b == B_EXTERN_FN_PTR) && ((a & 0xffff) == B_EXTERN_FN_PTR)) return 1;
    if ((b == B_FN_PTR) && ((a & 0xff7f) == B_FN_PTR)) return 1;
    if ((b == B_CHAR_STAR) && ((a & 0xff7f) == B_CHAR_STAR)) return 1;
    if ((b == B_VOID_STAR) && ((a & 0xff7f) == B_VOID_STAR)) return 1;
    if ((a & 0x000000FF) == b) return 1;
    return 0;
}

static enum btyp _tDepointered(enum btyp t) {
    while ((t & 0x000000FF) == B_PTR) t >>= 8;
    return t;
}

enum btyp tRet(enum btyp tFn) {
    return tFn >> 8;               // functions are stored shifted with type B_FN
}

void fPPT(FILE *f, enum btyp t) {
    int separate = 0;  enum btyp tBase;
    tBase = _tDepointered(t);
    if (fitsWithin(t, B_EXTERN)) {fputs("extern", f); separate = 1;}
    if (fitsWithin(tBase, B_FN)) {
        if (separate) {fputc(' ', f); separate = 0;}
        fputs("(...) ->", f);
        tBase >>= 8;
        separate = 1;
    }
    if (separate) {fputc(' ', f); separate = 0;}
    while ((t & 0x000000FF) == B_PTR) {
        fputc('*', f);
        t >>= 8;
    }
    fputs(btyptopp[tBase], f);
}

enum btyp BTIntersect(enum btyp a, enum btyp b) {
    if ((a & 0x00000080) == 0 && (b == B_EXTERN)) return a | B_EXTERN;
    nyi("BTIntersect");
    return 0;
}

enum btyp minus(enum btyp a, enum btyp b) {
    if (b & 0x80) return a & 0xffffff7f;
    nyi("minus");
    return 0;
}


// ---------------------------------------------------------------------------------------------------------------------
// TOK
// ---------------------------------------------------------------------------------------------------------------------

#define _t 0
#define _expr _t+40
#define _bin _expr+30
#define _stmt _bin+20
#define _pt 256

enum tok {

    MISSING = 0,


    // type tokens
    T_TYPE_NAME = _t+1,
    T_TYPEDEF   = _t+2,
    T_EXTERN    = _t+3,
    T_STATIC    = _t+4,
    T_AUTO      = _t+5,
    T_REGISTER  = _t+6,
    T_STRUCT    = _t+7,
    T_UNION     = _t+8,

    T_CONST     = _t+9,
    T_RESTRICT  = _t+10,
    T_VOLATILE  = _t+11,
    T_INLINE    = _t+12,

    T_VOID      = _t+13,
    T_CHAR      = _t+14,
    T_SHORT     = _t+15,
    T_INT       = _t+16,
    T_LONG      = _t+17,

    T_FLOAT     = _t+18,
    T_DOUBLE    = _t+19,
    T_SIGNED    = _t+20,        // OPEN: drop these and add uchar etc
    T_UNSIGNED  = _t+21,
    T_BOOL      = _t+22,
    T_COMPLEX   = _t+23,
    T_IMAGINARY = _t+24,

    T_PTR       = _t+25,
    T_ELLIPSIS  = _t+26,


    // expressions
    LIT_CHAR    = _expr,            // e.g. '\n' OPEN: add these to lexer
    LIT_INT     = _expr+1,
    LIT_DEC     = _expr+2,
    LIT_STR     = _expr+3,
    LIT_BOOL    = _expr+4,

    OP_CALL     = _expr+5,

    OP_IIF      = _expr+6,          // ? :
    OP_TF       = _expr+7,          // ditto
    OP_AND      = _expr+8,
    OP_OR       = _expr+9,

    OP_BINV     = _expr+10,         // ~ need to use xor
    OP_NOT      = _expr+11,         // !
    OP_ATTR     = _expr+12,         // e.g. x.name

    IDENT       = _expr+14,
    OP_ADDR     = _expr+15,         // &
    OP_DEREF    = _expr+16,         // *

    OP_INC      = _expr+17,
    OP_DEC      = _expr+18,
    OP_ASSIGN   = _expr+19,
    OP_NEG      = _expr+20,         // -

    // base types - w is word, l is long, s is single, d is double
    // extended types - b is byte, h is half word (for aggregate types and data defs)
    // T is wlsd, I is wl, F is sd, m is pointer (on 64-bit architectures it is the same as l)
    // simple binary expressions
    OP_ADD      = _bin,             // addT
    OP_SUB      = _bin+1,           // subT
    OP_MUL      = _bin+2,           // mulT
    OP_DIV      = _bin+3,           // divT, udivT
    OP_MOD      = _bin+4,           // udivI, remI, uremI
    OP_LSHIFT   = _bin+5,           // shlI
    OP_RSHIFT   = _bin+6,           // sarI, shrI

    OP_EQ       = _bin+7,           // ceqT
    OP_NE       = _bin+8,           // cneT
    OP_LE       = _bin+9,           // csleI, csgeI, culeI, cugeI, cleF, cgeF
    OP_LT       = _bin+10,          // csltI, csgtI, cultI, cugtI, cltF, cgtF

    OP_BAND     = _bin+11,          // andI
    OP_BOR      = _bin+12,          // orI
    OP_BXOR     = _bin+13,          // xorI


    // statements
    Label       = _stmt+1,
    If          = _stmt+2,
    IfElse      = _stmt+3,
    Else        = _stmt+4,
    While       = _stmt+5,          // for is implemented in terms of while
    Select      = _stmt+6,
    Case        = _stmt+7,
    Default     = _stmt+8,
    Goto        = _stmt+9,
    Continue    = _stmt+10,
    Break       = _stmt+11,
    Ret         = _stmt+12,
    Seq         = _stmt+13,
    Do          = _stmt+14,
    DeclVar     = _stmt+15,
    DeclVars    = _stmt+16,


    // parse tree construction
    func_def                    = _pt+1,
    pt_declaration              = _pt+2,
    pt_parameter_type_list      = _pt+3,
    pt_argument_expression_list = _pt+4,
    pt_declarator               = _pt+5,
    pt_abstract_declarator      = _pt+6,
    pt_identifier_list          = _pt+7,
    pt_init_declarator_list     = _pt+8,
    pt_init_declarator          = _pt+9,
    pt_parameter_declaration    = _pt+10,
    pt_declaration_specifiers   = _pt+11,
    pt_type_specifier           = _pt+12,
    pt_storage_class_specifier  = _pt+13,
    pt_type_qualifier           = _pt+14,
    pt_pointer                  = _pt+15,
    pt_type_qualifier_list      = _pt+16,
    pt_type_name                = _pt+17,
    pt_array                    = _pt+18,
    pt_specifier_qualifier_list = _pt+19,
    pt_function_specifier       = _pt+20,
    pt_LP_declarator_RP         = _pt+21,

};

#define OP_EXPR_START LIT_CHAR
#define OP_EXPR_END OP_BXOR
#define OP_BIN_START OP_ADD
#define OP_BIN_END OP_BXOR

// PP nodes
static char *toktopp[] = {
        [LIT_CHAR] = "LIT_CHAR",        [LIT_INT] = "LIT_INT",          [LIT_DEC] = "LIT_DEC",          [LIT_STR] = "LIT_STR",
        [LIT_BOOL] = "LIT_BOOL",
        [OP_CALL] = "OP_CALL",          [OP_ADD] = "OP_ADD",            [OP_SUB] = "OP_SUB",            [OP_MUL] = "OP_MUL",
        [OP_DIV] = "OP_DIV",            [OP_MOD] = "OP_MOD",            [OP_LSHIFT] = "OP_LSHIFT",      [OP_RSHIFT] = "OP_RSHIFT",
        [OP_EQ] = "OP_EQ",              [OP_NE] = "OP_NE",              [OP_LE] = "OP_LE",              [OP_LT] = "OP_LT",
        [OP_AND] = "OP_AND",            [OP_OR] = "OP_OR",              [OP_NOT] = "OP_NOT",            [OP_BAND] = "OP_BAND",
        [OP_BOR] = "OP_BOR",            [OP_BINV] = "OP_BINV",          [OP_BXOR] = "OP_BXOR",          [OP_IIF] = "OP_IIF",
        [OP_TF] = "OP_TF",              [IDENT] = "IDENT",              [OP_ATTR] = "OP_ATTR",
        [OP_ADDR] = "OP_ADDR",          [OP_DEREF] = "OP_DEREF",        [OP_INC] = "OP_INC",            [OP_DEC] = "OP_DEC",
        [OP_ASSIGN] = "OP_ASSIGN",      [OP_NEG] = "OP_NEG",
        [If] = "If",                    [IfElse] = "IfElse",            [Else] = "Else",                [While] = "While",
        [Select] = "Select",            [Case] = "Case",                [Default] = "Default",          [Goto] = "Goto",
        [Continue] = "Continue",        [Break] = "Break",              [Ret] = "Ret",                  [Seq] = "Seq",
        [Do] = "Do",                    [DeclVar] = "DeclVar",          [DeclVars] = "DeclVars",
        [T_TYPE_NAME] = "T_TYPE_NAME",  [T_TYPEDEF] = "T_TYPEDEF",      [T_EXTERN] = "T_EXTERN",
        [T_STATIC] = "T_STATIC",        [T_AUTO] = "T_AUTO",            [T_REGISTER] = "T_REGISTER",    [T_STRUCT] = "T_STRUCT",
        [T_UNION] = "T_UNION",          [T_CONST] = "T_CONST",          [T_RESTRICT] = "T_RESTRICT",    [T_VOLATILE] = "T_VOLATILE",
        [T_INLINE] = "T_INLINE",        [T_VOID] = "T_VOID",            [T_CHAR] = "T_CHAR",            [T_SHORT] = "T_SHORT",
        [T_INT] = "T_INT",              [T_LONG] = "T_LONG",            [T_FLOAT] = "T_FLOAT",          [T_DOUBLE] = "T_DOUBLE",
        [T_SIGNED] = "T_SIGNED",        [T_UNSIGNED] = "T_UNSIGNED",    [T_BOOL] = "T_BOOL",            [T_COMPLEX] = "T_COMPLEX",
        [T_IMAGINARY] = "T_IMAGINARY",  [T_PTR] = "T_PTR",              [T_ELLIPSIS] = "T_ELLIPSIS",
        [func_def] = "func_def",                                        [pt_declaration] = "pt_declaration",
        [pt_parameter_type_list] = "pt_parameter_type_list",            [pt_argument_expression_list] = "pt_argument_expression_list",
        [pt_declarator] = "pt_declarator",                              [pt_abstract_declarator] = "pt_abstract_declarator",
        [pt_identifier_list] = "pt_identifier_list",                    [pt_init_declarator_list] = "pt_init_declarator_list",
        [pt_init_declarator] = "pt_init_declarator",                    [pt_parameter_declaration] = "pt_parameter_declaration",
        [pt_declaration_specifiers] = "pt_declaration_specifiers",      [pt_type_specifier] = "pt_type_specifier",
        [pt_storage_class_specifier] = "pt_storage_class_specifier",    [pt_type_qualifier] = "pt_type_qualifier",
        [pt_pointer] = "pt_pointer",                                    [pt_type_qualifier_list] = "pt_type_qualifier_list",
        [pt_type_name] = "pt_type_name",                                [pt_specifier_qualifier_list] = "pt_specifier_qualifier_list",
        [pt_function_specifier] = "pt_function_specifier",              [pt_LP_declarator_RP] = "pt_LP_declarator_RP",
};


// AST, Parse Tree and AST Symbols

typedef struct Node Node;
typedef struct Symb Symb;

struct Symb {
    enum {                  // 4
        Con = 1,            // constant - integer or double with type btyp
        Str = 2,            // literal string
        Tmp = 3,            // qbe temporary - hidden from user
        Var = 4,            // local variable, with type btyp - named
        Glo = 5,            // global variable, with type btyp - numbered
        Ext = 6,            // external variable or function, with type btyp, named
        Fn  = 7,            // function, with type btyp - either a forward declare or definition
    } styp;
    int i;                  // 4 - styp defined - e.g. string number, iEllipsis
    enum btyp btyp;         // 4 (upto ***<type>)
    union {                 // 8
        int n;              // integer constant
        char *v;            // string constant, name of fn or variable (and in short term structs, unions, typedefs etc) OPEN: change v to name
//        Node *pn;           // pointer to a node
        double d;           // double constant
    } u;
};


// list of name types
struct NameType {
    char *name;             // 8
    struct NameType *next;  // 8
    enum btyp btyp;         // 4
};


// see https://peps.python.org/pep-3123/
//struct TV {
//    enum tok tok;
//};

struct Node {               // 40 bytes
//    struct TV t;            // 4
    enum tok tok;           // 4
    unsigned int lineno;    // 4
    struct Symb s;          // 4 + 4 + 8
    struct Node *l, *r;     // 8 + 8
};

//#define _t(o)    (((TV*)(o))->t)


//// https://learn.microsoft.com/en-us/cpp/cpp/argument-passing-and-naming-conventions?view=msvc-170
//// https://gcc.gnu.org/onlinedocs/gcc/x86-Function-Attributes.html
//struct Func {
//    unsigned int attrs;     // 4  inline, __cdecl, __stdcall, __fastcall, __vectorcall, exported, etc
//    unsigned int rRet;      // 4
//    struct Node * tArgs;    // 8
//};


typedef struct TLLHead TLLHead;

typedef struct NameType NameType;


// logging
enum {
    lex = 1,
    parse = 2,
    emit = 4,
    info = 8,
    error = 16,
    pt = 32,        // parse tree
};
int g_logging_level = info;     // OPEN: add filter as well as level?


// memory managers
Buckets all_strings;
BucketsCheckpoint idents_checkpoint;
Buckets nodes;


// label generation
int tmp_seed = TMP_START;
int lbl_seed = LBL_START;


// i/o streams
FILE *inf;                      // input stream, e.g. stdio or a file
FILE *of;                       // output stream, e.g. stdout
char srcFfn[1000];              // should be long enough for a filename OPEN: use a memory manager when have a string api
int isrcline = 1;               // current source line being parsed


// the literal integer 0
static Node *z;



// ---------------------------------------------------------------------------------------------------------------------
// STORAGE FOR GLOBALS
// ---------------------------------------------------------------------------------------------------------------------

int next_oglo = 1;              // 0 is reserved to mean a local variable - wasting slots below
Symb globals[NGlo];             // global literal strings, variables and functions



// ---------------------------------------------------------------------------------------------------------------------
// SYMBOL TABLE
// ---------------------------------------------------------------------------------------------------------------------

struct {
    char name[SYM_NAME_MAX];    // 32
    enum btyp btyp;             // 4
    int glo;                    // 4 - 0 means local else an offset into globals
}
_symtable[NVar];                // hash table of all defined variables - i.e. current locals and globals
Symb _tsym[1];

void symclr() {
    for (unsigned h=0; h<NVar; h++)
        if (!_symtable[h].glo)
            _symtable[h].name[0] = 0;     // set first char to NULL
}

unsigned _hash(char *s) {
    unsigned h = 42;
    while (*s) h += 11 * h + *s++;
    return h % NVar;
}

void symadd(char *name, int glo, enum btyp btyp) {
    unsigned h0 = _hash(name);
    unsigned h = h0;
    do {
        if (_symtable[h].name[0] == 0) {
            strncpy(_symtable[h].name, name, SYM_NAME_MAX);
            _symtable[h].glo = glo;
            _symtable[h].btyp = btyp;
            return;
        }
        if (strcmp(_symtable[h].name, name) == 0) {
            PP(error, "%s is already defined\n", _symtable[h].name);
            die("double definition");
        }
        h = (h+1) % NVar;
    } while(h != h0);
    die("too many variables");
}

void symset(char *name, int glo, enum btyp btyp) {
    unsigned h0 = _hash(name);
    unsigned h = h0;
    do {
        if (_symtable[h].name[0] == 0) {
            PP(error, "%s is not defined\n", _symtable[h].name);
            die("not defined");
        }
        if (strcmp(_symtable[h].name, name) == 0) {
            _symtable[h].glo = glo;
            _symtable[h].btyp = btyp;
            return;
        }
        h = (h+1) % NVar;
    } while(h != h0);
    PP(error, "%s is not defined\n", _symtable[h].name);
    die("not defined");
}

Symb * symget(char *name) {
    unsigned h0 = _hash(name);
    unsigned h = h0;
    do {
        if (strcmp(_symtable[h].name, name) == 0) {
            if (_symtable[h].glo) {
                _tsym->styp = globals[_symtable[h].glo].styp;
                _tsym->i = globals[_symtable[h].glo].i;
                _tsym->btyp = globals[_symtable[h].glo].btyp;
                switch (_tsym->styp) {
                    case Con:
                    case Str:
                        _tsym->u = globals[_symtable[h].glo].u;
                        break;
                    case Glo:
                    case Fn:
                    case Ext:
                        _tsym->u.v = _symtable[h].name;
                        break;
                    default:
                        bug("symget");
                }
            }
            else {
                _tsym->styp = Var;
                _tsym->i = 0;
                _tsym->btyp = _symtable[h].btyp;
                _tsym->u.v = _symtable[h].name;
            }
            return _tsym;
        }
        h = (h+1) % NVar;
    } while (h != h0 && _symtable[h].name[0] != 0);
    return 0;
}



// ---------------------------------------------------------------------------------------------------------------------
// HELPERS
// ---------------------------------------------------------------------------------------------------------------------

void assertTok(Node *n, char* varname, enum tok tok, int lineno) {
    if (n->tok != tok) die("%s->tok != %s @ %d", varname, toktopp[tok], lineno);
}

void assertExists(void *p, char* varname, int lineno) {
    if (!p) die("missing %s @ %d", varname, lineno);
}

void assertMissing(void *p, char* varname, int lineno) {
    if (p) die("not missing %s @ %d", varname, lineno);
}

void die_(char *preamble, char *msg, va_list args) {
    fprintf(stderr, "\nbefore end of line %d: ", isrcline);
    fprintf(stderr, "%s", preamble);
    vfprintf(stderr, msg, args);
    fprintf(stderr, "\nin %s\n\n", srcFfn);
    // OPEN: use setjmp and longjmp with deallocation of linked list of arenas
    exit(1);
}

void die(char *msg, ...) {
    va_list args;
    va_start(args, msg);
    die_("", msg, args);
    va_end(args);
}

void nyi(char *msg, ...) {
    va_list args;
    va_start(args, msg);
    die_("nyi: ", msg, args);
    va_end(args);
}

void bug(char *msg, ...) {
    va_list args;
    va_start(args, msg);
    die_("bug: ", msg, args);
    va_end(args);
}

void PP(int level, char *msg, ...) {
    if (level & g_logging_level) {
        va_list args;
        va_start(args, msg);
        vfprintf(stderr, msg, args);
        fprintf(stderr, "\n");
        va_end(args);
    }
}

void PPbtyp(int level, enum btyp t) {
    if (level & g_logging_level) {
        while (t & 0xFFFFFF00) {
            fprintf(stderr, "*");
            t >>= 8;
        }
        fprintf(stderr, "%s", btyptopp[t]);
    }
}

void putq(char *src, ...) {
    va_list args;
    va_start(args, src);
    vfprintf(of, src, args);
    va_end(args);
}

void scanLineAndSrcFfn() {
    // https://stackoverflow.com/questions/24483075/input-using-sscanf-with-regular-expression instead of regex "(?<=\")(.*)(?=\")" instead
    fscanf(inf, "%d", &isrcline);
    fscanf(inf, "%%*[^\"]");
    fscanf(inf, "\"");
    fscanf(inf, "%[^\"]", srcFfn);
}

void incLine() {isrcline++;}

int reserve_lbl(int n) {int l = lbl_seed; lbl_seed += n; return l;}
int reserve_tmp() {return tmp_seed++;}
int reserve_oglo() {return next_oglo++;}


#endif //MINC_MINC_H
