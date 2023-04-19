%{
/*Beginning of C declarations*/

// NAMING CONVENTION
// TOKEN            (including T_TYPENAME_)
// OP_OPERATION     (e.g. OP_ADD, except NAME, LIT_INT, LIT_DEC, LIT_STR)
// T_TYPE


#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

enum {
    NString = 32,
    NGlo = 256,
    NVar = 512,
    NStr = 256,
};

enum {
    T_VOID,
    T_INT,
    T_LNG,
    T_DBL,
    T_PTR,
    T_FUN,
};

#define IDIR(x) (((x) << 3) + T_PTR)
#define FUNC(x) (((x) << 3) + T_FUN)
#define DREF(x) ((x) >> 3)
#define KIND(x) ((x) & 7)
#define SIZE(x) (                                   \
    x == T_VOID ? (die("void has no size"), 0) : (  \
	x == T_INT ? 4 : (                              \
	8                                               \
)))

#define OP_CALL 'C'
#define OP_ASSIGN '='

#define OP_EQ   'e'
#define OP_NE   'n'
#define OP_LE   'l'
#define OP_LT   '<'
#define OP_AND  'a'
#define OP_OR   'o'

#define OP_BAND '&'
#define OP_BOR  '|'
#define OP_BINV '~'
#define OP_BXOR '^'

#define OP_ADD  '+'
#define OP_SUB  '-'
#define OP_MUL  '*'
#define OP_DIV  '/'
#define OP_REM  '%'

#define OP_DEREF '@'
#define OP_ADDR  'A'

#define OP_PP   'P'
#define OP_MM   'M'

#define NAME    'V'
#define LIT_INT 'N'
#define LIT_DEC 'D'


enum {
    L_LEX = 1,
    L_PARSE = 2,
    L_EMIT = 3,
};

int LOG = L_LEX | L_PARSE | L_EMIT;


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
        case T_LNG:
            fprintf(stderr, "long ");
            break;
        case T_DBL:
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



#define GLOBAL "$g"
#define TEMP "%%t"
#define LOCAL "%%_"
#define LABEL "@L"


typedef struct Node Node;
typedef struct Symb Symb;
typedef struct Stmt Stmt;
typedef struct TLLHead TLLHead;



int yylex(void);
void yyerror(char const *);
Symb emitexpr(Node *);
Symb lval(Node *);
void emitboolop(Node *, int, int);
void * alloc(size_t s);



struct Symb {
    enum {
        Con,
        Tmp,
        Var,
        Glo,
    } t;
    union {
        int n;
        char v[NString];
        double d;
    } u;
    unsigned long ctyp;
};


struct TLLHead {
    int t;
    TLLHead *r;
};

TLLHead * newTLLHead(int t, TLLHead *other) {
    TLLHead *head = alloc(sizeof *head);
    head->t = t;
    if (other != NULL) head->r = other;
    return head;
}


struct Node {
    char op;
    union {
        int n;
        char v[NString];
        Symb s;
        double d;
    } u;
    Node *l, *r;
};

Node * newNode(char op, Node *l, Node *r) {
    Node *n = alloc(sizeof *n);
    n->op = op;
    n->l = l;
    n->r = r;
    return n;
}


struct Stmt {
    enum {
        If,
        While,
        Seq,
        Expr,
        Break,
        Ret,
    } t;
    void *p1, *p2, *p3;
};

Stmt * newstmt(int t, void *p1, void *p2, void *p3) {
    Stmt *s = alloc(sizeof *s);
    s->t = t;
    s->p1 = p1;
    s->p2 = p2;
    s->p3 = p3;
    return s;
}



// OPEN: put these on a context (almost as fast as globals but faster than putting everything on the stack
// so top context becomes an indirect through a global and is a struct, i.e. with known offsets - could used scratch
FILE *of;
int line, lbl, tmp, nglo;
char *ini[NGlo];
struct {
    char v[NString];
    unsigned ctyp;
    int glo;
} varh[NVar];
char currentFFN[1000];     // should be long enough for a filename


void die(char *s) {
    fprintf(stderr, "\nline <= %d: %s\n", line, s);
    fprintf(stderr, "in %s\n\n", currentFFN);
    // OPEN: use setjmp and longjmp with deallocation of linked list of arenas
    exit(1);
}


void * alloc(size_t s) {
    // OPEN: do a linked list of arenas - so can unwind more safely in Python
    void *p = malloc(s);
    if (!p) die("out of memory");
    return p;
}


unsigned hash(char *s) {
    unsigned h = 42;
    while (*s) h += 11 * h + *s++;
    return h % NVar;
}


void varclr() {
    for (unsigned h=0; h<NVar; h++)
        if (!varh[h].glo) varh[h].v[0] = 0;
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
            fprintf(stderr, "%s is already defined\n", varh[h].v);
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
                s.t = Var;
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


char irtyp(unsigned ctyp) {
    switch (KIND(ctyp)) {
        case T_VOID: die("void has no size");
        case T_INT: return 'w';
        case T_LNG: return 'l';
        case T_DBL: return 'd';
        case T_PTR: return 'l';
        case T_FUN: return 'l';
    }
    die("unhandled type");
    return 'l';
}


void emitsymb(Symb s) {
    switch (s.t) {
        case Tmp:
            fprintf(of, TEMP "%d", s.u.n);
            break;
        case Var:
            fprintf(of, LOCAL "%s", s.u.v);
            break;
        case Glo:
            fprintf(of, GLOBAL "%d", s.u.n);
            break;
        case Con:
            fprintf(of, "%d", s.u.n);
            break;
    }
}


void l_extsw(Symb *s) {
    fprintf(of, "\t" TEMP "%d =l extsw ", tmp);
    emitsymb(*s);
    fprintf(of, "\n");
    s->t = Tmp;
    s->ctyp = T_LNG;
    s->u.n = tmp++;
}


void d_swtof(Symb *s) {
    fprintf(of, "\t" TEMP "%d =d swtof ", tmp);
    emitsymb(*s);
    fprintf(of, "\n");
    s->t = Tmp;
    s->ctyp = T_DBL;
    s->u.n = tmp++;
}


void d_sltof(Symb *s) {
    fprintf(of, "\t" TEMP "%d =d sltof ", tmp);
    emitsymb(*s);
    fprintf(of, "\n");
    s->t = Tmp;
    s->ctyp = T_DBL;
    s->u.n = tmp++;
}


unsigned prom(int op, Symb *l, Symb *r) {
    Symb *t;
    int sz;

    if (l->ctyp == r->ctyp && KIND(l->ctyp) != T_PTR)
        return l->ctyp;

    if (l->ctyp == T_LNG && r->ctyp == T_INT) {
        l_extsw(r);
        return T_LNG;
    }
    if (l->ctyp == T_INT && r->ctyp == T_LNG) {
        l_extsw(l);
        return T_LNG;
    }
    if (l->ctyp == T_DBL && r->ctyp == T_INT) {
        d_swtof(r);
        return T_DBL;
    }
    if (l->ctyp == T_DBL && r->ctyp == T_LNG) {
        d_sltof(r);
        return T_DBL;
    }

    if (op == OP_ADD) {
        // OPEN: handle double
        if (KIND(r->ctyp) == T_PTR) {
            t = l;
            l = r;
            r = t;
        }
        if (KIND(r->ctyp) == T_PTR) die("pointers added");
        goto Scale;
    }

    if (op == OP_SUB) {
        // OPEN: handle double
        if (KIND(l->ctyp) != T_PTR) die("pointer substracted from integer");
        if (KIND(r->ctyp) != T_PTR) goto Scale;
        if (l->ctyp != r->ctyp) die("non-homogeneous pointers in substraction");
        return T_LNG;
    }

Scale:
    // OPEN: handle double
    sz = SIZE(DREF(l->ctyp));
    if (r->t == Con)
        r->u.n *= sz;
    else {
        if (irtyp(r->ctyp) != 'l') l_extsw(r);
        fprintf(of, "\t" TEMP "%d =l mul %d, ", tmp, sz);
        emitsymb(*r);
        fprintf(of, "\n");
        r->u.n = tmp++;
    }
    return l->ctyp;
}


void emitload(Symb d, Symb s) {
    fprintf(of, "\t");
    emitsymb(d);
    fprintf(of, " =%c load%c ", irtyp(d.ctyp), irtyp(d.ctyp));
    emitsymb(s);
    fprintf(of, "\n");
}


void emitcall(Node *n, Symb *sr) {
    Node *a;  unsigned ft;
    char *f = n->l->u.v;
    if (varget(f)) {
        ft = varget(f)->ctyp;
        if (KIND(ft) != T_FUN) die("invalid call");
    } else
        ft = FUNC(T_INT);
    sr->ctyp = DREF(ft);
    for (a=n->r; a; a=a->r)
        a->u.s = emitexpr(a->l);
    fprintf(of, "\t");
    emitsymb(*sr);
    fprintf(of, " =%c call $%s(", irtyp(sr->ctyp), f);
    for (a=n->r; a; a=a->r) {
        fprintf(of, "%c ", irtyp(a->u.s.ctyp));
        emitsymb(a->u.s);
        fprintf(of, ", ");
    }
    fprintf(of, "...)\n");
}


Symb emitexpr(Node *n) {
    static char *otoa[] = {
            [OP_ADD] = "add",
            [OP_SUB] = "sub",
            [OP_MUL] = "mul",
            [OP_DIV] = "div",
            [OP_REM] = "rem",
            [OP_BAND] = "and",
            [OP_LT] = "cslt",  /* meeeeh, wrong for pointers! */
            [OP_LE] = "csle",
            [OP_EQ] = "ceq",
            [OP_NE] = "cne",
    };
    Symb sr, s0, s1, sl;
    int o, l;
    char ty[2];

    sr.t = Tmp;
    sr.u.n = tmp++;

    switch (n->op) {

        case 0:
            abort();

        case OP_OR:
            die("|| NYI");

        case OP_AND:
            l = lbl;
            lbl += 3;
            emitboolop(n, l, l+1);
            fprintf(of, LABEL "%d\n", l);
            fprintf(of, "\tjmp " LABEL "%d\n", l+2);
            fprintf(of, LABEL "%d\n", l+1);
            fprintf(of, "\tjmp " LABEL "%d\n", l+2);
            fprintf(of, LABEL "%d\n", l+2);
            fprintf(of, "\t");
            sr.ctyp = T_INT;
            emitsymb(sr);
            fprintf(of, " =w phi " LABEL "%d 1, " LABEL "%d 0\n", l, l+1);
            break;

        case NAME:
            s0 = lval(n);
            sr.ctyp = s0.ctyp;
            emitload(sr, s0);
            break;

        case LIT_DEC:
            sr.t = Con;
            sr.u.d = n->u.d;
            sr.ctyp = T_DBL;
            break;

        case LIT_INT:
            sr.t = Con;
            sr.u.n = n->u.n;
            sr.ctyp = T_INT;
            break;

        case 'S':
            sr.t = Glo;
            sr.u.n = n->u.n;
            sr.ctyp = IDIR(T_INT);
            break;

        case OP_CALL:
            emitcall(n, &sr);
            break;

        case OP_DEREF:
            s0 = emitexpr(n->l);
            if (KIND(s0.ctyp) != T_PTR)
                die("dereference of a non-pointer");
            sr.ctyp = DREF(s0.ctyp);
            emitload(sr, s0);
            break;

        case OP_ADDR:
            sr = lval(n->l);
            sr.ctyp = IDIR(sr.ctyp);
            break;

        case OP_ASSIGN:
            s0 = emitexpr(n->r);
            s1 = lval(n->l);
            sr = s0;
            if (s1.ctyp == T_LNG && s0.ctyp == T_INT) l_extsw(&s0);
            if (s1.ctyp == T_DBL && s0.ctyp == T_INT) d_swtof(&s0);
            if (s1.ctyp == T_DBL && s0.ctyp == T_LNG) d_sltof(&s0);
            if (s0.ctyp != IDIR(T_VOID) || KIND(s1.ctyp) != T_PTR)
                if (s1.ctyp != IDIR(T_VOID) || KIND(s0.ctyp) != T_PTR)
                    if (s1.ctyp != s0.ctyp) {
                        ppCtype(s1.ctyp);
                        fprintf(stderr, "%s = ", s1.u.v);
                        ppCtype(s0.ctyp);
                        fprintf(stderr, "\n");
                        die("invalid assignment");
                    }
            fprintf(of, "\tstore%c ", irtyp(s1.ctyp));
            goto Args;

        case OP_PP:
        case OP_MM:
            o = n->op == OP_PP ? OP_ADD : OP_SUB;
            sl = lval(n->l);
            s0.t = Tmp;
            s0.u.n = tmp++;
            s0.ctyp = sl.ctyp;
            emitload(s0, sl);
            s1.t = Con;
            s1.u.n = 1;
            s1.ctyp = T_INT;
            goto Binop;

        default:
            s0 = emitexpr(n->l);
            s1 = emitexpr(n->r);
            o = n->op;
        Binop:
            sr.ctyp = prom(o, &s0, &s1);
            if (strchr("ne<l", n->op)) {
                sprintf(ty, "%c", irtyp(sr.ctyp));
                sr.ctyp = T_INT;
            } else
                strcpy(ty, "");
            fprintf(of, "\t");
            emitsymb(sr);
            fprintf(of, " =%c", irtyp(sr.ctyp));
            fprintf(of, " %s%s ", otoa[o], ty);
        Args:
            emitsymb(s0);
            fprintf(of, ", ");
            emitsymb(s1);
            fprintf(of, "\n");
            break;

    }
    if (n->op == OP_SUB  &&  KIND(s0.ctyp) == T_PTR  &&  KIND(s1.ctyp) == T_PTR) {
        fprintf(of, "\t" TEMP "%d =l div ", tmp);
        emitsymb(sr);
        fprintf(of, ", %d\n", SIZE(DREF(s0.ctyp)));
        sr.u.n = tmp++;
    }
    if (n->op == OP_PP  ||  n->op == OP_MM) {
        fprintf(of, "\tstore%c ", irtyp(sl.ctyp));
        emitsymb(sr);
        fprintf(of, ", ");
        emitsymb(sl);
        fprintf(of, "\n");
        sr = s0;
    }
    return sr;
}


Symb lval(Node *n) {
    Symb sr;
    switch (n->op) {
        default:
            die("invalid lvalue");
        case NAME:
            if (!varget(n->u.v)) {
                fprintf(stderr, "%s is not defined\n", n->u.v);
                die("undefined variable");
            }
            sr = *varget(n->u.v);
            break;
        case OP_DEREF:
            sr = emitexpr(n->l);
            if (KIND(sr.ctyp) != T_PTR) die("dereference of a non-pointer");
            sr.ctyp = DREF(sr.ctyp);
            break;
    }
    return sr;
}


void emitboolop(Node *n, int lt, int lf) {
    Symb s;  int l;
    switch (n->op) {
        default:
            s = emitexpr(n); /* TODO: insert comparison to 0 with proper type */
            fprintf(of, "\tjnz ");
            emitsymb(s);
            fprintf(of, ", " LABEL "%d, " LABEL "%d\n", lt, lf);
            break;
        case OP_OR:
            l = lbl;
            lbl += 1;
            emitboolop(n->l, lt, l);
            fprintf(of, LABEL "%d\n", l);
            emitboolop(n->r, lt, lf);
            break;
        case OP_AND:
            l = lbl;
            lbl += 1;
            emitboolop(n->l, l, lf);
            fprintf(of, LABEL "%d\n", l);
            emitboolop(n->r, lt, lf);
            break;
    }
}


int emitstmt(Stmt *s, int b) {
    int l, r;  Symb x;

    if (!s) return 0;

    switch (s->t) {
        case Ret:
            x = emitexpr(s->p1);
            fprintf(of, "\tret ");
            emitsymb(x);
            fprintf(of, "\n");
            return 1;
        case Break:
            if (b < 0) die("break not in loop");
            fprintf(of, "\tjmp " LABEL "%d\n", b);
            return 1;
        case Expr:
            emitexpr(s->p1);
            return 0;
        case Seq:
            return emitstmt(s->p1, b) || emitstmt(s->p2, b);
        case If:
            l = lbl;
            lbl += 3;
            emitboolop(s->p1, l, l+1);
            fprintf(of, LABEL "%d\n", l);
            if (!(r=emitstmt(s->p2, b)))
                if (s->p3)
                    fprintf(of, "\tjmp " LABEL "%d\n", l+2);
            fprintf(of, LABEL "%d\n", l+1);
            if (s->p3)
                if (!(r &= emitstmt(s->p3, b)))
                    fprintf(of, LABEL "%d\n", l+2);
            return s->p3 && r;
        case While:
            l = lbl;
            lbl += 3;
            fprintf(of, LABEL "%d\n", l);
            emitboolop(s->p1, l+1, l+2);
            fprintf(of, LABEL "%d\n", l+1);
            if (!emitstmt(s->p2, l+2))
                fprintf(of, "\tjmp " LABEL "%d\n", l);
            fprintf(of, LABEL "%d\n", l+2);
            return 0;
    }
}


Node * mkidx(Node *a, Node *i) {
    Node *n = newNode(OP_ADD, a, i);
    n = newNode(OP_DEREF, n, 0);
    return n;
}


Node * mkneg(Node *n) {
    static Node *z;
    if (!z) {
        z = newNode(LIT_INT, 0, 0);
        z->u.n = 0;
    }
    return newNode(OP_SUB, z, n);
}


Node * mkparam(char *v, unsigned ctyp, Node *pl) {
    if (ctyp == T_VOID) die("invalid void declaration");
    Node *n = newNode(0, 0, pl);
    varadd(v, 0, ctyp);
    strcpy(n->u.v, v);
    return n;
}


Stmt * mkfor(Node *ini, Node *tst, Node *inc, Stmt *s) {
    Stmt *s1, *s2;

    if (ini)
        s1 = newstmt(Expr, ini, 0, 0);
    else
        s1 = 0;
    if (inc) {
        s2 = newstmt(Expr, inc, 0, 0);
        s2 = newstmt(Seq, s, s2, 0);
    } else
        s2 = s;
    if (!tst) {
        tst = newNode(LIT_INT, 0, 0);
        tst->u.n = 1;
    }
    s2 = newstmt(While, tst, s2, 0);
    if (s1)
        return newstmt(Seq, s1, s2, 0);
    else
        return s2;
}


void initFunc() {
    if (LOG & L_EMIT) fprintf(stderr, "initFunc\n");
    varclr(); tmp = 0;
}


void startFunc(int t, Node *fnname, Node *params) {
    Symb *s;  Node *n;  int i, m;

    if (LOG & L_EMIT) fprintf(stderr, "startFunc\n");

    varadd(fnname->u.v, 1, FUNC(T_INT));
    fprintf(of, "export function w $%s(", fnname->u.v);
    n = params;
    if (n)
        for (;;) {
            s = varget(n->u.v);
            fprintf(of, "%c ", irtyp(s->ctyp));
            fprintf(of, TEMP "%d", tmp++);
            n = n->r;
            if (n)
                fprintf(of, ", ");
            else
                break;
        }
    fprintf(of, ") {\n");
    fprintf(of, LABEL "%d\n", lbl++);
    for (i=0, n=params; n; i++, n=n->r) {
        s = varget(n->u.v);
        m = SIZE(s->ctyp);
        fprintf(of, "\t" LOCAL "%s =l alloc%d %d\n", n->u.v, m, m);
        fprintf(of, "\tstore%c " TEMP "%d", irtyp(s->ctyp), i);
        fprintf(of, ", " LOCAL "%s\n", n->u.v);
    }
}


void finishFunc(Stmt *s) {
    if (LOG & L_EMIT) fprintf(stderr, "finishFunc\n\n");
    if (!emitstmt(s, -1)) fprintf(of, "\tret 0\n");
    fprintf(of, "}\n\n");
}


void emitLocalDecl(int t, Node *varname) {
    if (LOG & L_EMIT) fprintf(stderr, "emitLocalDecl\n");
    // OPEN: allow multiple names for each type
    int s;  char *v;
    if (t == T_VOID) die("invalid void declaration");
    v = varname->u.v;
    s = SIZE(t);
    varadd(v, 0, t);
    fprintf(of, "\t" LOCAL "%s =l alloc%d %d\n", v, s, s);
}


void collectGlobal(int t, Node *globalname) {
    if (t == T_VOID) die("invalid void declaration");
    if (nglo == NGlo) die("too many string literals");
    ini[nglo] = alloc(sizeof "{ x 0 }");
    sprintf(ini[nglo], "{ %c 0 }", irtyp(t));
    varadd(globalname->u.v, nglo++, t);
}


/*End of C declarations*/
%}


%union {
    Node *n;
    TLLHead *t;
    Stmt *s;
    unsigned u;
}

%token <n> IDENTIFIER CONSTANT STRING_LITERAL
%token SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER INLINE RESTRICT
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token BOOL COMPLEX IMAGINARY
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%start translation_unit
%%

primary_expression
: IDENTIFIER
| CONSTANT
| STRING_LITERAL
| '(' expression ')'
;

postfix_expression
: primary_expression
| postfix_expression '[' expression ']'
| postfix_expression '(' ')'
| postfix_expression '(' argument_expression_list ')'
| postfix_expression '.' IDENTIFIER
| postfix_expression PTR_OP IDENTIFIER
| postfix_expression INC_OP
| postfix_expression DEC_OP
| '(' type_name ')' '{' initializer_list '}'
| '(' type_name ')' '{' initializer_list ',' '}'
;

argument_expression_list
: assignment_expression
| argument_expression_list ',' assignment_expression
;

unary_expression
: postfix_expression
| INC_OP unary_expression
| DEC_OP unary_expression
| unary_operator cast_expression
| SIZEOF unary_expression
| SIZEOF '(' type_name ')'
;

unary_operator
: '&'
| '*'
| '+'
| '-'
| '~'
| '!'
;

cast_expression
: unary_expression
| '(' type_name ')' cast_expression
;

multiplicative_expression
: cast_expression
| multiplicative_expression '*' cast_expression
| multiplicative_expression '/' cast_expression
| multiplicative_expression '%' cast_expression
;

additive_expression
: multiplicative_expression
| additive_expression '+' multiplicative_expression
| additive_expression '-' multiplicative_expression
;

shift_expression
: additive_expression
| shift_expression LEFT_OP additive_expression
| shift_expression RIGHT_OP additive_expression
;

relational_expression
: shift_expression
| relational_expression '<' shift_expression
| relational_expression '>' shift_expression
| relational_expression LE_OP shift_expression
| relational_expression GE_OP shift_expression
;

equality_expression
: relational_expression
| equality_expression EQ_OP relational_expression
| equality_expression NE_OP relational_expression
;

and_expression
: equality_expression
| and_expression '&' equality_expression
;

exclusive_or_expression
: and_expression
| exclusive_or_expression '^' and_expression
;

inclusive_or_expression
: exclusive_or_expression
| inclusive_or_expression '|' exclusive_or_expression
;

logical_and_expression
: inclusive_or_expression
| logical_and_expression AND_OP inclusive_or_expression
;

logical_or_expression
: logical_and_expression
| logical_or_expression OR_OP logical_and_expression
;

conditional_expression
: logical_or_expression
| logical_or_expression '?' expression ':' conditional_expression
;

assignment_expression
: conditional_expression
| unary_expression assignment_operator assignment_expression
;

assignment_operator
: '='
| MUL_ASSIGN
| DIV_ASSIGN
| MOD_ASSIGN
| ADD_ASSIGN
| SUB_ASSIGN
| LEFT_ASSIGN
| RIGHT_ASSIGN
| AND_ASSIGN
| XOR_ASSIGN
| OR_ASSIGN
;

expression
: assignment_expression
| expression ',' assignment_expression
;

constant_expression
: conditional_expression
;

declaration
: declaration_specifiers ';'
| declaration_specifiers init_declarator_list ';'
;

declaration_specifiers
: storage_class_specifier
| storage_class_specifier declaration_specifiers
| type_specifier
| type_specifier declaration_specifiers
| type_qualifier
| type_qualifier declaration_specifiers
| function_specifier
| function_specifier declaration_specifiers
;

init_declarator_list
: init_declarator
| init_declarator_list ',' init_declarator
;

init_declarator
: declarator
| declarator '=' initializer
;

storage_class_specifier
: TYPEDEF
| EXTERN
| STATIC
| AUTO
| REGISTER
;

type_specifier
: VOID
| CHAR
| SHORT
| INT
| LONG
| FLOAT
| DOUBLE
| SIGNED
| UNSIGNED
| BOOL
| COMPLEX
| IMAGINARY
| struct_or_union_specifier
| enum_specifier
| TYPE_NAME
;

struct_or_union_specifier
: struct_or_union IDENTIFIER '{' struct_declaration_list '}'
| struct_or_union '{' struct_declaration_list '}'
| struct_or_union IDENTIFIER
;

struct_or_union
: STRUCT
| UNION
;

struct_declaration_list
: struct_declaration
| struct_declaration_list struct_declaration
;

struct_declaration
: specifier_qualifier_list struct_declarator_list ';'
;

specifier_qualifier_list
: type_specifier specifier_qualifier_list
| type_specifier
| type_qualifier specifier_qualifier_list
| type_qualifier
;

struct_declarator_list
: struct_declarator
| struct_declarator_list ',' struct_declarator
;

struct_declarator
: declarator
| ':' constant_expression
| declarator ':' constant_expression
;

enum_specifier
: ENUM '{' enumerator_list '}'
| ENUM IDENTIFIER '{' enumerator_list '}'
| ENUM '{' enumerator_list ',' '}'
| ENUM IDENTIFIER '{' enumerator_list ',' '}'
| ENUM IDENTIFIER
;

enumerator_list
: enumerator
| enumerator_list ',' enumerator
;

enumerator
: IDENTIFIER
| IDENTIFIER '=' constant_expression
;

type_qualifier
: CONST
| RESTRICT
| VOLATILE
;

function_specifier
: INLINE
;

declarator
: pointer direct_declarator
| direct_declarator
;


direct_declarator
: IDENTIFIER
| '(' declarator ')'
| direct_declarator '[' type_qualifier_list assignment_expression ']'
| direct_declarator '[' type_qualifier_list ']'
| direct_declarator '[' assignment_expression ']'
| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'
| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'
| direct_declarator '[' type_qualifier_list '*' ']'
| direct_declarator '[' '*' ']'
| direct_declarator '[' ']'
| direct_declarator '(' parameter_type_list ')'
| direct_declarator '(' identifier_list ')'
| direct_declarator '(' ')'
;

pointer
: '*'
| '*' type_qualifier_list
| '*' pointer
| '*' type_qualifier_list pointer
;

type_qualifier_list
: type_qualifier
| type_qualifier_list type_qualifier
;


parameter_type_list
: parameter_list
| parameter_list ',' ELLIPSIS
;

parameter_list
: parameter_declaration
| parameter_list ',' parameter_declaration
;

parameter_declaration
: declaration_specifiers declarator
| declaration_specifiers abstract_declarator
| declaration_specifiers
;

identifier_list
: IDENTIFIER
| identifier_list ',' IDENTIFIER
;

type_name
: specifier_qualifier_list
| specifier_qualifier_list abstract_declarator
;

abstract_declarator
: pointer
| direct_abstract_declarator
| pointer direct_abstract_declarator
;

direct_abstract_declarator
: '(' abstract_declarator ')'
| '[' ']'
| '[' assignment_expression ']'
| direct_abstract_declarator '[' ']'
| direct_abstract_declarator '[' assignment_expression ']'
| '[' '*' ']'
| direct_abstract_declarator '[' '*' ']'
| '(' ')'
| '(' parameter_type_list ')'
| direct_abstract_declarator '(' ')'
| direct_abstract_declarator '(' parameter_type_list ')'
;

initializer
: assignment_expression
| '{' initializer_list '}'
| '{' initializer_list ',' '}'
;

initializer_list
: initializer
| designation initializer
| initializer_list ',' initializer
| initializer_list ',' designation initializer
;

designation
: designator_list '='
;

designator_list
: designator
| designator_list designator
;

designator
: '[' constant_expression ']'
| '.' IDENTIFIER
;

statement
: labeled_statement
| compound_statement
| expression_statement
| selection_statement
| iteration_statement
| jump_statement
;

labeled_statement
: IDENTIFIER ':' statement
| CASE constant_expression ':' statement
| DEFAULT ':' statement
;

compound_statement
: '{' '}'
| '{' block_item_list '}'
;

block_item_list
: block_item
| block_item_list block_item
;

block_item
: declaration
| statement
;

expression_statement
: ';'
| expression ';'
;

selection_statement
: IF '(' expression ')' statement
| IF '(' expression ')' statement ELSE statement
| SWITCH '(' expression ')' statement
;

iteration_statement
: WHILE '(' expression ')' statement
| DO statement WHILE '(' expression ')' ';'
| FOR '(' expression_statement expression_statement ')' statement
| FOR '(' expression_statement expression_statement expression ')' statement
| FOR '(' declaration expression_statement ')' statement
| FOR '(' declaration expression_statement expression ')' statement
;

jump_statement
: GOTO IDENTIFIER ';'
| CONTINUE ';'
| BREAK ';'
| RETURN ';'
| RETURN expression ';'
;

translation_unit
: external_declaration
| translation_unit external_declaration
;

external_declaration
: function_definition
| declaration
;

function_definition
: declaration_specifiers declarator declaration_list compound_statement
| declaration_specifiers declarator compound_statement
;

declaration_list
: declaration
| declaration_list declaration
;


%%
#include <stdio.h>


int yylex() {
    struct {
        char *s;
        int t;
    } kwds[] = {
            { "void", VOID },
            { "char", CHAR },
            { "short", SHORT },
            { "int", INT },
            { "long", LONG },
            { "double", DOUBLE },
            { "if", IF },
            { "else", ELSE },
            { "for", FOR },
            { "while", WHILE },
            { "return", RETURN },
            { "break", BREAK },
            { "sizeof", SIZEOF },
            { 0, 0 }
    };
    int i, c, c2, c3, n;
    char v[NString], *p;
    double d, s;

    do {
        c = getchar();
        if (c == '#') {
            // commentary from the preprocessor starts with # followed by a line number and the file it's come from
            fscanf(stdin, "%d", &line);
            scanf("%%*[^\"]");
            scanf("\"");
            scanf("%[^\"]", currentFFN);
            // https://stackoverflow.com/questions/24483075/input-using-sscanf-with-regular-expression instead of regex "(?<=\")(.*)(?=\")" instead
            while ((c = getchar()) != '\n') {;}  // don't include a line with # on the line count
        }
        else if (c == '/') {
            c2 = getchar();
            if (c2 == '/')
                while ((c = getchar()) != '\n') {;}
            else
                ungetc(c2, stdin);
        }
        if (c == '\n') {
            line++;
        }
    } while (isspace(c));

    if (c == EOF) {
        if (LOG & L_LEX) fprintf(stderr, "\nEOF\n");
        return 0;
    }

    if (isdigit(c)) {
        // OPEN: use standard C to parse the numbers
        n = 0;
        do {
            n *= 10;
            n += c-'0';
            c = getchar();
        } while (isdigit(c));
        if (c == '.') {
            c = getchar();
            if (!isdigit(c)) die("invalid decimal");
            d = n;
            s = 1.0;
            do {
                s /= 10;
                d += s * (c-'0');
                c = getchar();
            } while (isdigit(c));
            ungetc(c, stdin);
            yylval.n = newNode(LIT_DEC, 0, 0);
            yylval.n->u.d = d;
            if (LOG & L_EMIT) fprintf(stderr, "%f ", d);
            return CONSTANT;
        }
        else {
            ungetc(c, stdin);
            yylval.n = newNode(LIT_INT, 0, 0);
            yylval.n->u.n = n;
            if (LOG & L_EMIT) fprintf(stderr, "%d ", n);
            return CONSTANT;
        }
    }

    if (isalpha(c) || c == '_') {
        p = v;
        do {
            if (p == &v[NString-1]) die("ident too long");
            *p++ = c;
            c = getchar();
        } while (isalnum(c) || c == '_');
        *p = 0;
        ungetc(c, stdin);
        for (i=0; kwds[i].s; i++)
            if (strcmp(v, kwds[i].s) == 0)
                return kwds[i].t;
        yylval.n = newNode(NAME, 0, 0);
        strcpy(yylval.n->u.v, v);
        if (LOG & L_EMIT) fprintf(stderr, "%s ", p);
        return IDENTIFIER;
    }

    if (c == '"') {
        i = 0;
        n = 32;
        p = alloc(n);
        strcpy(p, "{ b \"");
        for (i=5;; i++) {
            c = getchar();
            if (c == EOF) die("unclosed string literal");
            if (i+8 >= n) {
                char* oldP = p;
                p = memcpy(alloc(n*2), p, n);
                free(oldP);
                n *= 2;
            }
            if (c != '"')
                p[i] = c;
            else {
                if (p[i-1] == '\\')
                    p[i] = c;
                else {
                    // handle multiple strings on one line, OPEN: handle across multiple lines
                    int eos = 1;
                    do {
                        c2 = getchar();
                        if (c2 == '"') {
                            eos = 0;
                        }
                        else if (c == '#') die("unexpected # encountered");
                    } while (c2 == ' ');
                    if (eos == 1) {
                        p[i] = c;
                        ungetc(c2, stdin);
                        break;
                    }
                    else
                        i--;
                }
            }
        }
        strcpy(&p[i], "\", b 0 }");
        if (nglo == NGlo) die("too many globals");
        ini[nglo] = p;
        yylval.n = newNode('S', 0, 0);
        yylval.n->u.n = nglo++;
        if (LOG & L_EMIT) fprintf(stderr, "%s ", &p[i]);
        return STRING_LITERAL;
    }

    c2 = getchar();
#define DI(a, b) a + b*256
    switch (DI(c,c2)) {
        case DI('!','='): return NE_OP;
        case DI('=','='): return EQ_OP;
        case DI('<','='): return LE_OP;
        case DI('>','='): return GE_OP;
        case DI('+','+'): return INC_OP;
        case DI('-','-'): return DEC_OP;
        case DI('&','&'): return AND_OP;
        case DI('|','|'): return OR_OP;
        case DI('.','.'): {
            c3 = getchar();
            if (c3 == '.') {
                return ELLIPSIS;
            }
            ungetc(c3, stdin);
        }
    }
#undef DI
    ungetc(c2, stdin);
    if (LOG & L_EMIT) fprintf(stderr, "%c ", c);
    return c;
}


void yyerror(char const *err) {
//    fflush(stdout);
//    printf("\n%*s\n%*s\n", column, "^", column, s);
    die("parse error from yyerror");
}


int main() {
    int i;
    of = stdout;
    nglo = 1;
    if (LOG) fprintf(stderr, "Parsing...\n");
    if (yyparse() != 0) die("parse error");
    for (i=1; i<nglo; i++)
        fprintf(of, "data " GLOBAL "%d = %s\n", i, ini[i]);
    return 0;
}
