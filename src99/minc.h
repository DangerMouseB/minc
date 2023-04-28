#ifndef MINC_MINC_H
#define MINC_MINC_H

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <stdalign.h>


#define SEED_START 1


// C and QBE IR

#define _t 0
#define _lvns _t+40         // if we can fit within 31 then we can have type flags for
#define _ac _lvns+30
#define _lvse _ac+10
#define _nvse _lvse+10
#define _nvns _nvse+10

#define _pt 255

enum op {

    OP_ERROR = 0,

    // types
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
    T_SIGNED    = _t+20,
    T_UNSIGNED  = _t+21,
    T_BOOL      = _t+22,
    T_COMPLEX   = _t+23,
    T_IMAGINARY = _t+24,

    T_PTR       = _t+25,
    T_FUN       = _t+26,
    T_ELLIPSIS  = _t+27,


    // local value with no direct side effect
    Expr        = _lvns+1,

    LIT_INT     = _lvns+2,
    LIT_DEC     = _lvns+3,
    LIT_STR     = _lvns+4,
    LIT_BOOL    = _lvns+5,

    OP_CALL     = _lvns+6,

    OP_ADD      = _lvns+7,
    OP_SUB      = _lvns+8,
    OP_MUL      = _lvns+9,
    OP_DIV      = _lvns+10,
    OP_MOD      = _lvns+11,
    OP_LSHIFT   = _lvns+12,
    OP_RSHIFT   = _lvns+13,

    OP_EQ       = _lvns+14,
    OP_NE       = _lvns+15,
    OP_LE       = _lvns+16,
    OP_LT       = _lvns+17,

    OP_AND      = _lvns+18,
    OP_OR       = _lvns+19,
    OP_NOT      = _lvns+20,

    OP_BAND     = _lvns+21,
    OP_BOR      = _lvns+22,
    OP_BINV     = _lvns+23,
    OP_BXOR     = _lvns+24,

    OP_IIF      = _lvns+25,


    // access
    IDENT        = _ac+1,
    OP_ATTR     = _ac+2,       // e.g. x.name
    OP_INDEX    = _ac+3,       // e.g. xs[0]
    OP_ADDR     = _ac+4,
    OP_DEREF    = _ac+5,


    // local value with direct side effect
    OP_INC      = _lvse+1,
    OP_DEC      = _lvse+2,


    // no local value with direct side effect
    OP_ASSIGN   = _nvse+1,
    OP_ADD_EQ   = _nvse+2,
    OP_SUB_EQ   = _nvse+3,


    // no local value with no direct side effect
    Label       = _nvns+1,
    If          = _nvns+2,
    IfElse      = _nvns+3,
    Else        = _nvns+4,
    While       = _nvns+5,      // for is implemented in terms of while
    Select      = _nvns+6,
    Case        = _nvns+7,
    Default     = _nvns+8,
    Goto        = _nvns+9,
    Continue    = _nvns+10,
    Break       = _nvns+11,
    Ret         = _nvns+12,
    Seq         = _nvns+13,
    Do          = _nvns+14,


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
};


// PP nodes
static char *optopp[] = {
        [Expr] = "Expr",                [LIT_INT] = "LIT_INT",          [LIT_DEC] = "LIT_DEC",          [LIT_STR] = "LIT_STR",
        [LIT_BOOL] = "LIT_BOOL",        [OP_CALL] = "OP_CALL",          [OP_ADD] = "OP_ADD",            [OP_SUB] = "OP_SUB",
        [OP_MUL] = "OP_MUL",            [OP_DIV] = "OP_DIV",            [OP_MOD] = "OP_MOD",
        [OP_LSHIFT] = "OP_LSHIFT",      [OP_RSHIFT] = "OP_RSHIFT",      [OP_EQ] = "OP_EQ",              [OP_NE] = "OP_NE",
        [OP_LE] = "OP_LE",              [OP_LT] = "OP_LT",              [OP_AND] = "OP_AND",            [OP_OR] = "OP_OR",
        [OP_NOT] = "OP_NOT",            [OP_BAND] = "OP_BAND",          [OP_BOR] = "OP_BOR",            [OP_BINV] = "OP_BINV",
        [OP_BXOR] = "OP_BXOR",          [OP_IIF] = "OP_IIF",            [IDENT] = "IDENT",                [OP_ATTR] = "OP_ATTR",
        [OP_INDEX] = "OP_INDEX",        [OP_ADDR] = "OP_ADDR",          [OP_DEREF] = "OP_DEREF",        [OP_INC] = "OP_INC",
        [OP_DEC] = "OP_DEC",            [OP_ASSIGN] = "OP_ASSIGN",      [OP_ADD_EQ] = "OP_ADD_EQ",      [OP_SUB_EQ] = "OP_SUB_EQ",
        [If] = "If",                    [IfElse] = "IfElse",            [Else] = "Else",                [While] = "While",
        [Select] = "Select",            [Case] = "Case",                [Default] = "Default",          [Goto] = "Goto",
        [Continue] = "Continue",        [Break] = "Break",              [Ret] = "Ret",                  [Seq] = "Seq",
        [Do] = "Do",                    [T_TYPE_NAME] = "T_TYPE_NAME",  [T_TYPEDEF] = "T_TYPEDEF",      [T_EXTERN] = "T_EXTERN",
        [T_STATIC] = "T_STATIC",        [T_AUTO] = "T_AUTO",            [T_REGISTER] = "T_REGISTER",    [T_STRUCT] = "T_STRUCT",
        [T_UNION] = "T_UNION",          [T_CONST] = "T_CONST",          [T_RESTRICT] = "T_RESTRICT",    [T_VOLATILE] = "T_VOLATILE",
        [T_INLINE] = "T_INLINE",        [T_VOID] = "T_VOID",            [T_CHAR] = "T_CHAR",            [T_SHORT] = "T_SHORT",
        [T_INT] = "T_INT",              [T_LONG] = "T_LONG",            [T_FLOAT] = "T_FLOAT",          [T_DOUBLE] = "T_DOUBLE",
        [T_SIGNED] = "T_SIGNED",        [T_UNSIGNED] = "T_UNSIGNED",    [T_BOOL] = "T_BOOL",            [T_COMPLEX] = "T_COMPLEX",
        [T_IMAGINARY] = "T_IMAGINARY",  [T_PTR] = "T_PTR",              [T_FUN] = "T_FUN",              [T_ELLIPSIS] = "T_ELLIPSIS",
        [func_def] = "func_def",                                        [pt_declaration] = "pt_declaration",
        [pt_parameter_type_list] = "pt_parameter_type_list",            [pt_argument_expression_list] = "pt_argument_expression_list",
        [pt_declarator] = "pt_declarator",                              [pt_abstract_declarator] = "pt_abstract_declarator",
        [pt_identifier_list] = "pt_identifier_list",                    [pt_init_declarator_list] = "pt_init_declarator_list",
        [pt_init_declarator] = "pt_init_declarator",                    [pt_parameter_declaration] = "pt_parameter_declaration",
        [pt_declaration_specifiers] = "pt_declaration_specifiers",      [pt_type_specifier] = "pt_type_specifier",
        [pt_storage_class_specifier] = "pt_storage_class_specifier",    [pt_type_qualifier] = "pt_type_qualifier",
        [pt_pointer] = "pt_pointer",                                    [pt_type_qualifier_list] = "pt_type_qualifier_list",
};


struct Symb {
    enum op ctyp;           // 4 (upto ***)
    enum {
        Con,
        Tmp,
        Loc,
        Glo,
    } t;                    // 4
    union {
        int n;
        char *v;
        double d;
    } u;                    // 4 | 8 | 8 = 8
};


struct Node {               // 40 bytes
    struct Symb s;          // 4 + 4 + 8
    enum op op;             // 4
    unsigned int lineno;    // 4
    struct Node *l, *r;     // 8 + 8
};


struct TLLHead {
    // OPEN: remove this by changing the logic that needed this to using node
    int t;
    struct TLLHead *r;
};


struct Arena {
    void *first_chunk;      // 8
    void *current_chunk;    // 8
    void *next;             // 8
    void *eoc;              // 8
    void *last;             // 8
    unsigned short nPages;  // 2
};


typedef struct Node Node;
typedef struct Symb Symb;
typedef struct TLLHead TLLHead;
typedef struct Arena Arena;


// logging
enum {
    lex = 1,
    parse = 2,
    emit =4,
    info = 8,
    error = 16,
    pt = 32,        // parse tree
    nyi = 64,
};
int g_logging_level = info;     // OPEN: add filter as well as level?


// housekeeping
enum {
    NGlo = 256,
    NVar = 512,
    NString = 32,
};
struct Variable {
    char v[NString];
    unsigned ctyp;
    int glo;
};

int nglo;
char srcFfn[1000];     // should be long enough for a filename
char *globals[NGlo];
struct Variable varh[NVar];     // hash table of variables - current locals and globals
Arena strings;                  // literal strings
Arena idents;                   // local identifiers
Arena nodes;


int tmp = SEED_START;           // seed for temporary variables in a function
int lbl = SEED_START;           // seed for labels


FILE *of;
FILE *inf;
int srclineno;

unsigned int PAGE_SIZE = 4096;


// ---------------------------------------------------------------------------------------------------------------------
// FORWARD DECLARATIONS
// ---------------------------------------------------------------------------------------------------------------------

void * alloc(size_t s);
void PP(int level, char *msg, ...);
void die(char *msg, ...);
void *_nextChunk(Arena *a);
void *_allocChunk(size_t size);


// ---------------------------------------------------------------------------------------------------------------------
// HELPERS
// ---------------------------------------------------------------------------------------------------------------------

// arena is supposed to be fast on allocation and deallocation

void * initArena(Arena *a, unsigned long chunkSize) {
    a->first_chunk = NULL;
    a->current_chunk = NULL;
    a->next = NULL;
    a->eoc = NULL;
    a->nPages = chunkSize / PAGE_SIZE + (chunkSize % PAGE_SIZE > 0);
    return _nextChunk(a);
}

void * allocInArena(Arena *a, unsigned int n, unsigned int align) {
    void *p;
    if (n > a->nPages * PAGE_SIZE - sizeof(void*)) return NULL;      // OPEN: store pLast as well as pNextChunk in header to remove this check
    p = a->next + (align - ((unsigned long)a->next % align));
    if ((p + n) > a->eoc) {
        p = _nextChunk(a);
        if (!p) return NULL;
        p = a->next + (align - ((unsigned long)a->next % align));
    }
    a->last = p;
    a->next = p + n;
    return p;
}

void * reallocInArena(Arena *a, void* p, unsigned int n, unsigned int align) {
    if (!p  || p != a->last) return allocInArena(a, n, align);
    if (n > a->nPages * PAGE_SIZE - sizeof(void*)) return NULL;      // OPEN: store pLast as well as pNextChunk in header to remove this check
    if ((p + n) > a->eoc) {
        void *chunk = _nextChunk(a);
        if (!chunk) return NULL;
        p = a->next + (align - ((unsigned long)a->next % align));
    }
    a->last = p;
    a->next = p + n;
    return p;
}

void* _nextChunk(Arena *a) {
    void *p;
    if (!a->current_chunk) {
        p = a->current_chunk = _allocChunk(a -> nPages * PAGE_SIZE);
    } else {
        p = *(void**)a->current_chunk;                      // get next chunk in list
        if (!p) {
            p = _allocChunk(a -> nPages * PAGE_SIZE);
            if (!p) return NULL;
            *(void**)a->current_chunk = p;                  // add this chunk to the list
            a->current_chunk = p;
        }
    }
    if (!a->first_chunk) a->first_chunk = a->current_chunk;
    a->current_chunk = p;
    a->next = p + sizeof(void*);
    a->eoc = p + a->nPages * PAGE_SIZE - 1;
}

void *_allocChunk(size_t size) {
    void *p = alloc(size);                              // OPEN: cache, page and set alignment options
    if (!p) die("out of memory");
    *(void * *)p = NULL;
    return p;
}

void resetArena(Arena *a) {
    a->current_chunk = a->first_chunk;
    a->next = a->current_chunk + sizeof(void*);
    a->eoc = a->current_chunk + a->nPages * PAGE_SIZE - 1;
}

void wipeChunks(Arena *a) {
    die("freeChunks nyi");
}

void freeChunks(Arena *a) {
    die("freeChunks nyi");
}

unsigned long numChunks(Arena *a) {
    if (!a->first_chunk) return 0;
    unsigned long n = 0;
    void *p = a-> first_chunk;
    do {
        n++;
        p = *(void **)p;
    }
    while (p);
    return n;
}

Node * node(int op, Node *l, Node *r, int lineno) {
    Node *n = allocInArena(&nodes, sizeof *n, alignof n);
    n->op = op;
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

TLLHead * newTLLHead(int t, TLLHead *other) {
    TLLHead *head = alloc(sizeof *head);
    head->t = t;
    if (other != NULL) head->r = other;
    return head;
}

unsigned hash(char *s) {
    unsigned h = 42;
    while (*s) h += 11 * h + *s++;
    return h % NVar;
}

void * alloc(size_t s) {
    void *p = malloc(s);
    if (!p) die("out of memory");
    return p;
}

void die(char *msg, ...) {
    va_list args;
    fprintf(stderr, "\nline <= %d: ", srclineno);
    va_start(args, msg);
    vfprintf(stderr, msg, args);
    va_end(args);
    fprintf(stderr, "\nin %s\n\n", srcFfn);
    // OPEN: use setjmp and longjmp with deallocation of linked list of arenas
    exit(1);
}

void varclr() {
    for (unsigned h=0; h<NVar; h++)
        if (!varh[h].glo) varh[h].v[0] = 0;     // set first char to NULL
    tmp = SEED_START;
    resetArena(&idents);
}

void varadd(char *v, int glo, unsigned ctyp) {
    unsigned h0 = hash(v);
    unsigned h = h0;
    do {
        if (varh[h].v[0] == 0) {
            strcpy(varh[h].v, v);
            varh[h].glo = glo;
            varh[h].ctyp = ctyp;
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
    static Symb s;
    unsigned h0 = hash(v);
    unsigned h = h0;
    do {
        if (strcmp(varh[h].v, v) == 0) {
            if (!varh[h].glo) {
                s.t = Loc;
                strcpy(s.u.v, v);
            } else {
                s.t = Glo;
                s.u.n = varh[h].glo;
            }
            s.ctyp = varh[h].ctyp;
            return &s;
        }
        h = (h+1) % NVar;
    } while (h != h0 && varh[h].v[0] != 0);
    return 0;
}

#define IDIR(t) (((t) << 8) + T_PTR)
#define FUNC(t) (((t) << 8) + T_FUN)
#define DREF(t) ((t) >> 8)
#define KIND(t) ((t) & 255)
#define SIZE(t) (                                   \
    t == T_VOID ? (die("void has no size"), 0) : (  \
	t == T_INT ? 4 : (                              \
	8                                               \
)))

void ppCtype(unsigned long t) {
    int n = 0, i;
    while (t > 7) {
        n++;
        t = DREF(t);
    }
    switch (t) {
        case T_VOID:
            fprintf(stderr, "void ");
            break;
        case T_INT:
            fprintf(stderr, "int ");
            break;
        case T_LONG:
            fprintf(stderr, "long ");
            break;
        case T_DOUBLE:
            fprintf(stderr, "double ");
            break;
        case T_FUN:
            fprintf(stderr, "() ");
            break;
        default:
            fprintf(stderr, "%lu", t);
    }
    for (i=0; i<n; i++) {
        fprintf(stderr, "*");
    }
    return;
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

void putq(char *src, ...) {
    va_list args;
    va_start(args, src);
    vfprintf(of, src, args);
    va_end(args);
}

void scanLineAndSrcFfn() {
    // https://stackoverflow.com/questions/24483075/input-using-sscanf-with-regular-expression instead of regex "(?<=\")(.*)(?=\")" instead
    fscanf(inf, "%d", &srclineno);
    fscanf(inf, "%%*[^\"]");
    fscanf(inf, "\"");
    fscanf(inf, "%[^\"]", srcFfn);
}

void incLine() {srclineno++;}

int reserve(int n) {int l = lbl; lbl += n; return l;}

int reserveTmp() {return tmp++;}



#endif //MINC_MINC_H
