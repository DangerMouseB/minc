%{


// NAMING CONVENTION
// TOKEN_           (including T_TYPENAME_)
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


int yylex(void);
int yyerror(char *);
Symb expr(Node *);
Symb lval(Node *);
void bool(Node *, int, int);


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


void psymb(Symb s) {
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
	psymb(*s);
	fprintf(of, "\n");
	s->t = Tmp;
	s->ctyp = T_LNG;
	s->u.n = tmp++;
}


void d_swtof(Symb *s) {
	fprintf(of, "\t" TEMP "%d =d swtof ", tmp);
	psymb(*s);
	fprintf(of, "\n");
	s->t = Tmp;
	s->ctyp = T_DBL;
	s->u.n = tmp++;
}


void d_sltof(Symb *s) {
	fprintf(of, "\t" TEMP "%d =d sltof ", tmp);
	psymb(*s);
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
		psymb(*r);
		fprintf(of, "\n");
		r->u.n = tmp++;
	}
	return l->ctyp;
}


void load(Symb d, Symb s) {
	fprintf(of, "\t");
	psymb(d);
	fprintf(of, " =%c load%c ", irtyp(d.ctyp), irtyp(d.ctyp));
	psymb(s);
	fprintf(of, "\n");
}


void call(Node *n, Symb *sr) {
	Node *a;  unsigned ft;
	char *f = n->l->u.v;
	if (varget(f)) {
		ft = varget(f)->ctyp;
		if (KIND(ft) != T_FUN) die("invalid call");
	} else
		ft = FUNC(T_INT);
	sr->ctyp = DREF(ft);
	for (a=n->r; a; a=a->r)
		a->u.s = expr(a->l);
	fprintf(of, "\t");
	psymb(*sr);
	fprintf(of, " =%c call $%s(", irtyp(sr->ctyp), f);
	for (a=n->r; a; a=a->r) {
		fprintf(of, "%c ", irtyp(a->u.s.ctyp));
		psymb(a->u.s);
		fprintf(of, ", ");
	}
	fprintf(of, "...)\n");
}


Symb expr(Node *n) {
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
		bool(n, l, l+1);
		fprintf(of, LABEL "%d\n", l);
		fprintf(of, "\tjmp " LABEL "%d\n", l+2);
		fprintf(of, LABEL "%d\n", l+1);
		fprintf(of, "\tjmp " LABEL "%d\n", l+2);
		fprintf(of, LABEL "%d\n", l+2);
		fprintf(of, "\t");
		sr.ctyp = T_INT;
		psymb(sr);
		fprintf(of, " =w phi " LABEL "%d 1, " LABEL "%d 0\n", l, l+1);
		break;

	case NAME:
		s0 = lval(n);
		sr.ctyp = s0.ctyp;
		load(sr, s0);
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
		call(n, &sr);
		break;

	case OP_DEREF:
		s0 = expr(n->l);
		if (KIND(s0.ctyp) != T_PTR)
			die("dereference of a non-pointer");
		sr.ctyp = DREF(s0.ctyp);
		load(sr, s0);
		break;

	case OP_ADDR:
		sr = lval(n->l);
		sr.ctyp = IDIR(sr.ctyp);
		break;

	case OP_ASSIGN:
		s0 = expr(n->r);
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
		load(s0, sl);
		s1.t = Con;
		s1.u.n = 1;
		s1.ctyp = T_INT;
		goto Binop;

	default:
		s0 = expr(n->l);
		s1 = expr(n->r);
		o = n->op;
	Binop:
		sr.ctyp = prom(o, &s0, &s1);
		if (strchr("ne<l", n->op)) {
			sprintf(ty, "%c", irtyp(sr.ctyp));
			sr.ctyp = T_INT;
		} else
			strcpy(ty, "");
		fprintf(of, "\t");
		psymb(sr);
		fprintf(of, " =%c", irtyp(sr.ctyp));
		fprintf(of, " %s%s ", otoa[o], ty);
	Args:
		psymb(s0);
		fprintf(of, ", ");
		psymb(s1);
		fprintf(of, "\n");
		break;

	}
	if (n->op == OP_SUB  &&  KIND(s0.ctyp) == T_PTR  &&  KIND(s1.ctyp) == T_PTR) {
		fprintf(of, "\t" TEMP "%d =l div ", tmp);
		psymb(sr);
		fprintf(of, ", %d\n", SIZE(DREF(s0.ctyp)));
		sr.u.n = tmp++;
	}
	if (n->op == OP_PP  ||  n->op == OP_MM) {
		fprintf(of, "\tstore%c ", irtyp(sl.ctyp));
		psymb(sr);
		fprintf(of, ", ");
		psymb(sl);
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
		sr = expr(n->l);
		if (KIND(sr.ctyp) != T_PTR) die("dereference of a non-pointer");
		sr.ctyp = DREF(sr.ctyp);
		break;
	}
	return sr;
}


void bool(Node *n, int lt, int lf) {
	Symb s;  int l;
	switch (n->op) {
	default:
		s = expr(n); /* TODO: insert comparison to 0 with proper type */
		fprintf(of, "\tjnz ");
		psymb(s);
		fprintf(of, ", " LABEL "%d, " LABEL "%d\n", lt, lf);
		break;
	case OP_OR:
		l = lbl;
		lbl += 1;
		bool(n->l, lt, l);
		fprintf(of, LABEL "%d\n", l);
		bool(n->r, lt, lf);
		break;
	case OP_AND:
		l = lbl;
		lbl += 1;
		bool(n->l, l, lf);
		fprintf(of, LABEL "%d\n", l);
		bool(n->r, lt, lf);
		break;
	}
}


int stmt(Stmt *s, int b) {
	int l, r;  Symb x;

	if (!s) return 0;

	switch (s->t) {
	case Ret:
		x = expr(s->p1);
		fprintf(of, "\tret ");
		psymb(x);
		fprintf(of, "\n");
		return 1;
	case Break:
		if (b < 0) die("break not in loop");
		fprintf(of, "\tjmp " LABEL "%d\n", b);
		return 1;
	case Expr:
		expr(s->p1);
		return 0;
	case Seq:
		return stmt(s->p1, b) || stmt(s->p2, b);
	case If:
		l = lbl;
		lbl += 3;
		bool(s->p1, l, l+1);
		fprintf(of, LABEL "%d\n", l);
		if (!(r=stmt(s->p2, b)))
		if (s->p3)
			fprintf(of, "\tjmp " LABEL "%d\n", l+2);
		fprintf(of, LABEL "%d\n", l+1);
		if (s->p3)
		if (!(r &= stmt(s->p3, b)))
			fprintf(of, LABEL "%d\n", l+2);
		return s->p3 && r;
	case While:
		l = lbl;
		lbl += 3;
		fprintf(of, LABEL "%d\n", l);
		bool(s->p1, l+1, l+2);
		fprintf(of, LABEL "%d\n", l+1);
		if (!stmt(s->p2, l+2))
			fprintf(of, "\tjmp " LABEL "%d\n", l);
		fprintf(of, LABEL "%d\n", l+2);
		return 0;
	}
}


Node * mknode(char op, Node *l, Node *r) {
	Node *n = alloc(sizeof *n);
	n->op = op;
	n->l = l;
	n->r = r;
	return n;
}


Node * mkidx(Node *a, Node *i) {
	Node *n = mknode(OP_ADD, a, i);
	n = mknode(OP_DEREF, n, 0);
	return n;
}


Node * mkneg(Node *n) {
	static Node *z;
	if (!z) {
		z = mknode(LIT_INT, 0, 0);
		z->u.n = 0;
	}
	return mknode(OP_SUB, z, n);
}


Stmt * mkstmt(int t, void *p1, void *p2, void *p3) {
	Stmt *s = alloc(sizeof *s);
	s->t = t;
	s->p1 = p1;
	s->p2 = p2;
	s->p3 = p3;
	return s;
}


Node * mkparam(char *v, unsigned ctyp, Node *pl) {
	if (ctyp == T_VOID) die("invalid void declaration");
	Node *n = mknode(0, 0, pl);
	varadd(v, 0, ctyp);
	strcpy(n->u.v, v);
	return n;
}


Stmt * mkfor(Node *ini, Node *tst, Node *inc, Stmt *s) {
	Stmt *s1, *s2;

	if (ini)
		s1 = mkstmt(Expr, ini, 0, 0);
	else
		s1 = 0;
	if (inc) {
		s2 = mkstmt(Expr, inc, 0, 0);
		s2 = mkstmt(Seq, s, s2, 0);
	} else
		s2 = s;
	if (!tst) {
		tst = mknode(LIT_INT, 0, 0);
		tst->u.n = 1;
	}
	s2 = mkstmt(While, tst, s2, 0);
	if (s1)
		return mkstmt(Seq, s1, s2, 0);
	else
		return s2;
}


void initFunc() {
    varclr(); tmp = 0;
}


void startFunc(int t, Node *fnname, Node *params) {
	Symb *s;  Node *n;  int i, m;

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
	if (!stmt(s, -1)) fprintf(of, "\tret 0\n");
	fprintf(of, "}\n\n");
}

void emitFnDecls(int t, Node *varname) {
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



%}


%union {
	Node *n;
	Stmt *s;
	unsigned u;
}

%token <n> LIT_INT_  LIT_DEC_  LIT_STR_  NAME_
%token PP_  MM_  SIZEOF_

%token T_VOID_  T_INT_  T_LNG_  T_DBL_
%token IF_  ELSE_  WHILE_  FOR_  BREAK_  RETURN_
%token LINE_COMMENT_

%nonassoc DOTS_
%right EQUALS_
%left OR_
%left AND_
%left AMPERSAND_
%left EQ_  NE_
%left ANGLE_L_  ANGLE_R_  LE_  GE_
%left PLUS_  HYPHEN_
%left STAR_  SLASH_  PERCENT_

%type <u> type
%type <s> stmt stmts open closed simple
%type <n> expr_ expr pref post args_ args params_ params types_ types


%%

prog: fdcl prog | gdcl prog | func prog | LINE_COMMENT_ prog |;


type: type STAR_                    { $$ = IDIR($1); }
    | T_INT_                        { $$ = T_INT; }
    | T_LNG_                        { $$ = T_LNG; }
    | T_DBL_                        { $$ = T_DBL; }
    | T_VOID_                       { $$ = T_VOID; };


fdcl: type NAME_ '(' types_ ')' ';' { varadd($2->u.v, 1, FUNC($1)); };
types_: types                       { $$ = 0; }
    |                               { $$ = 0; };
types: type ',' types               { $$ = 0; }
    | type                          { $$ = 0; };


gdcl: type NAME_ ';'                { collectGlobal($1, $2); };


func: init prot '{' dcls stmts '}'  { finishFunc($5); };
init:                               { initFunc(); };
prot: NAME_ '(' params_ ')'         { startFunc(0, $1, $3); };
params_: params
    |                               { $$ = 0; };
params: type NAME_ ',' params       { $$ = mkparam($2->u.v, $1, $4); }
    | type NAME_                    { $$ = mkparam($2->u.v, $1, 0); };
dcls: | dcls type NAME_ ';'         { emitFnDecls($2, $3); };


stmts: stmts stmt                   { $$ = mkstmt(Seq, $1, $2, 0); /* https://en.wikipedia.org/wiki/Dangling_else */ }
    |                               { $$ = 0; };

stmt: open                          { $$ = $1; }
    | closed                        { $$ = $1; };

open: IF_ '(' expr ')' stmt                         { $$ = mkstmt(If, $3, $5, 0); }
    | IF_ '(' expr ')' closed ELSE_ open            { $$ = mkstmt(If, $3, $5, $7); }
    | WHILE_ '(' expr ')' open                      { $$ = mkstmt(While, $3, $5, 0); }
    | FOR_ '(' expr_ ';' expr_ ';' expr_ ')' open   { $$ = mkfor($3, $5, $7, $9); };

closed: simple
    | IF_ '(' expr ')' closed ELSE_ closed          { $$ = mkstmt(If, $3, $5, $7); }
    | WHILE_ '(' expr ')' closed                    { $$ = mkstmt(While, $3, $5, 0); }
    | FOR_ '(' expr_ ';' expr_ ';' expr_ ')' closed { $$ = mkfor($3, $5, $7, $9); };

simple: ';'                         { $$ = 0; }
    | LINE_COMMENT_                 { $$ = 0; }
    | '{' stmts '}'                 { $$ = $2; }
    | BREAK_ ';'                    { $$ = mkstmt(Break, 0, 0, 0); }
    | RETURN_ expr ';'              { $$ = mkstmt(Ret, $2, 0, 0); }
    | expr ';'                      { $$ = mkstmt(Expr, $1, 0, 0); };

expr: pref
    | expr EQUALS_ expr             { $$ = mknode(OP_ASSIGN, $1, $3); }
    | expr PLUS_ expr               { $$ = mknode(OP_ADD, $1, $3); }
    | expr HYPHEN_ expr             { $$ = mknode(OP_SUB, $1, $3); }
    | expr STAR_ expr               { $$ = mknode(OP_MUL, $1, $3); }
    | expr SLASH_ expr              { $$ = mknode(OP_DIV, $1, $3); }
    | expr PERCENT_ expr            { $$ = mknode(OP_REM, $1, $3); }
    | expr ANGLE_L_ expr            { $$ = mknode(OP_LT, $1, $3); }
    | expr ANGLE_R_ expr            { $$ = mknode(OP_LT, $3, $1); }
    | expr LE_ expr                 { $$ = mknode(OP_LE, $1, $3); }
    | expr GE_ expr                 { $$ = mknode(OP_LE, $3, $1); }
    | expr EQ_ expr                 { $$ = mknode(OP_EQ, $1, $3); }
    | expr NE_ expr                 { $$ = mknode(OP_NE, $1, $3); }
    | expr AND_ expr                { $$ = mknode(OP_AND, $1, $3); }
    | expr OR_ expr                 { $$ = mknode(OP_OR, $1, $3); }
    | expr AMPERSAND_ expr          { $$ = mknode(OP_BAND, $1, $3); };

expr_: expr
    |                               { $$ = 0; };

pref: post
    | HYPHEN_ pref                  { $$ = mkneg($2); }
    | STAR_ pref                    { $$ = mknode(OP_DEREF, $2, 0); }
    | AMPERSAND_ pref               { $$ = mknode(OP_ADDR, $2, 0); };

post: LIT_INT_
    | LIT_DEC_
    | LIT_STR_
    | NAME_
    | SIZEOF_ '(' type ')'          { $$ = mknode(LIT_INT, 0, 0); $$->u.n = SIZE($3); }
    | '(' expr ')'                  { $$ = $2; }
    | NAME_ '(' args_ ')'           { $$ = mknode(OP_CALL, $1, $3); }
    | post '[' expr ']'             { $$ = mkidx($1, $3); }
    | post PP_                      { $$ = mknode(OP_PP, $1, 0); }
    | post MM_                      { $$ = mknode(OP_MM, $1, 0); };

args_ : args
    |                               { $$ = 0; };

args: expr                          { $$ = mknode(0, $1, 0); }
    | expr ',' args                 { $$ = mknode(0, $1, $3); };

%%


// OPEN: add char
int yylex() {
	struct {
		char *s;
		int t;
	} kwds[] = {
		{ "void", T_VOID_ },
		{ "int", T_INT_ },
		{ "long", T_LNG_ },
		{ "double", T_DBL_ },
		{ "if", IF_ },
		{ "else", ELSE_ },
		{ "for", FOR_ },
		{ "while", WHILE_ },
		{ "return", RETURN_ },
		{ "break", BREAK_ },
		{ "sizeof", SIZEOF_ },
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
			while ((c = getchar()) != '\n') {;}
        }
		else if (c == '\n') {
			line++;
		}
	} while (isspace(c));

	if (c == EOF) return 0;

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
            yylval.n = mknode(LIT_DEC, 0, 0);
            yylval.n->u.d = d;
            return LIT_DEC_;
		}
		else {
            ungetc(c, stdin);
            yylval.n = mknode(LIT_INT, 0, 0);
            yylval.n->u.n = n;
    		return LIT_INT_;
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
		yylval.n = mknode(NAME, 0, 0);
		strcpy(yylval.n->u.v, v);
		return NAME_;
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
		yylval.n = mknode('S', 0, 0);
		yylval.n->u.n = nglo++;
		return LIT_STR_;
	}

	c2 = getchar();
#define DI(a, b) a + b*256
	switch (DI(c,c2)) {
        case DI('!','='): return NE_;
        case DI('=','='): return EQ_;
        case DI('<','='): return LE_;
        case DI('>','='): return GE_;
        case DI('+','+'): return PP_;
        case DI('-','-'): return MM_;
        case DI('&','&'): return AND_;
        case DI('|','|'): return OR_;
        case DI('/','/'): {
            while ((c = getchar()) != '\n')
                ;
            ungetc(c, stdin);
            return LINE_COMMENT_;
        }
        case DI('.','.'): {
            c3 = getchar();
            if (c3 == '.') {
                fprintf(stderr, "DOTS\n");
                return DOTS_;
            }
            ungetc(c3, stdin);
        }
	}
#undef DI
	ungetc(c2, stdin);

    switch (c) {
        case '&': return AMPERSAND_;         // can be address or bitwise and
        case '*': return STAR_;              // can be pointer or multiply
        case '+': return PLUS_;              // can be positive or add
        case '-': return HYPHEN_;            // can be negative or subtract
        case '<': return ANGLE_L_;
        case '>': return ANGLE_R_;
        case '/': return SLASH_;
        case '=': return EQUALS_;
        case '%': return PERCENT_;
    }

	return c;
}


int yyerror(char *err) {
	die("parse error from yyerror");
	return 0;
}


int main() {
	int i;
	of = stdout;
	nglo = 1;
	if (yyparse() != 0) die("parse error");
	for (i=1; i<nglo; i++)
		fprintf(of, "data " GLOBAL "%d = %s\n", i, ini[i]);
	return 0;
}
