#ifndef MINC_MINC_H
#define MINC_MINC_H

#include <stddef.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdalign.h>
#include "aj.h"

#define SEED_START 0


// C and QBE IR

#define INDENT "\t"


// ---------------------------------------------------------------------------------------------------------------------
// btyp enum
// this just here to allow CLion to make life easier when debugging - eventually will replace with B_TYPE_ID
// ---------------------------------------------------------------------------------------------------------------------

#define _hc1 0
#define _hc2 20

enum btyp{
    B_ILLEGAL = 0,          // to catch bugs
    B_U8  = _hc1+1,         // char, unsigned char
    B_U16 = _hc1+2,         // unsigned short
    B_U32 = _hc1+3,         // signed int
    B_U64 = _hc1+4,         // unsigned long, unsigned long int
    B_I8  = _hc1+5,         // signed char
    B_I16 = _hc1+6,         // short, signed short
    B_I32 = _hc1+7,         // int, signed int
    B_I64 = _hc1+8,         // long, long int, signed long, signed long int

    B_F32 = _hc1+9,         // float
    B_F64 = _hc1+10,        // double

    B_CHARS = _hc1 + 11,    // null terminated uft-8 array, char*
    B_N_CHARS = _hc1 + 12,  // N**chars, char*argv[], char**
    B_TXT = _hc1+13,        // txt (length prefixed, null terminated uft-8 array)
    B_NN_I32 = _hc1+14,     // int **, signed int **
    B_N_I32 = _hc1+15,      // int *, signed int *
    B_VOID_STAR = _hc1+16,

    B_VOID = _hc2+1,
    B_VARARGS = _hc2+2,
    B_U8_S = _hc2+3,
    B_N_MEM = _hc2+4,       // N**MEM, implemented as void **
    B_PTR = 254,            // HACK
    B_FN = 255,             // HACK
};

static char *btyptopp[] = {
        [B_ILLEGAL] = "B_ILLEGAL",
        [B_U8] = "B_U8",                [B_U16] = "B_U16",              [B_U32] = "B_U32",              [B_U64] = "B_U64",
        [B_I8] = "B_I8",                [B_I16] = "B_I16",              [B_I32] = "B_I32",              [B_I64] = "B_I64",
        [B_F32] = "B_F32",              [B_F64] = "B_F64",              [B_CHARS] = "B_CHARS",          [B_N_CHARS] = "B_N_CHARS",
        [B_TXT] = "B_TXT",              [B_NN_I32] = "B_NN_I32",        [B_N_I32] = "B_N_I32",          [B_VOID_STAR] = "B_VOID_STAR",
        [B_VOID] = "B_VOID",            [B_VARARGS] = "B_VARARGS",      [B_U8_S] = "B_U8_S",            [B_N_MEM] = "B_N_MEM",
};

// implementation defined (poss with compiler flags)
#define B_CHAR_DEFAULT B_I8

#define IDIR(t) (((t) << 8) + B_PTR)
#define FUNC(t) (((t) << 8) + B_FN)
#define DREF(t) ((t) >> 8)
#define KIND(t) ((t) & 255)
#define SIZE(t) (                                   \
    t == T_VOID ? (die("void has no size"), 0) : (  \
	t == B_I32 ? 4 : (                              \
	8                                               \
)))


// ---------------------------------------------------------------------------------------------------------------------
// FORWARD DECLARATIONS
// ---------------------------------------------------------------------------------------------------------------------

void PP(int level, char *msg, ...);
void die(char *msg, ...);
unsigned hash(char *s);


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
    OP_INDEX    = _expr+13,         // e.g. xs[0]

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

};

#define OP_EXPR_START LIT_CHAR
#define OP_EXPR_END OP_BIN_END
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
        [OP_TF] = "OP_TF",              [IDENT] = "IDENT",              [OP_ATTR] = "OP_ATTR",          [OP_INDEX] = "OP_INDEX",
        [OP_ADDR] = "OP_ADDR",          [OP_DEREF] = "OP_DEREF",        [OP_INC] = "OP_INC",            [OP_DEC] = "OP_DEC",
        [OP_ASSIGN] = "OP_ASSIGN",      [OP_NEG] = "OP_NEG",
        [If] = "If",                    [IfElse] = "IfElse",            [Else] = "Else",                [While] = "While",
        [Select] = "Select",            [Case] = "Case",                [Default] = "Default",          [Goto] = "Goto",
        [Continue] = "Continue",        [Break] = "Break",              [Ret] = "Ret",                  [Seq] = "Seq",
        [Do] = "Do",                    [T_TYPE_NAME] = "T_TYPE_NAME",  [T_TYPEDEF] = "T_TYPEDEF",      [T_EXTERN] = "T_EXTERN",
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
        [pt_function_specifier] = "pt_function_specifier",
};


struct Symb {
    enum btyp btyp;         // 4 (upto ***<type>)
    enum {
        Con,                // constant
        Tmp,                // temporary
        Var,                // variable
        Glo,                // global
    } t;                    // 4
    union {
        int n;
        char *v;
        double d;
    } u;                    // 4 | 8 | 8 = 8
};


struct NameType {
    char *name;             // 8
    struct NameType *next;  // 8
    enum btyp btyp;           // 4
};


// hResult = disp(add2, PTR(s->l), COUNT(5), PTR(&res));


// if typ were 8 bytes we could use NaN boxing - but for the compiler unnecessary - however we could reuse the jones
// runtime here
// see https://peps.python.org/pep-3123/
//struct TV {
//    enum tok t;
//};

struct Node {               // 40 bytes
//    struct TV t;            // 4
    enum tok tok;             // 4
    unsigned int lineno;    // 4
    struct Symb s;          // 4 + 4 + 8
    struct Node *l, *r;     // 8 + 8
};

//#define _t(o)    (((TV*)(o))->t)


// https://learn.microsoft.com/en-us/cpp/cpp/argument-passing-and-naming-conventions?view=msvc-170
// https://gcc.gnu.org/onlinedocs/gcc/x86-Function-Attributes.html
struct Func {
    unsigned int attrs;     // 4  inline, __cdecl, __stdcall, __fastcall, __vectorcall, exported, etc
    unsigned int rRet;      // 4
    struct Node * tArgs;    // 8
};

typedef struct Node Node;
typedef struct Symb Symb;
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


// housekeeping
enum {
    NGlo = 256,
    NVar = 512,
    NString = 32,
};
struct Variable {
    char v[NString];    //32
    enum btyp btyp;
    int glo;
};

int oglo;
char srcFfn[1000];              // should be long enough for a filename
char *globals[NGlo];
struct Variable varh[NVar];     // hash table of variables - current locals and globals
Arena strings;                  // literal strings
Arena idents;                   // local identifiers
ArenaState savedidents;
Arena nodes;
Symb varBuf[1];
char varnameBuf[NString];

int tmp = SEED_START;           // seed for temporary variables in a function
int lbl = SEED_START;           // seed for labels

FILE *of;
FILE *inf;
int isrcline = 1;



void varclr() {
    for (unsigned h=0; h<NVar; h++)
        if (!varh[h].glo) varh[h].v[0] = 0;     // set first char to NULL
    tmp = SEED_START;
    resetToCheckpoint(&idents, &savedidents);
}

void varadd(char *v, int glo, enum btyp btyp) {
    unsigned h0 = hash(v);
    unsigned h = h0;
    do {
        if (varh[h].v[0] == 0) {
            strcpy(varh[h].v, v);
            varh[h].glo = glo;
            varh[h].btyp = btyp;
            return;
        }
        if (strcmp(varh[h].v, v) == 0) {
            PP(error, "%s is already defined\n", varh[h].v);
            die("double definition");
        }
        h = (h+1) % NVar;
    } while(h != h0);
    die("too many variables");
}

Symb * varget(char *v) {
    unsigned h0 = hash(v);
    unsigned h = h0;
    do {
        if (strcmp(varh[h].v, v) == 0) {
            if (!varh[h].glo) {
                varBuf->t = Var;
                strcpy(varnameBuf, v);
                varBuf->u.v = varnameBuf;
            } else {
                varBuf->t = Glo;
                varBuf->u.n = varh[h].glo;
            }
            varBuf->btyp = varh[h].btyp;
            return varBuf;
        }
        h = (h+1) % NVar;
    } while (h != h0 && varh[h].v[0] != 0);
    return 0;
}


// ---------------------------------------------------------------------------------------------------------------------
// HELPERS
// ---------------------------------------------------------------------------------------------------------------------

unsigned hash(char *s) {
    unsigned h = 42;
    while (*s) h += 11 * h + *s++;
    return h % NVar;
}

void assertTok(Node *n, char* varname, enum tok tok, int lineno) {
    if (n->tok != tok) die("%s->tok != %s @ %d", varname, toktopp[tok], lineno);
}

void assertExists(void *p, char* varname, int lineno) {
    if (!p) die("missing %s @ %d", varname, lineno);
}

Node * node(int tok, Node *l, Node *r, int lineno) {
    Node *n = allocInArena(&nodes, sizeof *n, alignof (n));
    n->tok = tok;
    n->l = l;
    n->r = r;
    n->lineno = lineno;
    return n;
}

Node * bindl(Node *n, Node *l, int lineno) {
    if (n->l != 0) {
        PP(parse, "bindl from @%d", lineno);
        die("node.l already bound");
    }
    n->l = l;
    return n;
}

Node * bindr(Node *n, Node *r, int lineno) {
    if (n->r != 0) {
        PP(parse, "bindr from @%d", lineno);
        die("2nd arg of fn already bound");
    }
    n->r = r;
    return n;
}

Node * bindlr(Node *n, Node *l, Node *r, int lineno) {
    if (n->l != 0) {PP(parse, "bindlr from @%d", lineno); die("n.l already bound");}
    if (n->r != 0) {PP(parse, "bindlr from @%d", lineno); die("n.r already bound");}
    n->l = l;
    n->r = r;
    return n;
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
        while (t && 0xFFFFFF00) {
            fprintf(stderr, "*");
            t >>= 8;
        }
        fprintf(stderr, btyptopp[t]);
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

int reserve(int n) {int l = lbl; lbl += n; return l;}

int reserveTmp() {return tmp++;}


#endif //MINC_MINC_H
