#ifndef MINC_MINC_H
#define MINC_MINC_H

#include <stddef.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdalign.h>
#include "../coppertop/bk/src/bk/k.c"
#include "../coppertop/bk/src/bk/pp.c"
#include "../coppertop/bk/src/bk/mm.c"
#include "../coppertop/bk/src/bk/tm.c"


// compiler constants (enum so get in debugger)
enum {
    NGlo = 256,
    NVar = 512,
    SYM_NAME_MAX = 32,
    TMP_START = 1,
    LBL_START = 1,
    STR_START = 1,
};


static char *btyptopp[] = {
        [B_U8] = "B_U8",                [B_U16] = "B_U16",              [B_U32] = "B_U32",              [B_U64] = "B_U64",
        [B_I8] = "B_I8",                [B_I16] = "B_I16",              [B_I32] = "B_I32",              [B_I64] = "B_I64",
        [B_F32] = "B_F32",              [B_F64] = "B_F64",
        [B_VOID_STAR] = "B_VOID_STAR",  [B_CHAR_STAR] = "B_CHAR_STAR",
        [B_VOID] = "B_VOID",            [B_VARARGS] = "B_VARARGS",
};

#define FUNC(t) (((t) << 8) + B_FN)
#define DREF(t) ((t) >> 8)
#define KIND(t) ((t) & 0xff)
#define SIZE(t) (                                   \
    t == T_VOID ? (die("void has no size"), 0) : (  \
    t == B_I32 ? 4 : (                              \
    8                                               \
)))


BK_K *_bk;

static btypeid_t _tDepointered(btypeid_t t) {
    if (tm_fitsWithin(_bk->tm, t, B_PPP)) return tm_minus(_bk->tm, t, B_PPP, 0);
    if (tm_fitsWithin(_bk->tm, t, B_PP)) return tm_minus(_bk->tm, t, B_PP, 0);
    if (tm_fitsWithin(_bk->tm, t, B_P)) return tm_minus(_bk->tm, t, B_P, 0);
    return 0;
}

static btypeid_t _tIndirect(btypeid_t t) {
    if (tm_fitsWithin(_bk->tm, t, B_PPP)) return 0;
    if (tm_fitsWithin(_bk->tm, t, B_PP)) return tm_interv(_bk->tm, 2, B_PPP, tm_minus(_bk->tm, t, B_PP, 0), 0);
    if (tm_fitsWithin(_bk->tm, t, B_P)) return tm_interv(_bk->tm, 2, B_PP, tm_minus(_bk->tm, t, B_P, 0), 0);
    return tm_interv(_bk->tm, 2, B_P, t, 0);
}

void fPPT(FILE *f, btypeid_t t) {
    int separate = 0;  btypeid_t tBase;
    tBase = _tDepointered(t);
    if (tm_fitsWithin(_bk->tm, t, B_EXTERN)) {fputs("extern", f); separate = 1;}
    if (tm_fitsWithin(_bk->tm, tBase, B_FN)) {
        if (separate) {fputc(' ', f); separate = 0;}
        fputs("(...) ->", f);
        tBase >>= 8;
        separate = 1;
    }
    if (separate) {fputc(' ', f); separate = 0;}
    while ((t & 0x000000FF) == B_P) {
        fputc('*', f);
        t >>= 8;
    }
    fputs(btyptopp[tBase], f);
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
    T_TYPE_NAME,
    T_TYPEDEF,
    T_EXTERN,
    T_STATIC,
    T_AUTO,
    T_REGISTER,
    T_STRUCT,
    T_UNION,

    T_CONST,
    T_RESTRICT,
    T_VOLATILE,
    T_INLINE,

    T_VOID,
    T_CHAR,
    T_SHORT,
    T_INT,
    T_LONG,

    T_FLOAT,
    T_DOUBLE,
    T_SIGNED,
    T_UNSIGNED,
    T_BOOL,
    T_COMPLEX,
    T_IMAGINARY,

    T_PTR,
    T_ELLIPSIS,


    // expressions
    LIT_CHAR,           // e.g. '\n' OPEN: add these to lexer
    LIT_INT,
    LIT_DEC,
    LIT_STR,
    LIT_BOOL,

    OP_CALL,

    OP_IIF,             // ? :
    OP_TF,              // ditto
    OP_AND,
    OP_OR,

    OP_BINV,            // ~ need to use xor
    OP_NOT,             // !
    OP_ATTR,            // e.g. x.name

    IDENT,
    OP_ADDR,            // &
    OP_DEREF,           // *

    OP_INC,
    OP_DEC,
    OP_ASSIGN,
    OP_NEG,             // -

    // base types - w is word, l is long, s is single, d is double
    // extended types - b is byte, h is half word (for aggregate types and data defs)
    // T is wlsd, I is wl, F is sd, m is pointer (on 64-bit architectures it is the same as l)
    // simple binary expressions
    OP_ADD,             // addT
    OP_SUB,             // subT
    OP_MUL,             // mulT
    OP_DIV,             // divT, udivT
    OP_MOD,             // udivI, remI, uremI
    OP_LSHIFT,          // shlI
    OP_RSHIFT,          // sarI, shrI

    OP_EQ,              // ceqT
    OP_NE,              // cneT
    OP_LE,              // csleI, csgeI, culeI, cugeI, cleF, cgeF
    OP_LT,              // csltI, csgtI, cultI, cugtI, cltF, cgtF

    OP_BAND,            // andI
    OP_BOR,             // orI
    OP_BXOR,            // xorI


    // statements
    Label,
    If,
    IfElse,
    Else,
    While,
    // For,               // for is implemented in terms of while
    Select,
    Case,
    Default,
    Goto,
    Continue,
    Break,
    Ret,
    Seq,
    Do,
    DeclVar,
    DeclVars,


    // parse tree construction
    pt_func_def,
    pt_declaration,
    pt_parameter_type_list,
    pt_argument_expression_list,
    pt_declarator,
    pt_abstract_declarator,
    pt_identifier_list,
    pt_init_declarator_list,
    pt_init_declarator,
    pt_parameter_declaration,
    pt_declaration_specifiers,
    pt_type_specifier,
    pt_storage_class_specifier,
    pt_type_qualifier,
    pt_pointer,
    pt_type_qualifier_list,
    pt_type_name,
    pt_array,
    pt_specifier_qualifier_list,
    pt_function_specifier,
    pt_LP_declarator_RP,

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
        [pt_func_def] = "pt_func_def",                                  [pt_declaration] = "pt_declaration",
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

struct Symb {               // 20
    enum {                  // 4
        Con = 1,            // constant - integer or double with type btyp
        Str,                // literal string
        Tmp,                // qbe temporary - hidden from user
        Var,                // local variable, with type btyp - named
        Glo,                // global variable, with type btyp - numbered
        Ext,                // external variable or function, with type btyp, named
        Fn,                 // function, with type btyp - either a forward declare or definition
    } styp;
    btypeid_t btyp;         // 4 (upto ***<type>)
    union {                 // 8
        long n;             // styp defined - integer constant, temp variable ordinal
        char *v;            // string constant, name of fn or variable (and in short term structs, unions, typedefs etc) OPEN: change v to name
        double d;           // double constant
    } u;
    int i;                  // 4 - styp defined - global string number, iEllipsis
};


// list of name types
struct NameType {
    char *name;             // 8
    struct NameType *next;  // 8
    btypeid_t btyp;         // 4
};


// see https://peps.python.org/pep-3123/

struct Node {               // 44 bytes
    enum tok tok;           // 4
    unsigned int lineno;    // 4
    struct Symb s;          // 20
    struct Node *l, *r;     // 8 + 8
};


//// https://learn.microsoft.com/en-us/cpp/cpp/argument-passing-and-naming-conventions?view=msvc-170
//// https://gcc.gnu.org/onlinedocs/gcc/x86-Function-Attributes.html
//struct Func {
//    unsigned int attrs;     // 4  inline, __cdecl, __stdcall, __fastcall, __vectorcall, exported, etc
//    unsigned int rRet;      // 4
//    struct Node * tArgs;    // 8
//};


typedef struct TLLHead TLLHead;

typedef struct NameType NameType;


// memory managers
Buckets all_strings;
BucketsCheckpoint idents_checkpoint;
Buckets nodes;


// label generation
int tmp_seed = TMP_START;
int lbl_seed = LBL_START;
int next_str = STR_START;


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
// C-TYPES
// ---------------------------------------------------------------------------------------------------------------------


void minc_createBk() {
    btypeid_t tChar, tVoid, tP, tConst, tConstP, tExtern, tFn;  btypeid_t *tl;

    BK_MM *mm = MM_create();
    Buckets *buckets = mm->malloc(sizeof(Buckets));
    initBuckets(buckets, 4096);
    _bk = K_create(mm, buckets);
    PP(info, "kernel created");

    tm_exclusion_cat(_bk->tm, "mem", btememory);
    tm_exclusion_cat(_bk->tm, "ptr", bteptr);
    tm_exclusion_cat(_bk->tm, "ccy", bteccy);

    tChar = tm_exclnominal(_bk->tm, "char", btememory, 1, B_CHAR);
    tm_exclnominal(_bk->tm, "u8", btememory, 1, B_U8);
    tm_exclnominal(_bk->tm, "u16", btememory, 2, B_U16);
    tm_exclnominal(_bk->tm, "u32", btememory, 4, B_U32);
    tm_exclnominal(_bk->tm, "u64", btememory, 8, B_U64);
    tm_exclnominal(_bk->tm, "i8", btememory, 1, B_I8);
    tm_exclnominal(_bk->tm, "i16", btememory, 2, B_I16);
    tm_exclnominal(_bk->tm, "i32", btememory, 4, B_I32);
    tm_exclnominal(_bk->tm, "i64", btememory, 8, B_I64);
    tm_exclnominal(_bk->tm, "f32", btememory, 4, B_F32);
    tm_exclnominal(_bk->tm, "f64", btememory, 8, B_F64);

    tVoid = tm_exclnominal(_bk->tm, "void", btememory, 0, B_VOID);

    tP = tm_exclnominal(_bk->tm, "P", bteptr, 8, B_P);
    tm_exclnominal(_bk->tm, "PP", bteptr, 8, B_PP);
    tm_exclnominal(_bk->tm, "PPP", bteptr, 8, B_PPP);

    tExtern = tm_nominal(_bk->tm, "extern", B_EXTERN);
    tm_nominal(_bk->tm, "static", B_STATIC);
    tm_nominal(_bk->tm, "varargs", B_VARARGS);
    tConst = tm_nominal(_bk->tm, "const", B_CONST);
    tConstP = tm_nominal(_bk->tm, "constP", B_CONST_P);
    tFn = tm_nominal(_bk->tm, "fn", B_FN);

    tl = malloc(5 * sizeof(btypeid_t));

    // char & P
    tl[0] = 2;  tl[1] = tChar;  tl[2] = tP;
    tm_inter(_bk->tm, tl, B_CHAR_STAR);

    // char & const & P
    tl[0] = 3;  tl[1] = tChar;  tl[2] = tConst;  tl[3] = tP;
    tm_inter(_bk->tm, tl, B_CHAR_CONST_STAR);

    // char & const & P & constP
    tl[0] = 4;  tl[1] = tChar;  tl[2] = tConst;  tl[3] = tP;  tl[4] = tConstP;
    tm_inter(_bk->tm, tl, B_CHAR_CONST_STAR_CONST);

    // void & P
    tl[0] = 2;  tl[1] = tVoid;  tl[2] = tP;
    tm_inter(_bk->tm, tl, B_VOID_STAR);

    // fn & P
    tl[0] = 2;  tl[1] = tFn;  tl[2] = tP;
    tm_inter(_bk->tm, tl, B_FN_PTR);

    // fn & extern
    tl[0] = 2;  tl[1] = tFn;  tl[2] = tExtern;
    tm_inter(_bk->tm, tl, B_EXTERN_FN);

    // fn & extern & p
    tl[0] = 3;  tl[1] = tFn;  tl[2] = tP;  tl[3] = tExtern;
    tm_inter(_bk->tm, tl, B_EXTERN_FN_PTR);

    free(tl);

}



// ---------------------------------------------------------------------------------------------------------------------
// SYMBOL TABLE
// ---------------------------------------------------------------------------------------------------------------------

struct {
    char name[SYM_NAME_MAX];    // 32
    btypeid_t btyp;             // 4
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

void symadd(char *name, int glo, btypeid_t btyp) {
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

void symset(char *name, int glo, btypeid_t btyp) {
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

pvt void die_(char *preamble, char *msg, va_list args) {
    fprintf(stderr, "\nbefore end of line %d: ", isrcline);
    fprintf(stderr, "%s", preamble);
    vfprintf(stderr, msg, args);
    fprintf(stderr, "\nin %s\n\n", srcFfn);
    // OPEN: use setjmp and longjmp with deallocation of linked list of arenas
    exit(1);
}

void PPbtyp(int level, btypeid_t t) {
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
int reserve_str() {return next_str++;}
int reserve_oglo() {return next_oglo++;}


#endif //MINC_MINC_H
