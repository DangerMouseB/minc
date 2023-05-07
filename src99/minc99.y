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
 OP_OPERATION     (e.g. OP_ADD, except IDENT, LIT_INT, LIT_DEC, LIT_STR)
 T_TYPE



 *** NOTES ***

 OPEN: move the global variables into a struct? Actually we only need to do that if we want the compiler to be
 reentrant in Python. Which we probably don't need.


 minc stuff - hide as much as possible
 c stuff
 qbe ir stuff

https://cdecl.org/



 NEXT
 use g_<name> for declared globals
 use g<seed> for literal strings

 store function definitions with their types -> check types on call AND insert ellipses properly
 need a function struct

 check emission conforms to minic

*/


/*Beginning of C declarations*/


#include <stdarg.h>
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include "minc.h"


int yylex(void);

void yyerror(char const *);


#define GLOBAL  "$g"
#define TEMP    "%%t"
#define LOCAL   "%%_"
#define LABEL   "@L"


Symb emitexpr(Node *);

Symb lval(Node *);

void emitboolop(Node *, int, int);

void emitLocalDecl(int t, char *varname);



// Node construction

unsigned int pointerise(unsigned int ctyp, Node *ptr, int isarray) {
    // OPEN check for const, volatile, restrict
    while (ptr) {
        assertOp(ptr, "ptr", pt_pointer, __LINE__);
        if (ptr->l->tok == T_PTR) {
            ctyp <<= 8;
            ctyp |= T_PTR;
        }
        ptr = ptr->r;
    }
    if (isarray) {
        ctyp <<= 8;
        ctyp |= T_PTR;
    }
    return ctyp;
}

Node *nodepp(int tok, Node *l, Node *r, int lineno, int level, char *msg, ...) {
    if (level & g_logging_level) {
        va_list args;
        va_start(args, msg);
        vfprintf(stderr, msg, args);
        fprintf(stderr, "\n");
        va_end(args);
    }
    return node(tok, l, r, lineno);
}

Node * mkidx(Node *a, Node *i, int lineno) {
    Node *n = node(OP_ADD, a, i, lineno);
    n = node(OP_DEREF, n, 0, lineno);
    return n;
}

Node * mkneg(Node *n, int lineno) {
    static Node *z;
    if (!z) {
        z = node(LIT_INT, 0, 0, lineno);
        z->s.u.n = 0;
    }
    return node(OP_SUB, z, n, lineno);
}

Node * mkparam(char *v, unsigned ctyp, Node *others, int lineno) {
    if (ctyp == T_VOID)
        die("invalid void declaration");
    Node *n = node(0, 0, others, lineno);
    varadd(v, 0, ctyp);
    strcpy(n->s.u.v, v);
    return n;
}

// declaration_specifiers, declarator
Node * c99_mkparam(Node *ds, Node *d, int lineno) {
    return mkparam(d->s.u.v, ds->s.ctyp, 0, lineno);
}

Node * mkifelse(void *c, Node *t, Node *f, int lineno) {
    return node(IfElse, c, node(Else, t, f, lineno), lineno);
}

Node * mkfor(Node *ini, Node *tst, Node *inc, Node *s, int lineno) {
    Node *s1, *s2;
    if (ini)
        s1 = ini;
    else
        s1 = 0;
    if (inc) {
        s2 = inc;
        s2 = node(Seq, s, s2, lineno);
    } else
        s2 = s;
    if (!tst) {
        tst = node(LIT_INT, 0, 0, lineno);
        tst->s.u.n = 1;
    }
    s2 = node(While, tst, s2, lineno);
    if (s1)
        return node(Seq, s1, s2, lineno);
    else
        return s2;
}

Node * mkopassign(Node *n, Node *l, Node *r, int lineno) {
    PP(parse, "mkopassign %d:%s\n", n->tok, toktopp[n->tok]);
    if (n->l != 0) die("n->l != 0 @ %d", __LINE__);
    if (n->r != 0) die("n->r != 0 @ %d", __LINE__);
    n->l = l;
    n->r = r;
    return node(OP_ASSIGN, l, n, lineno);
}

Node * mktype(int tok, enum tok t, int lineno) {
    Node * n = node(tok, 0, 0, lineno);
    n->s.ctyp = t;
    return n;
}

Node * appendR(Node * start, Node * next) {
    if (start) {
        Node * end = start;
        while (end->r) end = end->r;
        end->r = next;
        return start;
    }
    else
        return next;
}

Node * mkidentifierlist(Node * start, char * identifier, int lineno) {
    Node * next = node(pt_identifier_list, 0, 0, lineno);
    next->s.u.v = identifier;
    return appendR(start, next);
}

Node * mkinitdeclaratorlist(Node * start, Node * initdeclarator, int lineno) {
    Node * next = node(pt_init_declarator_list, initdeclarator, 0, lineno);
    return appendR(start, next);
}

Node * mkparametertypelist(Node * start, Node * parameterdeclarationOrELLIPSIS, int lineno) {
    Node * next = node(pt_parameter_type_list, parameterdeclarationOrELLIPSIS, 0, lineno);
    return appendR(start, next);
}

Node * mktypequalifierlist(Node * start, Node * typequalifier, int lineno) {
    Node * next = node(pt_type_qualifier_list, typequalifier, 0, lineno);
    return appendR(start, next);
}

Node * mkargumentexpressionlist(Node * start, Node * expr, int lineno) {
    Node * next = node(pt_argument_expression_list, expr, 0, lineno);
    return appendR(start, next);
}


// QBE IR emission

void emitsymb(Symb s) {
    switch (s.t) {
        case Tmp:
            putq(TEMP "%d", s.u.n);
            break;
        case Loc:
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
        case T_LONG: return 'l';
        case T_DOUBLE: return 'd';
        case T_PTR: return 'l';
        case T_FUN: return 'l';
    }
    die("unhandled type %d @ %d", KIND(ctyp), __LINE__);
    return 'l';
}


void l_extsw(Symb *s) {
    putq(INDENT TEMP "%d =l extsw ", tmp);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->ctyp = T_LONG;
    s->u.n = reserveTmp();
}


void d_swtof(Symb *s) {
    putq(INDENT TEMP "%d =d swtof ", tmp);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->ctyp = T_DOUBLE;
    s->u.n = reserveTmp();
}


void d_sltof(Symb *s) {
    putq(INDENT TEMP "%d =d sltof ", tmp);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->ctyp = T_DOUBLE;
    s->u.n = reserveTmp();
}


unsigned prom(int tok, Symb *l, Symb *r) {
    Symb *t;
    int sz;

    if (l->ctyp == r->ctyp && KIND(l->ctyp) != T_PTR)
        return l->ctyp;

    if (l->ctyp == T_LONG && r->ctyp == T_INT) {
        l_extsw(r);
        return T_LONG;
    }
    if (l->ctyp == T_INT && r->ctyp == T_LONG) {
        l_extsw(l);
        return T_LONG;
    }
    if (l->ctyp == T_DOUBLE && r->ctyp == T_INT) {
        d_swtof(r);
        return T_DOUBLE;
    }
    if (l->ctyp == T_DOUBLE && r->ctyp == T_LONG) {
        d_sltof(r);
        return T_DOUBLE;
    }

    if (tok == OP_ADD) {
        // OPEN: handle double
        if (KIND(r->ctyp) == T_PTR) {
            t = l;
            l = r;
            r = t;
        }
        if (KIND(r->ctyp) == T_PTR) die("pointers added");
        goto Scale;
    }

    if (tok == OP_SUB) {
        // OPEN: handle double
        if (KIND(l->ctyp) != T_PTR) die("pointer substracted from integer");
        if (KIND(r->ctyp) != T_PTR) goto Scale;
        if (l->ctyp != r->ctyp) die("non-homogeneous pointers in substraction");
        return T_LONG;
    }

Scale:
    // OPEN: handle double
    sz = SIZE(DREF(l->ctyp));
    if (r->t == Con)
        r->u.n *= sz;
    else {
        if (irtyp(r->ctyp) != 'l') l_extsw(r);
        putq(INDENT TEMP "%d =l mul %d, ", tmp, sz);
        emitsymb(*r);
        putq("\n");
        r->u.n = reserveTmp();
    }
    return l->ctyp;
}


void emitload(Symb d, Symb s) {
    putq(INDENT);
    emitsymb(d);
    putq(" =%c load%c ", irtyp(d.ctyp), irtyp(d.ctyp));
    emitsymb(s);
    putq("\n");
}


void emitcall(Node *n, Symb *sr) {
    Node *a;  unsigned ft = 0;  int iEllipses, iArg;
    char *f = n->l->s.u.v;
    // OPEN: get ellipses location from function parameter types
    if (strcmp(f, "printf") == 0) iEllipses = 2;
    if (strcmp(f, "fprintf") == 0) iEllipses = 3;
    if (varget(f)) {
        ft = varget(f)->ctyp;
        if (KIND(ft) != T_FUN) die("invalid call");
    } else
        ft = FUNC(T_INT);
    sr->ctyp = DREF(ft);
    for (a=n->r; a; a=a->r)
        a->s = emitexpr(a->l);
    putq(INDENT);
    emitsymb(*sr);
    putq(" =%c call $%s(", irtyp(sr->ctyp), f);
    a = n->r; iArg = 1;
    while (a) {
        if (iArg == iEllipses) putq("..., ");
        putq("%c ", irtyp(a->s.ctyp));
        emitsymb(a->s);
        a = a->r;
        if (a) putq(", ");
        iArg++;
    }
    putq(")\n");
}


Symb emitexpr(Node *n) {
    static const char neltl[] = {OP_NE, OP_EQ, OP_LT, OP_LE, };
    static char *otoa[] = {
            [OP_ADD] = "add",
            [OP_SUB] = "sub",
            [OP_MUL] = "mul",
            [OP_DIV] = "div",
            [OP_MOD] = "rem",
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
    sr.u.n = reserveTmp();

    switch (n->tok) {

        // both these short circuit
        case OP_OR:
        case OP_AND:
            l = reserve(3);
            emitboolop(n, l, l+1);
            putq(LABEL "%d\n", l);
            putq(INDENT "jmp " LABEL "%d\n", l+2);
            putq(LABEL "%d\n", l+1);
            putq(INDENT "jmp " LABEL "%d\n", l+2);
            putq(LABEL "%d\n", l+2);
            putq(INDENT);
            sr.ctyp = T_INT;
            emitsymb(sr);
            putq(" =w phi " LABEL "%d 1, " LABEL "%d 0\n", l, l+1);
            break;

        case IDENT:
            s0 = lval(n);
            sr.ctyp = s0.ctyp;
            emitload(sr, s0);
            break;

        case LIT_DEC:
            sr.t = Con;
            sr.u.d = n->s.u.d;
            sr.ctyp = T_DOUBLE;
            break;

        case LIT_INT:
            sr.t = Con;
            sr.u.n = n->s.u.n;
            sr.ctyp = T_INT;
            break;

        case LIT_STR:
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

        case OP_ASSIGN:
            s0 = emitexpr(n->r);
            s1 = lval(n->l);
            sr = s0;
            if (s1.ctyp == T_LONG && s0.ctyp == T_INT) l_extsw(&s0);
            if (s1.ctyp == T_DOUBLE && s0.ctyp == T_INT) d_swtof(&s0);
            if (s1.ctyp == T_DOUBLE && s0.ctyp == T_LONG) d_sltof(&s0);
            if (s0.ctyp != IDIR(T_VOID) || KIND(s1.ctyp) != T_PTR)
                if (s1.ctyp != IDIR(T_VOID) || KIND(s0.ctyp) != T_PTR)
                    if (s1.ctyp != s0.ctyp) {
                        ppCtype(s1.ctyp);
                        PP(emit, "%s = ", s1.u.v);
                        ppCtype(s0.ctyp);
                        PP(emit, "\n");
                        die("invalid assignment");
                    }
            putq(INDENT "store%c ", irtyp(s1.ctyp));
            goto Args;

        case OP_INC:
        case OP_DEC:
            o = n->tok == OP_INC ? OP_ADD : OP_SUB;
            sl = lval(n->l);
            s0.t = Tmp;
            s0.u.n = reserveTmp();
            s0.ctyp = sl.ctyp;
            emitload(s0, sl);
            s1.t = Con;
            s1.u.n = 1;
            s1.ctyp = T_INT;
            goto Binop;

        default:
            if ((OP_BIN_START <= n->tok) && (n->tok <= OP_BIN_END)) {
                s0 = emitexpr(n->l);
                s1 = emitexpr(n->r);
                o = n->tok;
            }
            else {
                die("%s is not an expression", toktopp[n->tok]);
                return sr;
            }
        Binop:
            sr.ctyp = prom(o, &s0, &s1);
            if (strchr(neltl, n->tok)) {
                sprintf(ty, "%c", irtyp(sr.ctyp));
                sr.ctyp = T_INT;
            } else
                strcpy(ty, "");
            putq(INDENT);
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
    if (n->tok == OP_SUB  &&  KIND(s0.ctyp) == T_PTR  &&  KIND(s1.ctyp) == T_PTR) {
        putq(INDENT TEMP "%d =l div ", tmp);
        emitsymb(sr);
        putq(", %d\n", SIZE(DREF(s0.ctyp)));
        sr.u.n = reserveTmp();
    }
    if (n->tok == OP_INC  ||  n->tok == OP_DEC) {
        putq(INDENT "store%c ", irtyp(sl.ctyp));
        emitsymb(sr);
        putq(", ");
        emitsymb(sl);
        putq("\n");
        sr = s0;
    }
    return sr;
}


//<:Symb> lval(<:Node&ptr> n) {
//<:Symb> lval(<:pNode> n) {
Symb lval(Node *n) {
    Symb sr;
    switch (n->tok) {
        default:
            die("invalid lvalue");
        case IDENT:
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
    switch (n->tok) {
        default:
            s = emitexpr(n); /* OPEN: insert comparison to 0 with proper type */
            putq(INDENT "jnz ");
            emitsymb(s);
            putq(", " LABEL "%d, " LABEL "%d\n", lt, lf);
            break;
        case OP_OR:
            l = reserve(1);
            emitboolop(n->l, lt, l);
            putq(LABEL "%d\n", l);
            emitboolop(n->r, lt, lf);
            break;
        case OP_AND:
            l = reserve(1);
            emitboolop(n->l, l, lf);
            putq(LABEL "%d\n", l);
            emitboolop(n->r, lt, lf);
            break;
    }
}


int emitstmt(Node *s, int b) {
    int l, r;  Symb x;  unsigned int ctyp;  char *varname;

    if (!s) return 0;
    PP(emit, "%s", toktopp[s->tok]);

    switch (s->tok) {
        case pt_declaration:
            assertOp(s, "s", pt_declaration, __LINE__);
            assertOp(s->l, "s->l", pt_declaration_specifiers, __LINE__);
            assertOp(s->l->l, "s->l->l", pt_type_specifier, __LINE__);
            ctyp = s->l->l->s.ctyp;
            ctyp = pointerise(ctyp, s->l->r, 0);
            varname = s->r->l->l->r->s.u.v;
            emitLocalDecl(ctyp, varname);
            return 0;
        case Ret:
            PP(emit, "Ret");
            if (s->l) {
                x = emitexpr(s->l);
                putq(INDENT "ret ");
                emitsymb(x);
            }
            else
                putq(INDENT "ret");
            putq("\n");
            return 1;
        case Break:
            if (b < 0) die("break not in loop");
            putq(INDENT "jmp " LABEL "%d\n", b);
            return 1;
        case Seq:
            return emitstmt(s->l, b) || emitstmt(s->r, b);
        case If:
            l = reserve(2);
            emitboolop(s->l, l, l+1);
            putq(LABEL "%d\n", l);
            emitstmt(s->r, b);
            putq(LABEL "%d\n", l+1);
            return 0;
        case IfElse:
            l = reserve(3);
            emitboolop(s->l, l, l+1);
            putq(LABEL "%d\n", l);
            Node * e = s->r;
            if (!(r=emitstmt(e->l, b)))
                putq(INDENT "jmp " LABEL "%d\n", l+2);
            putq(LABEL "%d\n", l+1);
            if (!(r &= emitstmt(e->r, b)))
                putq(LABEL "%d\n", l+2);
            return e->r && r;
        case While:
            l = reserve(3);
            putq(LABEL "%d\n", l);
            emitboolop(s->l, l+1, l+2);
            putq(LABEL "%d\n", l+1);
            if (!emitstmt(s->r, l+2))
                putq(INDENT "jmp " LABEL "%d\n", l);
            putq(LABEL "%d\n", l+2);
            return 0;
        case Label:
        case Else:
        case Select:
        case Case:
        case Continue:
        case Goto:
        case Do:
            nyi("%d:\"%s\" @ %d", s->tok, toktopp[s->tok], s->lineno);
        default:
            if ((OP_EXPR_START <= s->tok) && (s->tok <= OP_EXPR_END))
                emitexpr(s);
            else
                die("invalid statement %d:\"%s\" @ %d", s->tok, toktopp[s->tok], s->lineno);
            return 0;
    }
}


void startFunc(unsigned long t, char *fnname, NameType *params) {
    NameType *p;  int i, m;
    PP(emit, "startFunc: %s", fnname);

    varadd(fnname, 1, FUNC(t));
    if (t == T_VOID)
        putq("export function $%s(", fnname);
    else
        putq("export function %c $%s(", irtyp(t), fnname);
    if ((p=params))
        do {
            varadd(p->name, 0, p->ctyp);
            putq("%c ", irtyp(p->ctyp));
            putq(TEMP "%d", reserveTmp());
            p = p->next;
            if (p) putq(", ");
        } while (p);
    putq(") {\n");
    putq(LABEL "%d\n", reserve(1));
    for (i=SEED_START, p=params; p; i++, p=p->next) {
        m = SIZE(p->ctyp);
        putq(INDENT LOCAL "%s =l alloc%d %d\n", p->name, m, m);
        putq(INDENT "store%c " TEMP "%d", irtyp(p->ctyp), i);
        putq(", " LOCAL "%s\n", p->name);
    }
}


void finishFunc(Node *s) {
    PP(emit, "finishFunc");
    if (!emitstmt(s, -1)) putq(INDENT "ret\n");    // for the case of a void function with no return statement
    putq("}\n\n");
    varclr();
}


NameType * ptparametertypelistToParameters(Node * ptl) {
    NameType *start=0, *next, *prior=0;  Node *pd, *ds, *d, *id, *ts;  int is_array = 0;
    if (!ptl) return NULL;
    while(ptl) {
        next = allocInArena(&nodes, sizeof (NameType), alignof (NameType));
        if (!start) start = next;
        if (prior) prior->next = next;
        assertOp(ptl, "ptl", pt_parameter_type_list, __LINE__);
        assertExists((pd=ptl->l), "ptl->l", __LINE__);
        assertOp(pd, "pd", pt_parameter_declaration, __LINE__);
        assertExists((ds=pd->l), "pd->l", __LINE__);
        assertOp(ds, "ds", pt_declaration_specifiers, __LINE__);
        assertExists((d=pd->r), "pd->r", __LINE__);
        assertOp(d, "d", pt_declarator, __LINE__);
        assertExists((id=d->r), "d->r", __LINE__);
        switch (id->tok) {
            case IDENT:
                break;
            case pt_array:
                is_array = 1;
                id = id->l;
                break;
            default:
                nyi("@ %d", __LINE__);
        }
        assertOp(id, "id", IDENT, __LINE__);
        next->name = id->s.u.v;
        assertExists((ts=ds->l), "ds->l", __LINE__);
        assertOp(ts, "td", pt_type_specifier, __LINE__);
        if (ds->r) nyi("@ %d", __LINE__);           // OPEN handle pointers and const etc
        next->ctyp = pointerise(ts->s.ctyp, d->l, is_array);
        ptl = ptl->r;
        prior = next;
    }
    return start;
}

BTYPE_ID ptdeclarationspecifiersToBTypeId(Node *ds) {
    // OPEN: convert tokens to the correct hardcoded btyp enum
    BTYPE_ID t;
    nyi("here");
    t = ds->l->s.ctyp;
    if ((t != T_INT) && (t != T_DOUBLE) && (t != T_VOID)) die("t == %s @ %d", toktopp[t], __LINE__);
    return t;
}

// declaration_specifiers, declarator, declaration_list, compound_statement
void c99_emit_function_definition(Node *ds, Node *d, Node *dl, Node* cs) {
    NameType *params = 0;  unsigned int t;
    PP(emit, "c99_emit_function_definition");
    assertOp(ds, "ds", pt_declaration_specifiers, __LINE__);
    assertOp(d, "d", pt_declarator, __LINE__);
    t = ptdeclarationspecifiersToBTypeId(ds);
    t = pointerise(t, d->l, 0);
    assertOp(d->r, "d->r", func_def, __LINE__);
    assertExists(d->r->l, "d->r->l", __LINE__);
    assertOp(d->r->l, "d->r->l", IDENT, __LINE__);
    if (d->r->r) {
        assertOp(d->r->r, "d->r->r", pt_parameter_type_list, __LINE__);
        params = ptparametertypelistToParameters(d->r->r);
    }
    startFunc(t, d->r->l->s.u.v, params);
    finishFunc(cs);
}


void emitLocalDecl(int t, char *varname) {
    PP(emit, "emitLocalDecl\n");
    // OPEN: allow multiple names for each type
    int s;
    if (t == T_VOID) die("invalid void declaration");
    PP(emit, "varname: %s\n", varname);
    s = SIZE(t);
    varadd(varname, 0, t);
    putq(INDENT LOCAL "%s =l alloc%d %d\n", varname, s, s);
}


void declareGlobal(int t, char* v) {
    if (oglo == NGlo) die("too many string literals");
    globals[oglo] = allocInArena(&strings, sizeof "{ x 0 }", 1);
    sprintf(globals[oglo], "{ %c 0 }", irtyp(t));
    varadd(v, oglo++, t);
}


// declaration
void c99_emit_declaration(Node *n) {
    // declaration_specifiers, init_declarator_list, init_declarator, declarator
    Node *ds, *idl, *id, *d;  unsigned int ctyp;  char *name;  int isVoid;
    PP(parse, "c99_emit_declaration\n");
    assertOp(n, "n", pt_declaration, __LINE__);
    // get the common type
    assertOp((ds=n->l), "n->l", pt_declaration_specifiers, __LINE__);
    switch (ds->l->tok) {
        default:
            die("unexpect tok %s @ %d", toktopp[n->tok], __LINE__);
            return;
        case pt_storage_class_specifier:
            // T_TYPEDEF, T_EXTERN, T_STATIC, T_AUTO, T_REGISTER
            die("unhandled declaration specifiers->l->tok %s", toktopp[n->tok]);
            return;
        case pt_type_specifier:
            ctyp = ds->l->s.ctyp;
            isVoid = ctyp == T_VOID;
            if ((ctyp == T_STRUCT) || (ctyp == T_STRUCT) || (ctyp == T_UNION) || (ctyp == T_TYPEDEF) || (ctyp == T_TYPE_NAME))
                nyi("%s @ %d", toktopp[n->tok], __LINE__);
            break;
        case pt_type_qualifier:
            // CONST, RESTRICT, VOLATILE
            nyi("%s @ %d", toktopp[n->tok], __LINE__);
            return;
        case T_INLINE:  // aka function_specifier
            // INLINE
            nyi("%s @ %d", toktopp[n->tok], __LINE__);
            return;
    }
    // process each declarator
    assertOp((idl=n->r), "n->r", pt_init_declarator_list, __LINE__);
    do {
        assertOp((id=idl->l), "idl->l", pt_init_declarator, __LINE__);
        if (id->r) nyi("declarator '=' initializer");
        if ((d=id->l)->tok != pt_declarator) die("programmer error: d->tok != pt_declarator");
        if (d->r->tok == IDENT) {
            if (isVoid) die("invalid void declaration @ %d", d->lineno);
            name = d->r->s.u.v;
            declareGlobal(pointerise(ctyp, d->l, 0), name);
        }
        else
            PP(parse, "c99_emit_declaration encountered %s @ %d", toktopp[d->r->tok], d->lineno);
            // OPEN: capture function argument types for type checking including handling variable length signatures
        idl = idl->r;
    } while (idl);
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
%token XOR_ASSIGN OR_ASSIGN
%token <n> TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER INLINE RESTRICT
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token BOOL COMPLEX IMAGINARY
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%start translation_unit

%type <n> expression pointer unary_operator assignment_expression unary_expression assignment_operator cast_expression
%type <n> type_name compound_statement declarator declaration_list block_item_list declaration declaration_specifiers
%type <n> primary_expression postfix_expression initializer_list designation initializer designator_list
%type <n> multiplicative_expression cast_expression additive_expression shift_expression relational_expression
%type <n> equality_expression and_expression exclusive_or_expression inclusive_or_expression logical_and_expression
%type <n> logical_or_expression conditional_expression enumerator type_qualifier constant_expression designator
%type <n> labeled_statement statement expression_statement selection_statement iteration_statement jump_statement
%type <n> storage_class_specifier function_specifier struct_or_union parameter_list direct_declarator translation_unit
%type <n> external_declaration type_specifier parameter_declaration parameter_type_list direct_abstract_declarator
%type <n> abstract_declarator init_declarator_list block_item argument_expression_list identifier_list
%type <n> init_declarator specifier_qualifier_list type_qualifier_list



%%

primary_expression
: IDENTIFIER
| CONSTANT
| STRING_LITERAL
| '(' expression ')'                                    { $$ = $2;}
;

postfix_expression
: primary_expression                                    { PP(pt, "primary_expression   =>   postfix_expression", $%); }
| postfix_expression '[' expression ']'                 { $$ = nodepp(OP_INDEX, $1, $3, $%, pt, "postfix_expression '[' expression ']'   =>   postfix_expression"); }
| postfix_expression '(' ')'                            { $$ = nodepp(OP_CALL, $1, 0, $%, pt, "postfix_expression '(' ')'   =>   postfix_expression"); }
| postfix_expression '(' argument_expression_list ')'   { $$ = nodepp(OP_CALL, $1, $3, $%, pt, "postfix_expression '(' argument_expression_list ')'   =>   postfix_expression"); }
| postfix_expression '.' IDENTIFIER                     { nyi("@ %d", $%); }
| postfix_expression PTR_OP IDENTIFIER                  { nyi("@ %d", $%); }
| postfix_expression INC_OP                             { $$ = nodepp(OP_INC, $1, 0, $%, pt, "postfix_expression INC_OP   =>   postfix_expression"); }
| postfix_expression DEC_OP                             { $$ = nodepp(OP_DEC, $1, 0, $%, pt, "postfix_expression DEC_OP   =>   postfix_expression"); }
| '(' type_name ')' '{' initializer_list '}'            { nyi("@ %d", $%); }
| '(' type_name ')' '{' initializer_list ',' '}'        { nyi("@ %d", $%); }
;

argument_expression_list
: assignment_expression                                 { $$ = mkargumentexpressionlist(0, $1, $%); }
| argument_expression_list ',' assignment_expression    { $$ = mkargumentexpressionlist($1, $3, $%); }
;

unary_expression
: postfix_expression
| INC_OP unary_expression                               { $$ = node(OP_INC, 0, $2, $%); }
| DEC_OP unary_expression                               { $$ = node(OP_DEC, 0, $2, $%); }
| unary_operator cast_expression                        { $$ = bindl($1, $2, $%); }
| SIZEOF unary_expression                               { $$ = node(LIT_INT, 0, 0, $%); $$->s.u.n = SIZE($2); }
| SIZEOF '(' type_name ')'                              { $$ = node(LIT_INT, 0, 0, $%); $$->s.u.n = SIZE($3); }
;

unary_operator
: '&'                                                   { $$ = node(OP_ADDR, 0, 0, $%); }
| '*'                                                   { $$ = node(OP_DEREF, 0, 0, $%); }
| '+'                                                   { $$ = 0; }
| '-'                                                   { $$ = node(OP_NEG, 0, 0, $%); }
| '~'                                                   { $$ = node(OP_BINV, 0, 0, $%); }
| '!'                                                   { $$ = node(OP_NOT, 0, 0, $%); }
;

cast_expression
: unary_expression                                      { $$ = $1; }
| '(' type_name ')' cast_expression                     { nyi("@ %d", $%); }
;

multiplicative_expression
: cast_expression                                       { $$ = $1; }
| multiplicative_expression '*' cast_expression         { $$ = node(OP_MUL, $1, $3, $%); }
| multiplicative_expression '/' cast_expression         { $$ = node(OP_DIV, $1, $3, $%); }
| multiplicative_expression '%' cast_expression         { $$ = node(OP_MOD, $1, $3, $%); }
;

additive_expression
: multiplicative_expression                             { $$ = $1; }
| additive_expression '+' multiplicative_expression     { $$ = node(OP_ADD, $1, $3, $%); }
| additive_expression '-' multiplicative_expression     { $$ = node(OP_SUB, $1, $3, $%); }
;

shift_expression
: additive_expression                                   { $$ = $1; }
| shift_expression LEFT_OP additive_expression          { $$ = node(OP_LSHIFT, $1, $3, $%); }
| shift_expression RIGHT_OP additive_expression         { $$ = node(OP_RSHIFT, $1, $3, $%); }
;

relational_expression
: shift_expression                                      { $$ = $1; }
| relational_expression '<' shift_expression            { $$ = node(OP_LT, $1, $3, $%); }
| relational_expression '>' shift_expression            { $$ = node(OP_LT, $3, $1, $%); }
| relational_expression LE_OP shift_expression          { $$ = node(OP_LE, $1, $3, $%); }
| relational_expression GE_OP shift_expression          { $$ = node(OP_LE, $3, $1, $%); }
;

equality_expression
: relational_expression                                 { $$ = $1; }
| equality_expression EQ_OP relational_expression       { $$ = node(OP_EQ, $1, $3, $%); }
| equality_expression NE_OP relational_expression       { $$ = node(OP_NE, $1, $3, $%); }
;

and_expression
: equality_expression                                   { $$ = $1; }
| and_expression '&' equality_expression                { $$ = node(OP_BAND, $1, $3, $%); }
;

exclusive_or_expression
: and_expression                                        { $$ = $1; }
| exclusive_or_expression '^' and_expression            { $$ = node(OP_BXOR, $1, $3, $%); }
;

inclusive_or_expression
: exclusive_or_expression                               { $$ = $1; }
| inclusive_or_expression '|' exclusive_or_expression   { $$ = node(OP_ADD, $1, $3, $%); }
;

logical_and_expression
: inclusive_or_expression                               { $$ = $1; }
| logical_and_expression AND_OP inclusive_or_expression { $$ = node(OP_ADD, $1, $3, $%); }
;

logical_or_expression
: logical_and_expression                                { $$ = $1; }
| logical_or_expression OR_OP logical_and_expression    { $$ = node(OP_ADD, $1, $3, $%); }
;

conditional_expression
: logical_or_expression                                             { $$ = $1; }
| logical_or_expression '?' expression ':' conditional_expression   { $$ = node(OP_IIF, $1, node(OP_TF, $3, $5, $%), $%); }
;

assignment_expression
: conditional_expression                                        { $$ = $1; }
| unary_expression assignment_operator assignment_expression    { $$ = mkopassign($2, $1, $3, $%); }
;

assignment_operator
: '='                                                   { $$ = node(OP_ASSIGN, 0, 0, $%); }
| MUL_ASSIGN                                            { $$ = node(OP_MUL, 0, 0, $%); }
| DIV_ASSIGN                                            { $$ = node(OP_DIV, 0, 0, $%); }
| MOD_ASSIGN                                            { $$ = node(OP_MOD, 0, 0, $%); }
| ADD_ASSIGN                                            { $$ = node(OP_ADD, 0, 0, $%); }
| SUB_ASSIGN                                            { $$ = node(OP_SUB, 0, 0, $%); }
| LEFT_ASSIGN                                           { $$ = node(OP_LSHIFT, 0, 0, $%); }
| RIGHT_ASSIGN                                          { $$ = node(OP_RSHIFT, 0, 0, $%); }
| AND_ASSIGN                                            { $$ = node(OP_BAND, 0, 0, $%); }
| XOR_ASSIGN                                            { $$ = node(OP_BXOR, 0, 0, $%); }
| OR_ASSIGN                                             { $$ = node(OP_BOR, 0, 0, $%); }
;

expression
: assignment_expression                                 { $$ = $1; }
| expression ',' assignment_expression                  { nyi("@ %d", $%); }
;

constant_expression
: conditional_expression                                { $$ = $1; }
;

// OPEN: how do we capture the following?
// l=NULL, then l=declaration_specifiers, r=remainder
// l=NULL or prior, r=this?
declaration
: declaration_specifiers ';'                            { nyi("declaration_specifiers ';'   =>   declaration"); }
| declaration_specifiers init_declarator_list ';'       { $$ = nodepp(pt_declaration, $1, $2, $%, pt, "declaration_specifiers init_declarator_list ';'  =>  declaration"); }
;

// reverse of init_declarator_list
declaration_specifiers
: storage_class_specifier                               { PP(pt, "storage_class_specifier   =>   declaration_specifiers"); $$ = node(pt_declaration_specifiers, $1, 0, $%); }
| storage_class_specifier declaration_specifiers        { PP(pt, "type_specifier declaration_specifiers   =>   declaration_specifiers"); $$ = node(pt_declaration_specifiers, $1, $2, $%); }
| type_specifier                                        { PP(pt, "type_specifier   =>   declaration_specifiers"); $$ = node(pt_declaration_specifiers, $1, 0, $%); }
| type_specifier declaration_specifiers                 { PP(pt, "type_specifier declaration_specifiers   =>   declaration_specifiers"); $$ = node(pt_declaration_specifiers, $1, $2, $%); }
| type_qualifier                                        { PP(pt, "type_qualifier   =>   declaration_specifiers"); $$ = node(pt_declaration_specifiers, $1, 0, $%); }
| type_qualifier declaration_specifiers                 { PP(pt, "type_qualifier declaration_specifiers   =>   declaration_specifiers"); $$ = node(pt_declaration_specifiers, $1, $2, $%); }
| function_specifier                                    { PP(pt, "function_specifier   =>   declaration_specifiers"); $$ = node(pt_declaration_specifiers, $1, 0, $%); }
| function_specifier declaration_specifiers             { PP(pt, "function_specifier declaration_specifiers   =>   declaration_specifiers"); $$ = node(pt_declaration_specifiers, $1, $2, $%); }
;

// node(pt_init_declarator_list, pt_init_declarator, restOfList)
init_declarator_list
: init_declarator                                       { PP(pt, "init_declarator   =>   init_declarator_list"); $$ = mkinitdeclaratorlist(0, $1, $%); }
| init_declarator_list ',' init_declarator              { PP(pt, "init_declarator_list ',' init_declarator   =>   init_declarator_list"); $$ = mkinitdeclaratorlist($1, $3, $%); }
;

init_declarator
: declarator                                            { PP(pt, "declarator   =>   init_declarator"); $$ = node(pt_init_declarator, $1, 0, $%); }
| declarator '=' initializer                            { PP(pt, "declarator '=' initializer   =>   init_declarator"); $$ = node(pt_init_declarator, $1, $3, $%); }
;

storage_class_specifier
: TYPEDEF                                               { PP(pt, "TYPEDEF"); $$ = mktype(pt_storage_class_specifier, T_TYPEDEF, $%); }
| EXTERN                                                { PP(pt, "EXTERN"); $$ = mktype(pt_storage_class_specifier, T_EXTERN, $%); }
| STATIC                                                { PP(pt, "STATIC"); $$ = mktype(pt_storage_class_specifier, T_STATIC, $%); }
| AUTO                                                  { PP(pt, "AUTO"); $$ = mktype(pt_storage_class_specifier, T_AUTO, $%); }
| REGISTER                                              { PP(pt, "REGISTER"); $$ = mktype(pt_storage_class_specifier, T_REGISTER, $%); }
;

type_specifier
: VOID                                                  { PP(pt, "VOID   =>   type_specifier"); $$ = mktype(pt_type_specifier, T_VOID, $%); }
| CHAR                                                  { PP(pt, "CHAR   =>   type_specifier"); $$ = mktype(pt_type_specifier, T_CHAR, $%); }
| SHORT                                                 { $$ = mktype(pt_type_specifier, T_SHORT, $%); }
| INT                                                   { PP(pt, "INT   =>   type_specifier"); $$ = mktype(pt_type_specifier, T_INT, $%); }
| LONG                                                  { $$ = mktype(pt_type_specifier, T_LONG, $%); }
| FLOAT                                                 { $$ = mktype(pt_type_specifier, T_FLOAT, $%); }
| DOUBLE                                                { PP(pt, "DOUBLE   =>   type_specifier"); $$ = mktype(pt_type_specifier, T_DOUBLE, $%); }
| SIGNED                                                { $$ = mktype(pt_type_specifier, T_SIGNED, $%); }
| UNSIGNED                                              { $$ = mktype(pt_type_specifier, T_UNSIGNED, $%); }
| BOOL                                                  { $$ = mktype(pt_type_specifier, T_BOOL, $%); }
| COMPLEX                                               { $$ = mktype(pt_type_specifier, T_COMPLEX, $%); }
| IMAGINARY                                             { $$ = mktype(pt_type_specifier, T_IMAGINARY, $%); }
| struct_or_union_specifier                             { nyi("@ %d", $%); }
| enum_specifier                                        { nyi("@ %d", $%); }
| TYPE_NAME                                             { PP(pt, "#%s   =>   type_specifier", $1->s.u.v); nyi("@ %d", $%); }
;

struct_or_union_specifier
: struct_or_union IDENTIFIER '{' struct_declaration_list '}'    { nyi("@ %d", $%); }
| struct_or_union '{' struct_declaration_list '}'               { nyi("@ %d", $%); }
| struct_or_union IDENTIFIER                                    { nyi("@ %d", $%); }
;

struct_or_union
: STRUCT                                                { PP(pt, "STRUCT   =>   struct_or_union"); $$ = mktype(T_STRUCT, 0, $%); }
| UNION                                                 { PP(pt, "UNION   =>   struct_or_union"); $$ = mktype(T_UNION, 0, $%); }
;

struct_declaration_list
: struct_declaration                                    { nyi("@ %d", $%); }
| struct_declaration_list struct_declaration            { nyi("@ %d", $%); }
;

struct_declaration
: specifier_qualifier_list struct_declarator_list ';'   { nyi("@ %d", $%); }
;

specifier_qualifier_list
: type_specifier specifier_qualifier_list               { nyi("@ %d", $%); }
| type_specifier                                        //{ nyi("@ %d", $%); }
| type_qualifier specifier_qualifier_list               { nyi("@ %d", $%); }
| type_qualifier                                        //{ nyi("@ %d", $%); }
;

struct_declarator_list
: struct_declarator                                     { nyi("@ %d", $%); }
| struct_declarator_list ',' struct_declarator          { nyi("@ %d", $%); }
;

struct_declarator
: declarator                                            { nyi("declarator   =>   struct_declarator @ %d", $%); }
| ':' constant_expression                               { nyi("':' constant_expression   =>   struct_declarator @ %d", $%); }
| declarator ':' constant_expression                    { nyi("declarator ':' constant_expression   =>   struct_declarator @ %d", $%); }
;

enum_specifier
: ENUM '{' enumerator_list '}'                          { nyi("@ %d", $%); }
| ENUM IDENTIFIER '{' enumerator_list '}'               { nyi("@ %d", $%); }
| ENUM '{' enumerator_list ',' '}'                      { nyi("@ %d", $%); }
| ENUM IDENTIFIER '{' enumerator_list ',' '}'           { nyi("@ %d", $%); }
| ENUM IDENTIFIER
;

enumerator_list
: enumerator                                            { nyi("@ %d", $%); }
| enumerator_list ',' enumerator                        { nyi("enumerator_list ',' enumerator   =>   enumerator_list @ %d", $%); }
;

enumerator
: IDENTIFIER                                            { nyi("IDENTIFIER    =>   enumerator @ %d", $%); }
| IDENTIFIER '=' constant_expression                    { nyi("IDENTIFIER '=' constant_expression    =>   enumerator @ %d", $%); }
;

type_qualifier
: CONST                                                 { PP(pt, "CONST   =>   type_qualifier"); $$ = mktype(pt_type_qualifier, T_CONST, $%); }
| RESTRICT                                              { PP(pt, "RESTRICT   =>   type_qualifier"); $$ = mktype(pt_type_qualifier, T_RESTRICT, $%); }
| VOLATILE                                              { PP(pt, "VOLATILE   =>   type_qualifier"); $$ = mktype(pt_type_qualifier, T_VOLATILE, $%); }
;

function_specifier
: INLINE                                                { PP(pt, "INLINE   =>   function_specifier"); $$ = mktype(T_INLINE, 0, $%); }
;

// node(pt_declarator, l=pointerOrNull, r=pt_direct_declarator)
declarator
: pointer direct_declarator                             { PP(pt, "pointer direct_declarator   =>   declarator"); $$ = node(pt_declarator, $1, $2, $%); }
| direct_declarator                                     { PP(pt, "direct_declarator   =>   declarator"); $$ = node(pt_declarator, 0, $1, $%); }
;

// node()
direct_declarator
: IDENTIFIER                                                                    { PP(pt, "#%s   =>   direct_declarator", $1->s.u.v); }
| '(' declarator ')'                                                            { nyi("@ %d", $%); }
| direct_declarator '[' type_qualifier_list assignment_expression ']'           { nyi("@ %d", $%); }
| direct_declarator '[' type_qualifier_list ']'                                 { nyi("@ %d", $%); }
| direct_declarator '[' assignment_expression ']'                               { nyi("@ %d", $%); }
| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'    { nyi("@ %d", $%); }
| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'    { nyi("@ %d", $%); }
| direct_declarator '[' type_qualifier_list '*' ']'                             { nyi("@ %d", $%); }
| direct_declarator '[' '*' ']'                                                 { nyi("@ %d", $%); }
| direct_declarator '[' ']'                                                     { $$ = nodepp(pt_array, $1, 0, $%, pt, "direct_declarator '[' ']'   =>   direct_declarator"); }
| direct_declarator '(' parameter_type_list ')'                                 { $$ = nodepp(func_def, $1, $3, $%, pt, "direct_declarator '(' parameter_type_list ')'   =>   direct_declarator"); }
| direct_declarator '(' identifier_list ')'                                     { nyi("direct_declarator '(' identifier_list ')'   =>   direct_declarator");  }
| direct_declarator '(' ')'                                                     { $$ = nodepp(func_def, $1, 0, $%, pt, "direct_declarator '(' ')'   =>   direct_declarator"); }
;

pointer
: '*'                                                   { PP(pt, "'*'   =>   pointer"); $$ = node(pt_pointer, mktype(T_PTR, 0, $%), 0, $%); }
| '*' type_qualifier_list                               { PP(pt, "'*' type_qualifier_list   =>   pointer"); $$ = node(pt_pointer, mktype(T_PTR, $2, $%), 0, $%); }
| '*' pointer                                           { PP(pt, "'*' pointer   =>   pointer"); $$ = node(pt_pointer, mktype(T_PTR, 0, $%), $2, $%); }
| '*' type_qualifier_list pointer                       { PP(pt, "'*' type_qualifier_list pointer   =>   pointer"); $$ = node(pt_pointer, mktype(T_PTR, $2, $%), $3, $%); }
;

type_qualifier_list
: type_qualifier                                        { PP(pt, "type_qualifier   =>   type_qualifier_list"); $$ = mktypequalifierlist(0, $1, $%); }
| type_qualifier_list type_qualifier                    { PP(pt, "type_qualifier_list type_qualifier   =>   type_qualifier_list"); $$ = mktypequalifierlist($1, $2, $%); }
;

// parameter_type_list and parameter_list are really the same list of parameters
parameter_type_list
: parameter_list                                        { PP(pt, "parameter_list   =>   parameter_type_list"); }
| parameter_list ',' ELLIPSIS                           { PP(pt, "parameter_list ',' ELLIPSIS   =>   parameter_type_list"); $$ = mkparametertypelist($1, mktype(T_ELLIPSIS, 0, $%), $%); }
;

parameter_list
: parameter_declaration                                 { PP(pt, "parameter_declaration   =>   parameter_list"); $$ = mkparametertypelist(0, $1, $%); }
| parameter_list ',' parameter_declaration              { PP(pt, "parameter_list ',' parameter_declaration   =>   parameter_list"); $$ = mkparametertypelist($1, $3, $%); }
;

parameter_declaration
: declaration_specifiers declarator                     { PP(pt, "declaration_specifiers declarator   =>   parameter_declaration"); $$ = node(pt_parameter_declaration, $1, $2, $%); }
| declaration_specifiers abstract_declarator            { PP(pt, "declaration_specifiers abstract_declarator   =>   parameter_declaration"); $$ = node(pt_parameter_declaration, $1, $2, $%); ; }
| declaration_specifiers                                { PP(pt, "declaration_specifiers   =>   parameter_declaration"); $$ = node(pt_parameter_declaration, $1, 0, $%); }
;

// node(pt_identifier_list, 0, restOfList) and ->s.u.v = identifier char *
identifier_list
: IDENTIFIER                                            { PP(pt, "#%s   =>   identifier_list", $1->s.u.v); $$ = mkidentifierlist(0, $1->s.u.v, $%); }
| identifier_list ',' IDENTIFIER                        { PP(pt, "identifier_list ',' #%s   =>   identifier_list", $1->s.u.v); $$ = mkidentifierlist($1, $1->s.u.v, $%); }
;

type_name
: specifier_qualifier_list                              { PP(pt, "specifier_qualifier_list   =>   type_name"); $$ = node(pt_type_name, $1, 0, $%); }
| specifier_qualifier_list abstract_declarator          { PP(pt, "specifier_qualifier_list abstract_declarator   =>   type_name"); $$ = node(pt_type_name, $1, $2, $%); }
;

abstract_declarator
: pointer                                               { $$ = node(pt_abstract_declarator, $1, 0, $%); }
| direct_abstract_declarator                            { $$ = node(pt_abstract_declarator, 0, $1, $%); }
| pointer direct_abstract_declarator                    { $$ = node(pt_abstract_declarator, $1, $2, $%); }
;

direct_abstract_declarator
: '(' abstract_declarator ')'                               { nyi("@ %d", $%); }
| '[' ']'                                                   { nyi("@ %d", $%); }
| '[' assignment_expression ']'                             { nyi("@ %d", $%); }
| direct_abstract_declarator '[' ']'                        { nyi("@ %d", $%); }
| direct_abstract_declarator '[' assignment_expression ']'  { nyi("@ %d", $%); }
| '[' '*' ']'                                               { nyi("@ %d", $%); }
| direct_abstract_declarator '[' '*' ']'                    { nyi("@ %d", $%); }
| '(' ')'                                                   { nyi("@ %d", $%); }
| '(' parameter_type_list ')'                               { nyi("@ %d", $%); }
| direct_abstract_declarator '(' ')'                        { nyi("@ %d", $%); }
| direct_abstract_declarator '(' parameter_type_list ')'    { nyi("@ %d", $%); }
;

initializer
: assignment_expression
| '{' initializer_list '}'                              { nyi("@ %d", $%); }
| '{' initializer_list ',' '}'                          { nyi("@ %d", $%); }
;

initializer_list
: initializer
| designation initializer                               { $$ = bindr($1, $2, $%); }
| initializer_list ',' initializer                      { nyi("@ %d", $%); }
| initializer_list ',' designation initializer          { nyi("@ %d", $%); }
;

designation
: designator_list '='                                   { $$ = node(OP_ASSIGN, $1, 0, $%); }
;

designator_list
: designator
| designator_list designator                            { nyi("@ %d", $%); }
;

designator
: '[' constant_expression ']'                           { $$ = node(OP_INDEX, 0, $2, $%); }
| '.' IDENTIFIER                                        { $$ = node(OP_ATTR, 0, $2, $%); }
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
: IDENTIFIER ':' statement                              { $$ = node(Label, $1, $3, $%); }
| CASE constant_expression ':' statement                { $$ = node(Case, $2, $4, $%); }
| DEFAULT ':' statement                                 { $$ = node(Default, $3, 0, $%); }
;

compound_statement
: '{' '}'                                               { PP(pt, "'{' '}'    =>   compound_statement"); $$ = 0; }
| '{' block_item_list '}'                               { PP(pt, "'{' block_item_list '}'    =>   compound_statement"); $$ = $2; }
;

block_item_list
: block_item                                            { PP(pt, "block_item   =>   block_item_list"); }
| block_item_list block_item                            { $$ = nodepp(Seq, $1, $2, $%, pt, "block_item_list block_item   =>   block_item_list"); }
;

block_item
: declaration                                           { PP(pt, "declaration   =>   block_item"); }
| statement                                             { PP(pt, "statement   =>   block_item"); }
;

expression_statement
: ';'
| expression ';'                                        { $$ = $1; }
;

selection_statement
: IF '(' expression ')' statement                       { $$ = node(If, $3, $5, $%); }
| IF '(' expression ')' statement ELSE statement        { $$ = mkifelse($3, $5, $7, $%); }
| SWITCH '(' expression ')' statement                   { nyi("SWITCH @ %s", $%); }
;

iteration_statement
: WHILE '(' expression ')' statement                                    { nyi("@ %d", $%); }
| DO statement WHILE '(' expression ')' ';'                             { nyi("@ %d", $%); }
| FOR '(' expression_statement expression_statement ')' statement       { nyi("@ %d", $%); }
| FOR '(' expression_statement
    expression_statement expression ')'
    statement                                                           { PP(pt, "FOR '(' expression_statement expression_statement expression ')' statement"); $$ = mkfor($3, $4, $5, $7, $%); }
| FOR '(' declaration expression_statement ')' statement                { nyi("@ %d", $%); }
| FOR '(' declaration expression_statement expression ')' statement     { nyi("@ %d", $%); }
;

jump_statement
: GOTO IDENTIFIER ';'                                   { $$ = node(Goto, $2, 0, $%); }
| CONTINUE ';'                                          { $$ = node(Continue, 0, 0, $%); }
| BREAK ';'                                             { $$ = node(Break, 0, 0, $%); }
| RETURN ';'                                            { $$ = node(Ret, 0, 0, $%); }
| RETURN expression ';'                                 { $$ = node(Ret, $2, 0, $%); }
;

translation_unit
: external_declaration
| translation_unit external_declaration
;

external_declaration
: function_definition
| declaration                                           { PP(pt, "declaration   =>   external_declaration"); c99_emit_declaration($1); }
;

function_definition
: declaration_specifiers declarator declaration_list compound_statement     { PP(pt, "declaration_specifiers declarator declaration_list compound_statement   =>   function_definition"); c99_emit_function_definition($1, $2, $3, $4); }
| declaration_specifiers declarator compound_statement                      { PP(pt, "declaration_specifiers declarator compound_statement   =>   function_definition"); c99_emit_function_definition($1, $2, 0, $3); }
;

declaration_list
: declaration
| declaration_list declaration                          { $$ = node(Seq, $1, $2, $%); }
;

%%


struct {
    char *s;
    int t;
} kwds[] = {
    { "void", VOID },           { "char", CHAR },           { "short", SHORT },         { "int", INT },
    { "long", LONG },           { "float", FLOAT },         { "double", DOUBLE },       { "signed", SIGNED },
    { "unsigned", UNSIGNED },   { "bool", BOOL },           { "complex", COMPLEX },     { "imaginary", IMAGINARY },

    { "if", IF },               { "else", ELSE },           { "for", FOR },             { "do", DO },
    { "while", WHILE },         { "switch", SWITCH },       { "case", CASE },           { "default", DEFAULT },
    { "goto", GOTO },           { "continue", CONTINUE },   { "return", RETURN },       { "break", BREAK },

    { "sizeof", SIZEOF },       { "typedef", TYPEDEF },     { "extern", EXTERN },       { "static", STATIC },
    { "auto", AUTO },           { "register", REGISTER },   { "struct", STRUCT },       { "union", UNION },
    { "const", CONST },         { "restrict", RESTRICT },   { "volatile", VOLATILE },   { "inline", INLINE },
    { 0, 0 }
};




int yylex() {
    int i, c, c2, c3, n;  char v[NString], *p;  double d, s;

    do {
        c = getc(inf);
        if (c == '#') {
            // commentary from the preprocessor starts with # followed by a line number and the file it's come from
            scanLineAndSrcFfn();
            while ((c = getc(inf)) != '\n') {;}  // don't include a line with # on the line count
        }
        else if (c == '/') {
            c2 = getc(inf);
            if (c2 == '/')
                while ((c = getc(inf)) != '\n') {;}
            else
                ungetc(c2, inf);
        }
        if (c == '\n') incLine();
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
            c = getc(inf);
        } while (isdigit(c));
        if (c == '.') {
            c = getc(inf);
            if (!isdigit(c)) die("invalid decimal");
            d = n;
            s = 1.0;
            do {
                s /= 10;
                d += s * (c-'0');
                c = getc(inf);
            } while (isdigit(c));
            ungetc(c, inf);
            yylval.n = node(LIT_DEC, 0, 0, __LINE__);
            yylval.n->s.u.d = d;
            PP(lex, "%f ", d);
            return CONSTANT;
        }
        else {
            ungetc(c, inf);
            yylval.n = node(LIT_INT, 0, 0, __LINE__);
            yylval.n->s.u.n = n;
            PP(lex, "%d ", n);
            return CONSTANT;
        }
    }

    if (isalpha(c) || c == '_') {
        p = v;  n = 0;
        do {
            if (p == &v[NString-1]) die("ident too long");
            *p++ = c;  n++;
            c = getc(inf);
        } while (isalnum(c) || c == '_');
        *p = 0;  n++;
        ungetc(c, inf);
        for (i=0; kwds[i].s; i++)
            if (strcmp(v, kwds[i].s) == 0)
                return kwds[i].t;
        yylval.n = node(IDENT, 0, 0, __LINE__);
        void *buf = allocInArena(&strings, n, 1);
        yylval.n->s.u.v = buf;
        strcpy(yylval.n->s.u.v, v);
        PP(lex, "%s ", p);
        return IDENTIFIER;
    }

    if (c == '"') {
        i = 0;
        n = 32;
        p = allocInArena(&strings, n, 1);
        strcpy(p, "{ b \"");
        for (i=5;; i++) {
            c = getc(inf);
            if (c == EOF) die("unclosed string literal");
            if (i+8 >= n) {
                char* new = reallocInArena(&strings, p, n*2, 1);
                if (!new) die("out of memory");
                if (new != p) p = memcpy(new, p, n);
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
                        c2 = getc(inf);
                        if (c2 == '"') {
                            eos = 0;
                        }
                        else if (c == '#') die("unexpected # encountered");
                    } while (c2 == ' ');
                    if (eos == 1) {
                        p[i] = c;
                        ungetc(c2, inf);
                        break;
                    }
                    else
                        i--;
                }
            }
        }
        strcpy(&p[i], "\", b 0 }");
        if (oglo == NGlo) die("too many globals");
        globals[oglo] = p;
        yylval.n = node(LIT_STR, 0, 0, __LINE__);
        yylval.n->s.u.n = (oglo++) + SEED_START;
        PP(lex, "\"%s\" ", p);
        return STRING_LITERAL;
    }

    c2 = getc(inf);
#define DI(a, b) (a + b*256)
    switch (DI(c,c2)) {
        case DI('!','='): return NE_OP;
        case DI('=','='): return EQ_OP;
        case DI('<','='): return LE_OP;
        case DI('>','='): return GE_OP;
        case DI('+','+'): return INC_OP;
        case DI('-','-'): return DEC_OP;
        case DI('&','&'): return AND_OP;
        case DI('|','|'): return OR_OP;
        case DI('*','='): return MUL_ASSIGN;
        case DI('/','='): return DIV_ASSIGN;
        case DI('%','='): return MOD_ASSIGN;
        case DI('+','='): return ADD_ASSIGN;
        case DI('-','='): return SUB_ASSIGN;
        case DI('^','='): return XOR_ASSIGN;
        case DI('|','='): return OR_ASSIGN;
        case DI('.','.'): {
            c3 = getc(inf);
            if (c3 == '.') return ELLIPSIS;
            ungetc(c3, inf);
        }
        case DI('<','<'): {
            c3 = getc(inf);
            if (c3 == '=') return LEFT_ASSIGN;
            ungetc(c3, inf);
        }
        case DI('>','>'): {
            c3 = getc(inf);
            if (c3 == '=') return RIGHT_ASSIGN;
            ungetc(c3, inf);
        }
    }
#undef DI
    ungetc(c2, inf);
    return c;
}



int main(int argc, char*argv[]) {
    if (argc == 2) {
        const char *ffn = argv[1];
        FILE *file = fopen(ffn, "r");
        if (!file) {
            perror("Error opening file");
            return EXIT_FAILURE;
        }
        inf = file;
        strcpy(srcFfn, ffn);
    }
    else {
        inf = stdin;
        strcpy(srcFfn, "stdin");
    }
    g_logging_level = parse | emit | error | pt | lex;
    of = stdout;
    initArena(&strings, 4096);
    initArena(&idents, 4096);
    initArena(&nodes, 4096);
    int ret = yyparse();
    if (ret) die("parse error (%d)", ret);
    for (int o=0; o<oglo; o++)
        putq("data " GLOBAL "%d = %s\n", o + SEED_START, globals[o]);
    freeChunks(strings.first_chunk);
    freeChunks(idents.first_chunk);
    freeChunks(nodes.first_chunk);

    return EXIT_SUCCESS;
}
