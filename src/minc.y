%{


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

// minic types
enum {
	NIL,
	INT,
	LNG,
	DBL,
	PTR,
	FUN,
};

#define IDIR(x) (((x) << 3) + PTR)
#define FUNC(x) (((x) << 3) + FUN)
#define DREF(x) ((x) >> 3)
#define KIND(x) ((x) & 7)
#define SIZE(x) (                                   \
    x == NIL ? (die("void has no size"), 0) : (     \
	x == INT ? 4 : (                                \
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


void ppCtype(unsigned long t) {
    int n = 0, i;
    while (t > 7) {
        n++;
        t = DREF(t);
    }
    switch (t) {
    case NIL:
        fprintf(stderr, "void ");
        break;
    case INT:
        fprintf(stderr, "int ");
        break;
    case LNG:
        fprintf(stderr, "long ");
        break;
    case DBL:
        fprintf(stderr, "double ");
        break;
	case FUN:
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




// SNIPETS for code gen

// was Glo%d now g%d
#define GLOBAL_1 "$g%d"
#define GLOBAL_2 "data $g%d = %s\n"

// was %%t%d now %%_%d
#define TEMP_1 "%%t%d"
#define TEMP_2 "\t%%t%d =l extsw "
#define TEMP_3 "\t%%t%d =d swtof "
#define TEMP_4 "\t%%t%d =d sltof "
#define TEMP_5 "\t%%t%d =l mul %d, "
#define TEMP_6 "\t%%t%d =l div "
#define TEMP_7 "%%t%d"
#define TEMP_8 "\tstore%c %%t%d"

// was %%%s now %%_%s
#define VAR_1 "%%_%s"
#define VAR_2 "\t%%_%s =l alloc%d %d\n"
#define VAR_3 ", %%_%s\n"
#define VAR_4 "\t%%_%s =l alloc%d %d\n"




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
    if (ctyp == NIL) die("void has no size");
    if (ctyp == INT) return 'w';
//    if (ctyp == LNG) return 'l';
    if (ctyp == DBL) return 'd';
//    if (ctyp == PTR) return 'l';
//    if (ctyp == FUN) return 'l';
	return 'l';
}


void psymb(Symb s) {
	switch (s.t) {
	case Tmp:
		fprintf(of, TEMP_1, s.u.n);
		break;
	case Var:
		fprintf(of, VAR_1, s.u.v);
		break;
	case Glo:
		fprintf(of, GLOBAL_1, s.u.n);
		break;
	case Con:
		fprintf(of, "%d", s.u.n);
		break;
	}
}


void l_extsw(Symb *s) {
	fprintf(of, TEMP_2, tmp);
	psymb(*s);
	fprintf(of, "\n");
	s->t = Tmp;
	s->ctyp = LNG;
	s->u.n = tmp++;
}


void d_swtof(Symb *s) {
	fprintf(of, TEMP_3, tmp);
	psymb(*s);
	fprintf(of, "\n");
	s->t = Tmp;
	s->ctyp = DBL;
	s->u.n = tmp++;
}


void d_sltof(Symb *s) {
	fprintf(of, TEMP_4, tmp);
	psymb(*s);
	fprintf(of, "\n");
	s->t = Tmp;
	s->ctyp = DBL;
	s->u.n = tmp++;
}


unsigned prom(int op, Symb *l, Symb *r) {
	Symb *t;
	int sz;

	if (l->ctyp == r->ctyp && KIND(l->ctyp) != PTR)
		return l->ctyp;

	if (l->ctyp == LNG && r->ctyp == INT) {
		l_extsw(r);
		return LNG;
	}
	if (l->ctyp == INT && r->ctyp == LNG) {
		l_extsw(l);
		return LNG;
	}
    if (l->ctyp == DBL && r->ctyp == INT) {
		d_swtof(r);
		return DBL;
	}
    if (l->ctyp == DBL && r->ctyp == LNG) {
		d_sltof(r);
		return DBL;
	}

	if (op == OP_ADD) {
		if (KIND(r->ctyp) == PTR) {
			t = l;
			l = r;
			r = t;
		}
		if (KIND(r->ctyp) == PTR) die("pointers added");
		goto Scale;
	}

	if (op == OP_SUB) {
		if (KIND(l->ctyp) != PTR) die("pointer substracted from integer");
		if (KIND(r->ctyp) != PTR) goto Scale;
		if (l->ctyp != r->ctyp) die("non-homogeneous pointers in substraction");
		return LNG;
	}

Scale:
	sz = SIZE(DREF(l->ctyp));
	if (r->t == Con)
		r->u.n *= sz;
	else {
		if (irtyp(r->ctyp) != 'l') l_extsw(r);
		fprintf(of, TEMP_5, tmp, sz);
		psymb(*r);
		fprintf(of, "\n");
		r->u.n = tmp++;
	}
	return l->ctyp;
}


void load(Symb d, Symb s) {
	char t;
	fprintf(of, "\t");
	psymb(d);
	t = irtyp(d.ctyp);
	fprintf(of, " =%c load%c ", t, t);
	psymb(s);
	fprintf(of, "\n");
}


void call(Node *n, Symb *sr) {
	Node *a;  unsigned ft;
	char *f = n->l->u.v;
	if (varget(f)) {
		ft = varget(f)->ctyp;
		if (KIND(ft) != FUN) die("invalid call");
	} else
		ft = FUNC(INT);
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
	case OP_AND:
		l = lbl;
		lbl += 3;
		bool(n, l, l+1);
		fprintf(of, "@L%d\n", l);
		fprintf(of, "\tjmp @L%d\n", l+2);
		fprintf(of, "@L%d\n", l+1);
		fprintf(of, "\tjmp @L%d\n", l+2);
		fprintf(of, "@L%d\n", l+2);
		fprintf(of, "\t");
		sr.ctyp = INT;
		psymb(sr);
		fprintf(of, " =w phi @L%d 1, @L%d 0\n", l, l+1);
		break;

	case 'V':
		s0 = lval(n);
		sr.ctyp = s0.ctyp;
		load(sr, s0);
		break;

	case 'N':
		sr.t = Con;
		sr.u.n = n->u.n;
		sr.ctyp = INT;
		break;

	case 'S':
		sr.t = Glo;
		sr.u.n = n->u.n;
		sr.ctyp = IDIR(INT);
		break;

	case OP_CALL:
		call(n, &sr);
		break;

	case '@':
		s0 = expr(n->l);
		if (KIND(s0.ctyp) != PTR)
			die("dereference of a non-pointer");
		sr.ctyp = DREF(s0.ctyp);
		load(sr, s0);
		break;

	case 'A':
		sr = lval(n->l);
		sr.ctyp = IDIR(sr.ctyp);
		break;

	case OP_ASSIGN:
		s0 = expr(n->r);
		s1 = lval(n->l);
		sr = s0;
		if (s1.ctyp == LNG && s0.ctyp == INT) l_extsw(&s0);
		if (s1.ctyp == DBL && s0.ctyp == INT) d_swtof(&s0);
		if (s1.ctyp == DBL && s0.ctyp == LNG) d_sltof(&s0);
		if (s0.ctyp != IDIR(NIL) || KIND(s1.ctyp) != PTR)
		if (s1.ctyp != IDIR(NIL) || KIND(s0.ctyp) != PTR)
		if (s1.ctyp != s0.ctyp) {
		    ppCtype(s1.ctyp);
		    fprintf(stderr, "%s = ", s1.u.v);
		    ppCtype(s0.ctyp);
		    fprintf(stderr, "\n");
		    die("invalid assignment");
        }
		fprintf(of, "\tstore%c ", irtyp(s1.ctyp));
		goto Args;

	case 'P':
	case 'M':
		o = n->op == 'P' ? OP_ADD : OP_SUB;
		sl = lval(n->l);
		s0.t = Tmp;
		s0.u.n = tmp++;
		s0.ctyp = sl.ctyp;
		load(s0, sl);
		s1.t = Con;
		s1.u.n = 1;
		s1.ctyp = INT;
		goto Binop;

	default:
		s0 = expr(n->l);
		s1 = expr(n->r);
		o = n->op;
	Binop:
		sr.ctyp = prom(o, &s0, &s1);
		if (strchr("ne<l", n->op)) {
			sprintf(ty, "%c", irtyp(sr.ctyp));
			sr.ctyp = INT;
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
	if (n->op == OP_SUB  &&  KIND(s0.ctyp) == PTR  &&  KIND(s1.ctyp) == PTR) {
		fprintf(of, TEMP_6, tmp);
		psymb(sr);
		fprintf(of, ", %d\n", SIZE(DREF(s0.ctyp)));
		sr.u.n = tmp++;
	}
	if (n->op == 'P'  ||  n->op == 'M') {
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
	case 'V':
		if (!varget(n->u.v)) {
		    fprintf(stderr, "%s is not defined\n", n->u.v);
		    die("undefined variable");
		}
		sr = *varget(n->u.v);
		break;
	case '@':
		sr = expr(n->l);
		if (KIND(sr.ctyp) != PTR) die("dereference of a non-pointer");
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
		fprintf(of, ", @L%d, @L%d\n", lt, lf);
		break;
	case OP_OR:
		l = lbl;
		lbl += 1;
		bool(n->l, lt, l);
		fprintf(of, "@L%d\n", l);
		bool(n->r, lt, lf);
		break;
	case OP_AND:
		l = lbl;
		lbl += 1;
		bool(n->l, l, lf);
		fprintf(of, "@L%d\n", l);
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
		fprintf(of, "\tjmp @L%d\n", b);
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
		fprintf(of, "@L%d\n", l);
		if (!(r=stmt(s->p2, b)))
		if (s->p3)
			fprintf(of, "\tjmp @L%d\n", l+2);
		fprintf(of, "@L%d\n", l+1);
		if (s->p3)
		if (!(r &= stmt(s->p3, b)))
			fprintf(of, "@L%d\n", l+2);
		return s->p3 && r;
	case While:
		l = lbl;
		lbl += 3;
		fprintf(of, "@L%d\n", l);
		bool(s->p1, l+1, l+2);
		fprintf(of, "@L%d\n", l+1);
		if (!stmt(s->p2, l+2))
			fprintf(of, "\tjmp @L%d\n", l);
		fprintf(of, "@L%d\n", l+2);
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
	n = mknode('@', n, 0);
	return n;
}


Node * mkneg(Node *n) {
	static Node *z;
	if (!z) {
		z = mknode('N', 0, 0);
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


Node * param(char *v, unsigned ctyp, Node *pl) {
	if (ctyp == NIL) die("invalid void declaration");
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
		tst = mknode('N', 0, 0);
		tst->u.n = 1;
	}
	s2 = mkstmt(While, tst, s2, 0);
	if (s1)
		return mkstmt(Seq, s1, s2, 0);
	else
		return s2;
}


%}


%union {
	Node *n;
	Stmt *s;
	unsigned u;
}

%token <n> TOK_INT
%token <n> TOK_STR
%token <n> IDENT
%token TOK_PP TOK_MM SIZEOF

%token TVOID TINT TLNG TDBL
%token IF ELSE WHILE FOR BREAK RETURN
%token LINE_COMMENT

%right TOK_EQUALS
%left TOK_OR
%left TOK_AND
%left TOK_AMPERSAND
%left TOK_EQ TOK_NE
%left TOK_LANGLE TOK_RANGLE TOK_LE TOK_GE
%left TOK_PLUS TOK_HYPHEN
%left TOK_STAR TOK_SLASH TOK_PERCENT

%type <u> type
%type <s> stmt stmts
%type <n> expr exp0 pref post arg0 arg1 par0 par1


%%

prog: func prog | fdcl prog | idcl prog | LINE_COMMENT prog |;

fdcl: type IDENT '(' ')' ';'    {
	varadd($2->u.v, 1, FUNC($1));
};

idcl: type IDENT ';'            {
	if ($1 == NIL) die("invalid void declaration");
	if (nglo == NGlo) die("too many string literals");
	ini[nglo] = alloc(sizeof "{ x 0 }");
	sprintf(ini[nglo], "{ %c 0 }", irtyp($1));
	varadd($2->u.v, nglo++, $1);
};

init:                           {
	varclr();
	tmp = 0;
};

func: init prot '{' dcls stmts '}'  {
	if (!stmt($5, -1)) fprintf(of, "\tret 0\n");
	fprintf(of, "}\n\n");
};

prot: IDENT '(' par0 ')'        {
	Symb *s;
	Node *n;
	int t, m;

	varadd($1->u.v, 1, FUNC(INT));
	fprintf(of, "export function w $%s(", $1->u.v);
	n = $3;
	if (n)
		for (;;) {
			s = varget(n->u.v);
			fprintf(of, "%c ", irtyp(s->ctyp));
			fprintf(of, TEMP_7, tmp++);
			n = n->r;
			if (n)
				fprintf(of, ", ");
			else
				break;
		}
	fprintf(of, ") {\n");
	fprintf(of, "@L%d\n", lbl++);
	for (t=0, n=$3; n; t++, n=n->r) {
		s = varget(n->u.v);
		m = SIZE(s->ctyp);
		fprintf(of, VAR_2, n->u.v, m, m);
		fprintf(of, TEMP_8, irtyp(s->ctyp), t);
		fprintf(of, VAR_3, n->u.v);
	}
};

par0: par1
    |                           { $$ = 0; };

par1: type IDENT ',' par1       { $$ = param($2->u.v, $1, $4); }
    | type IDENT                { $$ = param($2->u.v, $1, 0); };

dcls: | dcls type IDENT ';'     {
	int s;
	char *v;
	if ($2 == NIL) die("invalid void declaration");
	v = $3->u.v;
	s = SIZE($2);
	varadd(v, 0, $2);
	fprintf(of, VAR_4, v, s, s);
};

type: type TOK_STAR             { $$ = IDIR($1); }
    | TINT                      { $$ = INT; }
    | TLNG                      { $$ = LNG; }
    | TDBL                      { $$ = DBL; }
    | TVOID                     { $$ = NIL; };

stmt: ';'                                       { $$ = 0; }
    | LINE_COMMENT                              { $$ = 0; }
    | '{' stmts '}'                             { $$ = $2; }
    | BREAK ';'                                 { $$ = mkstmt(Break, 0, 0, 0); }
    | RETURN expr ';'                           { $$ = mkstmt(Ret, $2, 0, 0); }
    | expr ';'                                  { $$ = mkstmt(Expr, $1, 0, 0); }
    | WHILE '(' expr ')' stmt                   { $$ = mkstmt(While, $3, $5, 0); }
    | IF '(' expr ')' stmt ELSE stmt            { $$ = mkstmt(If, $3, $5, $7); }
    | IF '(' expr ')' stmt                      { $$ = mkstmt(If, $3, $5, 0); }
    | FOR '(' exp0 ';' exp0 ';' exp0 ')' stmt   { $$ = mkfor($3, $5, $7, $9); };

stmts: stmts stmt               { $$ = mkstmt(Seq, $1, $2, 0); }
    |                           { $$ = 0; };

expr: pref
    | expr TOK_EQUALS expr      { $$ = mknode(OP_ASSIGN, $1, $3); }
    | expr TOK_PLUS expr        { $$ = mknode(OP_ADD, $1, $3); }
    | expr TOK_HYPHEN expr      { $$ = mknode(OP_SUB, $1, $3); }
    | expr TOK_STAR expr        { $$ = mknode(OP_MUL, $1, $3); }
    | expr TOK_SLASH expr       { $$ = mknode(OP_DIV, $1, $3); }
    | expr TOK_PERCENT expr     { $$ = mknode(OP_REM, $1, $3); }
    | expr TOK_LANGLE expr      { $$ = mknode(OP_LT, $1, $3); }
    | expr TOK_RANGLE expr      { $$ = mknode(OP_LT, $3, $1); }
    | expr TOK_LE expr          { $$ = mknode(OP_LE, $1, $3); }
    | expr TOK_GE expr          { $$ = mknode(OP_LE, $3, $1); }
    | expr TOK_EQ expr          { $$ = mknode(OP_EQ, $1, $3); }
    | expr TOK_NE expr          { $$ = mknode(OP_NE, $1, $3); }
    | expr TOK_AND expr         { $$ = mknode(OP_AND, $1, $3); }
    | expr TOK_OR expr          { $$ = mknode(OP_OR, $1, $3); }
    | expr TOK_AMPERSAND expr   { $$ = mknode(OP_BAND, $1, $3); };

exp0: expr
    |                           { $$ = 0; };

pref: post
    | TOK_HYPHEN pref           { $$ = mkneg($2); }
    | TOK_STAR pref             { $$ = mknode('@', $2, 0); }
    | TOK_AMPERSAND pref        { $$ = mknode('A', $2, 0); };

post: TOK_INT
    | TOK_STR
    | IDENT
    | SIZEOF '(' type ')'       { $$ = mknode('N', 0, 0); $$->u.n = SIZE($3); }
    | '(' expr ')'              { $$ = $2; }
    | IDENT '(' arg0 ')'        { $$ = mknode(OP_CALL, $1, $3); }
    | post '[' expr ']'         { $$ = mkidx($1, $3); }
    | post TOK_PP               { $$ = mknode('P', $1, 0); }
    | post TOK_MM               { $$ = mknode('M', $1, 0); };

arg0: arg1
    |                           { $$ = 0; };

arg1: expr                      { $$ = mknode(0, $1, 0); }
    | expr ',' arg1             { $$ = mknode(0, $1, $3); };

%%



int yylex() {
	struct {
		char *s;
		int t;
	} kwds[] = {
		{ "void", TVOID },
		{ "int", TINT },
		{ "long", TLNG },
		{ "double", TDBL },
		{ "if", IF },
		{ "else", ELSE },
		{ "for", FOR },
		{ "while", WHILE },
		{ "return", RETURN },
		{ "break", BREAK },
		{ "sizeof", SIZEOF },
		{ 0, 0 }
	};
	int i, c, c2, n;
	char v[NString], *p;

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
		n = 0;
		do {
			n *= 10;
			n += c-'0';
			c = getchar();
		} while (isdigit(c));
		ungetc(c, stdin);
		yylval.n = mknode('N', 0, 0);
		yylval.n->u.n = n;
		return TOK_INT;
	}

	if (isalpha(c)) {
		p = v;
		do {
			if (p == &v[NString-1])
				die("ident too long");
			*p++ = c;
			c = getchar();
		} while (isalpha(c) || c == '_');
		*p = 0;
		ungetc(c, stdin);
		for (i=0; kwds[i].s; i++)
			if (strcmp(v, kwds[i].s) == 0)
				return kwds[i].t;
		yylval.n = mknode('V', 0, 0);
		strcpy(yylval.n->u.v, v);
		return IDENT;
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
		return TOK_STR;
	}

	c2 = getchar();
#define DI(a, b) a + b*256
	switch (DI(c,c2)) {
        case DI('!','='): return TOK_NE;
        case DI('=','='): return TOK_EQ;
        case DI('<','='): return TOK_LE;
        case DI('>','='): return TOK_GE;
        case DI('+','+'): return TOK_PP;
        case DI('-','-'): return TOK_MM;
        case DI('&','&'): return TOK_AND;
        case DI('|','|'): return TOK_OR;
        case DI('/','/'): {
            while ((c = getchar()) != '\n')
                ;
            ungetc(c, stdin);
            return LINE_COMMENT;
        }
	}
#undef DI
	ungetc(c2, stdin);

    switch (c) {
        case '&': return TOK_AMPERSAND;         // can be address or bitwise and
        case '*': return TOK_STAR;              // can be pointer or multiply
        case '+': return TOK_PLUS;              // can be positive or add
        case '-': return TOK_HYPHEN;            // can be negative or subtract
        case '<': return TOK_LANGLE;
        case '>': return TOK_RANGLE;
        case '/': return TOK_SLASH;
        case '=': return TOK_EQUALS;
        case '%': return TOK_PERCENT;
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
		fprintf(of, GLOBAL_2, i, ini[i]);
	return 0;
}
