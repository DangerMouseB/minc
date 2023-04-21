%{
/*
// ---------------------------------------------------------------------------------------------------------------------
//
//                             Copyright (c) 2023 David Briant. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for
// the specific language governing permissions and limitations under the License.
//
// ---------------------------------------------------------------------------------------------------------------------


 *** OVERVIEW ***

 minc (i.e. minimal C) is derrived from minic by Quentin Carbonneaux

 It is supposed to be useful in exploring how to generate IR - the basics for doing C but also as a starting point
 for higher level ideas - e.g. inlining, multidispatch, exception handling, and so on.

 The code here should be simple (in the Rich Hickey sense) and easy to understand.

 The yacc grammar was replaced with a popular one found here https://www.quut.com/c/ANSI-C-grammar-y-1999.html.

 Stmt and Node were merged.

 We won't implement the full C99 standard but I'm a firm be believer in designing for the future even whilst
 implementing for the now. I found minic hard to extend as the yacc grammar was bound into the implementation types.

 We will continue to use the YACC implementation Quentin used.

 * to be extendable in ways that don't confirm to the standard such as:
    * adding bones style memory management based on stack, sratch and heap
    * add rust borrow style
    * add bones types
    * add logging for debugging in the background

 We would like to be able to use this in Python so will need to rework the memory management and fully clean up. For
 speed we could put out globals in one arena, and create a new arena for each function. Then free each arena in
 one go. Pyminc would take in C99 code, and output linked binary into memory to be v=called via ctypes. We don't
 need to call into it from C but I supposed that might be possible. Would need to understand linkers and loaders.
 Pyminc should also output QBE IR and asm.




 *** NAMING CONVENTION ***

 TOKEN            (including T_TYPENAME_)
 OP_OPERATION     (e.g. OP_ADD, except NAME, LIT_INT, LIT_DEC, LIT_STR)
 T_TYPE



 *** NOTES ***

 OPEN: move the global variables into a struct? Actually we only need to do that if we want the compiler to be
 reentrant in Python. Which we probably don't need.


 minc stuff - hide as much as possible
 c stuff
 qbe ir stuff


*/


/*Beginning of C declarations*/



// minc

#include <stdarg.h>
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

enum {
    lex = 1,
    parse = 2,
    emit =4,
    info = 8,
    error = 16,
};

enum {
    NString = 32,
    NGlo = 256,
    NVar = 512,
    NStr = 256,
};

typedef struct VarEntry {
    char v[NString];
    unsigned ctyp;
    int glo;
} VarEntry;

int gLevel;
FILE *of;
int line, lbl, tmp, nglo;
char *globals[NGlo];
VarEntry varh[NVar];
char srcFfn[1000];     // should be long enough for a filename

int yylex(void);
void yyerror(char const *);

unsigned hash(char *s);
void * alloc(size_t s);
void die(char *s, ...);
void varclr();
void varadd(char *v, int glo, unsigned ctyp);
void PP(int level, char *msg, ...);
void putq(char *src, ...);



// C and QBE IR


enum {
    T_VOID,
    T_CHR,
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

enum op {
    NAME = 86,
    If = 128,
    IfElse = 129,
    Else = 130,
    While = 131,
    Expr = 132,
    Break = 133,
    Ret = 134,
    Seq = 135,
    Ptr = 136,
    ADD_EQ = 137,
    SUB_EQ = 138,
};

#define OP_CALL 'C'
#define OP_ASSIGN '='

#define OP_EQ   'e'
#define OP_NE   'n'
#define OP_LE   'l'
#define OP_LT   '<'
#define OP_AND  'a'
#define OP_OR   'o'
#define OP_NOT  '!'

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

#define OP_INC  'P'
#define OP_DEC  'M'

#define LIT_INT 'N'
#define LIT_DEC 'D'


#define GLOBAL  "$g"
#define TEMP    "%%t"
#define LOCAL   "%%_"
#define LABEL   "@L"



typedef struct Symb {
    enum {
        Con,
        Tmp,
        Var,
        Glo,
    } t;                    // 4
    union {
        int n;
        char v[NString];
        double d;
    } u;                    // 4 | 32 | 8 = 32
    unsigned long ctyp;     // 8
} Symb;


typedef struct Node Node;
struct Node {               // 64 bytes
    int op;                 // 4
    Symb s;                 // 4 + 32 + 8
    Node *l, *r;            // 8 + 8
};
Node * node(int op, Node *l, Node *r);
Node * bindl(Node *n, Node *l, int lineno);
Node * bindr(Node *n, Node *r, int lineno);
Node * bindlr(Node *n, Node *l, Node *r, int lineno);



// OPEN: remove this by changing the logic that needed this to using node
typedef struct TLLHead TLLHead;
struct TLLHead {
    int t;
    TLLHead *r;
};
TLLHead * newTLLHead(int t, TLLHead *other);



Symb emitexpr(Node *);
Symb lval(Node *);
void emitboolop(Node *, int, int);
Symb * varget(char *v);
void ppCtype(unsigned long t);




// Node construction

Node * mkidx(Node *a, Node *i) {
    Node *n = node(OP_ADD, a, i);
    n = node(OP_DEREF, n, 0);
    return n;
}


Node * mkneg(Node *n) {
    static Node *z;
    if (!z) {
        z = node(LIT_INT, 0, 0);
        z->s.u.n = 0;
    }
    return node(OP_SUB, z, n);
}


Node * mkparam(char *v, unsigned ctyp, Node *pl) {
    if (ctyp == T_VOID) die("invalid void declaration");
    Node *n = node(0, 0, pl);
    varadd(v, 0, ctyp);
    strcpy(n->s.u.v, v);
    return n;
}


Node * mkifelse(void *c, Node *t, Node *f) {
    return node(IfElse, c, node(Else, t, f));
}


Node * mkfor(Node *ini, Node *tst, Node *inc, Node *s) {
    Node *s1, *s2;

    if (ini)
        s1 = node(Expr, ini, 0);
    else
        s1 = 0;
    if (inc) {
        s2 = node(Expr, inc, 0);
        s2 = node(Seq, s, s2);
    } else
        s2 = s;
    if (!tst) {
        tst = node(LIT_INT, 0, 0);
        tst->s.u.n = 1;
    }
    s2 = node(While, tst, s2);
    if (s1)
        return node(Seq, s1, s2);
    else
        return s2;
}



// emission

void emitsymb(Symb s) {
    switch (s.t) {
        case Tmp:
            putq(TEMP "%d", s.u.n);
            break;
        case Var:
            putq(LOCAL "%s", s.u.v);
            break;
        case Glo:
            putq(GLOBAL "%d", s.u.n);
            break;
        case Con:
            putq("%d", s.u.n);
            break;
    }
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


void l_extsw(Symb *s) {
    putq("\t" TEMP "%d =l extsw ", tmp);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->ctyp = T_LNG;
    s->u.n = tmp++;
}


void d_swtof(Symb *s) {
    putq("\t" TEMP "%d =d swtof ", tmp);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->ctyp = T_DBL;
    s->u.n = tmp++;
}


void d_sltof(Symb *s) {
    putq("\t" TEMP "%d =d sltof ", tmp);
    emitsymb(*s);
    putq("\n");
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
        putq("\t" TEMP "%d =l mul %d, ", tmp, sz);
        emitsymb(*r);
        putq("\n");
        r->u.n = tmp++;
    }
    return l->ctyp;
}


void emitload(Symb d, Symb s) {
    putq("\t");
    emitsymb(d);
    putq(" =%c load%c ", irtyp(d.ctyp), irtyp(d.ctyp));
    emitsymb(s);
    putq("\n");
}


void emitcall(Node *n, Symb *sr) {
    Node *a;  unsigned ft;
    char *f = n->l->s.u.v;
    if (varget(f)) {
        ft = varget(f)->ctyp;
        if (KIND(ft) != T_FUN) die("invalid call");
    } else
        ft = FUNC(T_INT);
    sr->ctyp = DREF(ft);
    for (a=n->r; a; a=a->r)
        a->s = emitexpr(a->l);
    putq("\t");
    emitsymb(*sr);
    putq(" =%c call $%s(", irtyp(sr->ctyp), f);
    for (a=n->r; a; a=a->r) {
        putq("%c ", irtyp(a->s.ctyp));
        emitsymb(a->s);
        putq(", ");
    }
    putq("...)\n");
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
            putq(LABEL "%d\n", l);
            putq("\tjmp " LABEL "%d\n", l+2);
            putq(LABEL "%d\n", l+1);
            putq("\tjmp " LABEL "%d\n", l+2);
            putq(LABEL "%d\n", l+2);
            putq("\t");
            sr.ctyp = T_INT;
            emitsymb(sr);
            putq(" =w phi " LABEL "%d 1, " LABEL "%d 0\n", l, l+1);
            break;

        case NAME:
            s0 = lval(n);
            sr.ctyp = s0.ctyp;
            emitload(sr, s0);
            break;

        case LIT_DEC:
            sr.t = Con;
            sr.u.d = n->s.u.d;
            sr.ctyp = T_DBL;
            break;

        case LIT_INT:
            sr.t = Con;
            sr.u.n = n->s.u.n;
            sr.ctyp = T_INT;
            break;

        case 'S':
            sr.t = Glo;
            sr.u.n = n->s.u.n;
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

        case ADD_EQ:
            die("+= NYI");

        case SUB_EQ:
            die("-= NYI");

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
                        PP(emit, "%s = ", s1.u.v);
                        ppCtype(s0.ctyp);
                        PP(emit, "\n");
                        die("invalid assignment");
                    }
            putq("\tstore%c ", irtyp(s1.ctyp));
            goto Args;

        case OP_INC:
        case OP_DEC:
            o = n->op == OP_INC ? OP_ADD : OP_SUB;
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
            putq("\t");
            emitsymb(sr);
            putq(" =%c", irtyp(sr.ctyp));
            putq(" %s%s ", otoa[o], ty);
        Args:
            emitsymb(s0);
            putq(", ");
            emitsymb(s1);
            putq("\n");
            break;

    }
    if (n->op == OP_SUB  &&  KIND(s0.ctyp) == T_PTR  &&  KIND(s1.ctyp) == T_PTR) {
        putq("\t" TEMP "%d =l div ", tmp);
        emitsymb(sr);
        putq(", %d\n", SIZE(DREF(s0.ctyp)));
        sr.u.n = tmp++;
    }
    if (n->op == OP_INC  ||  n->op == OP_DEC) {
        putq("\tstore%c ", irtyp(sl.ctyp));
        emitsymb(sr);
        putq(", ");
        emitsymb(sl);
        putq("\n");
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
            if (!varget(n->s.u.v)) {
                PP(error, "%s is not defined\n", n->s.u.v);
                die("undefined variable");
            }
            sr = *varget(n->s.u.v);
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
            s = emitexpr(n); /* OPEN: insert comparison to 0 with proper type */
            putq("\tjnz ");
            emitsymb(s);
            putq(", " LABEL "%d, " LABEL "%d\n", lt, lf);
            break;
        case OP_OR:
            l = lbl;
            lbl += 1;
            emitboolop(n->l, lt, l);
            putq(LABEL "%d\n", l);
            emitboolop(n->r, lt, lf);
            break;
        case OP_AND:
            l = lbl;
            lbl += 1;
            emitboolop(n->l, l, lf);
            putq(LABEL "%d\n", l);
            emitboolop(n->r, lt, lf);
            break;
    }
}


int emitstmt(Node *s, int b) {
    int l, r;  Symb x;
    PP(emit, "emitstmt");

    if (!s) return 0;

    switch (s->op) {
        default:
            die("invalid statement %d", s->op);
        case Ret:
            PP(emit, "Ret");
            x = emitexpr(s->l);
            putq("\tret ");
            emitsymb(x);
            putq("\n");
            return 1;
        case Break:
            if (b < 0) die("break not in loop");
            putq("\tjmp " LABEL "%d\n", b);
            return 1;
        case Expr:
            emitexpr(s->l);
            return 0;
        case Seq:
            return emitstmt(s->l, b) || emitstmt(s->r, b);
        case If:
            l = lbl;
            lbl += 2;
            emitboolop(s->l, l, l+1);
            putq(LABEL "%d\n", l);
            emitstmt(s->r, b);
            putq(LABEL "%d\n", l+1);
            return 0;
        case IfElse:
            l = lbl;
            lbl += 3;
            emitboolop(s->l, l, l+1);
            putq(LABEL "%d\n", l);
            Node * e = s->r;
            if (!(r=emitstmt(e->l, b)))
                putq("\tjmp " LABEL "%d\n", l+2);
            putq(LABEL "%d\n", l+1);
            if (!(r &= emitstmt(e->r, b)))
                putq(LABEL "%d\n", l+2);
            return e->r && r;
        case While:
            l = lbl;
            lbl += 3;
            putq(LABEL "%d\n", l);
            emitboolop(s->l, l+1, l+2);
            putq(LABEL "%d\n", l+1);
            if (!emitstmt(s->r, l+2))
                putq("\tjmp " LABEL "%d\n", l);
            putq(LABEL "%d\n", l+2);
            return 0;
    }
}


void initFunc() {
    PP(emit, "initFunc\n");
    varclr(); tmp = 0;
}


void startFunc(int t, Node *fnname, Node *params) {
    Symb *s;  Node *n;  int i, m;
    PP(emit, "startFunc");

    varadd(fnname->s.u.v, 1, FUNC(T_INT));
    putq("export function w $%s(", fnname->s.u.v);
    n = params;
    if (n)
        for (;;) {
            s = varget(n->s.u.v);
            putq("%c ", irtyp(s->ctyp));
            putq(TEMP "%d", tmp++);
            n = n->r;
            if (n)
                putq(", ");
            else
                break;
        }
    putq(") {\n");
    putq(LABEL "%d\n", lbl++);
    for (i=0, n=params; n; i++, n=n->r) {
        s = varget(n->s.u.v);
        m = SIZE(s->ctyp);
        putq("\t" LOCAL "%s =l alloc%d %d\n", n->s.u.v, m, m);
        putq("\tstore%c " TEMP "%d", irtyp(s->ctyp), i);
        putq(", " LOCAL "%s\n", n->s.u.v);
    }
}


void finishFunc(Node *s) {
    PP(emit, "finishFunc");
    if (!emitstmt(s, -1)) putq("\tret 0\n");
    putq("}\n\n");
}


void emitLocalDecl(int t, Node *varname) {
    PP(emit, "emitLocalDecl\n");
    // OPEN: allow multiple names for each type
    int s;  char *v;
    if (t == T_VOID) die("invalid void declaration");
    v = varname->s.u.v;
    s = SIZE(t);
    varadd(v, 0, t);
    putq("\t" LOCAL "%s =l alloc%d %d\n", v, s, s);
}


void declareGlobal(int t, Node *globalname) {
    if (t == T_VOID) die("invalid void declaration");
    if (nglo == NGlo) die("too many string literals");
    globals[nglo] = alloc(sizeof "{ x 0 }");
    sprintf(globals[nglo], "{ %c 0 }", irtyp(t));
    varadd(globalname->s.u.v, nglo++, t);
}


/*End of C declarations*/
%}


%union {
    Node *n;
    TLLHead *t;
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


%type <n> expression pointer unary_operator assignment_expression unary_expression assignment_operator cast_expression
%type <n> type_name compound_statement declarator declaration_list

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
| INC_OP unary_expression                               { $$ = node(OP_INC, $2, 0); }
| DEC_OP unary_expression                               { $$ = node(OP_DEC, $2, 0); }
| unary_operator cast_expression                        { $$ = bindl($1, $2, __LINE__); }
| SIZEOF unary_expression                               { $$ = node(LIT_INT, 0, 0); $$->s.u.n = SIZE($2); }
| SIZEOF '(' type_name ')'                              { $$ = node(LIT_INT, 0, 0); $$->s.u.n = SIZE($3); }
;

unary_operator
: '&'                                                   { $$ = node(OP_ADDR, 0, 0); }
| '*'                                                   { $$ = node(OP_DEREF, 0, 0); }
| '+'
| '-'
| '~'                                                   { $$ = node(OP_BINV, 0, 0); }
| '!'                                                   { $$ = node(OP_NOT, 0, 0); }
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
| unary_expression assignment_operator assignment_expression    { $$ = bindlr($2, $1, $3, __LINE__); }
;

assignment_operator
: '='                                                   { $$ = node(OP_ASSIGN, 0, 0); }
| MUL_ASSIGN
| DIV_ASSIGN
| MOD_ASSIGN
| ADD_ASSIGN                                            { $$ = node(ADD_EQ, 0, 0); }
| SUB_ASSIGN                                            { $$ = node(SUB_EQ, 0, 0); }
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
: VOID                                                      { $<u>$ = T_VOID; }
| CHAR                                                      { $<u>$ = T_CHR; }
| SHORT
| INT                                                       { $<u>$ = T_INT; }
| LONG
| FLOAT
| DOUBLE                                                    { $<u>$ = T_DBL; }
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
| '*' pointer                                           { //$<n>$ = IDIR($2);
    }
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
| FOR '(' expression_statement
    expression_statement expression ')'
    statement
| FOR '(' declaration expression_statement ')' statement
| FOR '(' declaration expression_statement expression ')' statement
;

jump_statement
: GOTO IDENTIFIER ';'
| CONTINUE ';'
| BREAK ';'
| RETURN ';'
| RETURN expression ';'                                     { $<n>$ = node(Ret, $2, 0); }
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
: declaration_specifiers declarator declaration_list compound_statement     { startFunc(0, $2, $3); finishFunc($4); }
| declaration_specifiers declarator compound_statement                      { startFunc(0, $2, 0); finishFunc($3); }
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
            scanf("%[^\"]", srcFfn);
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
        PP(lex, "\nEOF\n");
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
            yylval.n = node(LIT_DEC, 0, 0);
            yylval.n->s.u.d = d;
            PP(lex, "%f ", d);
            return CONSTANT;
        }
        else {
            ungetc(c, stdin);
            yylval.n = node(LIT_INT, 0, 0);
            yylval.n->s.u.n = n;
            PP(lex, "%d ", n);
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
        yylval.n = node(NAME, 0, 0);
        strcpy(yylval.n->s.u.v, v);
        PP(lex, "%s ", p);
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
        globals[nglo] = p;
        yylval.n = node('S', 0, 0);
        yylval.n->s.u.n = nglo++;
        PP(lex, "%s ", &p[i]);
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
        case DI('+','='): return ADD_EQ;
        case DI('-','='): return SUB_EQ;
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
    PP(lex, "%c ", c);
    return c;
}



int main() {
    gLevel = lex | parse | emit;
    of = stdout;
    nglo = 1;
    if (yyparse() != 0) die("parse error");
    for (int i=1; i<nglo; i++)
        putq("data " GLOBAL "%d = %s\n", i, globals[i]);
    return 0;
}




// ---------------------------------------------------------------------------------------------------------------------
// YACC HELPERS
// ---------------------------------------------------------------------------------------------------------------------

void yyerror(char const *err) {
//    fflush(stdout);
//    printf("\n%*s\n%*s\n", column, "^", column, s);
    die("parse error from yyerror");
}



// ---------------------------------------------------------------------------------------------------------------------
// HELPERS
// ---------------------------------------------------------------------------------------------------------------------

Node * node(int op, Node *l, Node *r) {
    Node *n = alloc(sizeof *n);
    n->op = op;
    n->l = l;
    n->r = r;
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
    // OPEN: do a linked list of arenas - so can unwind more safely in Python
    void *p = malloc(s);
    if (!p) die("out of memory");
    return p;
}

void die(char *msg, ...) {
    va_list args;
    fprintf(stderr, "\nline <= %d: ", line);
    va_start(args, msg);
    vfprintf(stderr, msg, args);
    va_end(args);
    fprintf(stderr, "\nin %s\n\n", srcFfn);
    // OPEN: use setjmp and longjmp with deallocation of linked list of arenas
    exit(1);
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

void PP(int level, char *msg, ...) {
    if (level & gLevel) {
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
