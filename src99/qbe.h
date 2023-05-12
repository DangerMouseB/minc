#ifndef MINC_QBE_H
#define MINC_QBE_H

#include "minc.h"

int emitstmt(Node *n, int b);
Symb emitexpr(Node *n);
void i8_to_i16(Symb *s);        // INTEGER CONVERSIONS
void i8_to_i32(Symb *s);
void i8_to_i64(Symb *s);
void u8_to_u64(Symb *s);
void i16_to_i32(Symb *s);
void i16_to_i64(Symb *s);
void u16_to_u64(Symb *s);
void i32_to_i64(Symb *s);
void u32_to_u64(Symb *s);
void i8_to_f64(Symb *s);        // FLOAT CONVERSIONS
void i16_to_f64(Symb *s);
void i32_to_f64(Symb *s);
void i64_to_f64(Symb *s);


// we use w (32 bit) temps except for B_U64 and B_I64 which uses l (64 bit) temps

char vtyp(enum btyp btyp) {
    switch (KIND(btyp)) {
        case B_I8:
        case B_U8:
        case B_I16:
        case B_U16:
        case B_I32:
        case B_U32: return 'w';
        case B_I64:
        case B_U64:
        case B_PTR:
        case B_VOID_STAR:
        case B_FN: return 'l';
        case B_F32: return 's';
        case B_F64: return 'd';
    }
    die("unhandled type %s @ %d", btyptopp[KIND(btyp)], __LINE__);
    return 0;
}

char storetyp(enum btyp btyp) {
    switch (KIND(btyp)) {
        case B_I8:
        case B_U8: return 'b';
        case B_I16:
        case B_U16: return 'h';
        case B_I32:
        case B_U32: return 'w';
        case B_I64:
        case B_U64:
        case B_PTR:
        case B_VOID_STAR:
        case B_FN: return 'l';
        case B_F32: return 's';
        case B_F64: return 'd';
    }
    die("unhandled type %s @ %d", btyptopp[KIND(btyp)], __LINE__);
    return 0;
}

char * fntyp(enum btyp btyp) {
    switch (KIND(btyp)) {
        case B_VOID: return "";
        case B_I8: return "sb";
        case B_U8: return "ub";
        case B_I16: return "sh";
        case B_U16: return "uh";
        case B_I32:
        case B_U32: return "w";
        case B_I64:
        case B_U64:
        case B_PTR:
        case B_VOID_STAR:
        case B_FN: return "l";
        case B_F32: return "s";
        case B_F64: return "d";
    }
    die("unhandled type %s @ %d", btyptopp[KIND(btyp)], __LINE__);
    return 0;
}

Symb lval(Node *n) {
    Symb s;
    switch (n->tok) {
        default:
            die("invalid lvalue");
        case IDENT:
            if (!symget(n->s.u.v)) {
                PP(error, "%s is not defined\n", n->s.u.v);
                die("undefined variable");
            }
            s = *symget(n->s.u.v);
            break;
        case OP_DEREF:
            s = emitexpr(n->l);
            if (KIND(s.btyp) != B_PTR) die("dereference of a non-pointer");
            s.btyp = DREF(s.btyp);
            break;
    }
    return s;
}

void emitlocaldecl(Node *decl) {
    int s;
    s = SIZE(decl->s.btyp );
    putq(INDENT PVAR "%s =l alloc%d %d\n", decl->l->s.u.v, s, s);
    if (decl->r) emitexpr(node(OP_ASSIGN, decl->l, decl->r, __LINE__));
}

void emitglobals() {
    putq("\n# GLOBAL VARIABLES\n");
    for (int oglo = 0; oglo < next_oglo; oglo++)
        if (globals[oglo].t == Glo) putq("data " GLOBAL "%d = { %c 0 }\n", oglo, vtyp(globals[oglo].btyp));
    putq("\n# STRING CONSTANTS\n");
    for (int oglo = 0; oglo < next_oglo; oglo++)
        if ((globals[oglo].t == Con) && (globals[oglo].btyp == B_CHARS)) putq("data " GLOBAL "%d = { b \"%s\", b 0 }\n", oglo, globals[oglo].u.v);
}

void emitsymb(Symb s) {
    switch (s.t) {
        case Tmp:
            putq(TEMP "%d", s.u.n);
            break;
        case Var:
            putq(PVAR "%s", s.u.v);
            break;
        case Glo:
            putq(GLOBAL "%d", s.u.n);
            break;
        case Con:
            putq("%d", s.u.n);
            break;
    }
}

void emitload(Symb d, Symb s) {
    putq(INDENT);
    emitsymb(d);
    putq(" =%c load%s ", vtyp(d.btyp), fntyp(d.btyp));
    emitsymb(s);
    putq("\n");
}

void emitcall(Node *n, Symb *sr) {
    Node *a;  int iEllipsis, iArg;  Symb *s;
    char *name = n->l->s.u.v;
    if (!(s=symget(name))) die("undeclared function %s", name);
    if (s->t != Glo) die("programmer error @ %d", __LINE__);
    if (KIND(s->btyp) != B_FN) die("programmer error @ %d", __LINE__);
    iEllipsis = i_ellipsis[s->u.n];
    sr->btyp = DREF(s->btyp);               // functions are stored shifted with type B_FN
    for (a=n->r; a; a=a->r)
        a->s = emitexpr(a->l);
    putq(INDENT);
    if (sr->btyp == B_VOID) {
        putq("call $%s(", name);
    }
    else {
        emitsymb(*sr);
        putq(" =%s call $%s(", fntyp(sr->btyp), name);
    }
    a = n->r; iArg = 1;
    while (a) {
        if (iArg == iEllipsis) putq("..., ");
        putq("%s ", fntyp(a->s.btyp));
        emitsymb(a->s);
        a = a->r;
        if (a) putq(", ");
        iArg++;
    }
    putq(")\n");
    // OPEN: extend sub word return types?
}

void emitboolop(Node *n, int tn, char *tlabel, int fn, char*flabel) {
    Symb s;  int l;
    switch (n->tok) {
        default:
            s = emitexpr(n); /* OPEN: insert comparison to 0 with proper type */
            putq(INDENT "jnz ");
            emitsymb(s);
            putq(", " LABEL "%s.%d, " LABEL "%s.%d\n", tlabel, tn, flabel, fn);
            break;
        case OP_OR:
            l = reserve_lbl(1);
            emitboolop(n->l, tn, tlabel, l, "or.false");
            putq(LABEL "or.false.%d\n", l);
            emitboolop(n->r, tn, tlabel, fn, flabel);
            break;
        case OP_AND:
            l = reserve_lbl(1);
            emitboolop(n->l, l, "and.true", fn, flabel);
            putq(LABEL "and.true.%d\n", l);
            emitboolop(n->r, tn, tlabel, fn, flabel);
            break;
    }
}

void emitbreak(Node *n, int b) {
    if (b < 0) die("break not in loop");
    putq(INDENT "jmp " LABEL "false.%d\n", b);
}

void emitret(Node *n) {
    Symb x;
    if (n->l) {
        x = emitexpr(n->l);
        putq(INDENT "ret ");
        emitsymb(x);
    } else
        putq(INDENT "ret");
    putq("\n");
}

void emitif(Node *n, int b) {
    int l;
    putq(LABEL "if.%d\n", reserve_lbl(1));
    l = reserve_lbl(2);
    emitboolop(n->l, l, "true", l+1, "false");
    putq(LABEL "true.%d\n", l);
    emitstmt(n->r, b);
    putq(LABEL "false.%d\n", l+1);
}

int emitifelse(Node *n, int b) {
    int l, r;  Node *e;
    putq(LABEL "if.else.%d\n", reserve_lbl(1));
    l = reserve_lbl(3);
    emitboolop(n->l, l, "true", l+1, "false");
    putq(LABEL "true.%d\n", l);
    e = n->r;
    if (!(r=emitstmt(e->l, b)))
        putq(INDENT "jmp " LABEL "if.end.%d\n", l+2);
    putq(LABEL "false.%d\n", l+1);
    if (!(r &= emitstmt(e->r, b)))
        putq(LABEL "if.end.%d\n", l+2);
    return e->r && r;
}

void emitwhile(Node *n) {
    int l;
    l = reserve_lbl(3);
    putq(LABEL "while.cond.%d\n", l);
    emitboolop(n->l, l+1, "while.body", l+2, "while.end");
    putq(LABEL "while.body.%d\n", l+1);
    if (!emitstmt(n->r, l+2))
        putq(INDENT "jmp " LABEL "while.cond.%d\n", l);
    putq(LABEL "while.end.%d\n", l+2);
}

void emitfunc(enum btyp t, char *fnname, NameType *params, Node *stmts) {
    NameType *p;  int i, m;
    PP(emit, "emitFunc: %s", fnname);

    symadd(fnname, reserve_oglo(), FUNC(t));
    if (t == B_VOID)
        putq("export function $%s(", fnname);
    else
        putq("export function %s $%s(", fntyp(t), fnname);
    if ((p=params))
        do {
            symadd(p->name, 0, p->btyp);
            putq("%s ", fntyp(p->btyp));
            putq(TEMP "%d", reserve_tmp());
            p = p->next;
            if (p) putq(", ");
        } while (p);
    putq(") {\n");
    putq(LABEL "start.%d\n", reserve_lbl(1));
    for (i=TMP_START, p=params; p; i++, p=p->next) {
        m = SIZE(p->btyp);
        putq(INDENT PVAR "%s =l alloc%d %d\n", p->name, m, m);
        putq(INDENT "store%c " TEMP "%d", storetyp(p->btyp), i);
        putq(", " PVAR "%s\n", p->name);
    }
    putq(LABEL "body.%d\n", reserve_lbl(1));
    if (!emitstmt(stmts, -1)) putq(INDENT "ret\n");    // for the case of a void function with no return statement
    putq("}\n\n");
}

int emitstmt(Node *n, int b) {
    if (!n) return 0;
    PP(emit, "%s", toktopp[n->tok]);

    switch (n->tok) {
        case DeclVars:
            emitlocaldecl(n->l);
            emitstmt(n->r, b);
            return 0;
        case Ret:
            emitret(n);
            return 1;
        case Break:
            emitbreak(n, b);
            return 1;
        case Seq:
            return emitstmt(n->l, b) || emitstmt(n->r, b);
        case If:
            emitif(n, b);
            return 0;
        case IfElse:
            return emitifelse(n, b);
        case While:
            emitwhile(n);
            return 0;
        case Label:
        case Else:
        case Select:
        case Case:
        case Continue:
        case Goto:
        case Do:
            nyi("%d:\"%s\" @ %d", n->tok, toktopp[n->tok], n->lineno);
        default:
            if ((OP_EXPR_START <= n->tok) && (n->tok <= OP_EXPR_END))
                emitexpr(n);
            else
                die("invalid statement %d:\"%s\" @ %d", n->tok, toktopp[n->tok], n->lineno);
            return 0;
    }
}


void i8_to_i16(Symb *s) {
    putq(INDENT TEMP "%d =w extsb ", tmp_seed);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->btyp = B_I16;
    s->u.n = reserve_tmp();
}

void i8_to_i32(Symb *s) {
    putq(INDENT TEMP "%d =w extsb ", tmp_seed);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->btyp = B_I32;
    s->u.n = reserve_tmp();
}

void i8_to_i64(Symb *s) {
    putq(INDENT TEMP "%d =l extsb ", tmp_seed);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->btyp = B_I64;
    s->u.n = reserve_tmp();
}

void u8_to_u64(Symb *s) {
    putq(INDENT TEMP "%d =l extub ", tmp_seed);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->btyp = B_U64;
    s->u.n = reserve_tmp();
}

void i16_to_i32(Symb *s) {
    putq(INDENT TEMP "%d =w extsh ", tmp_seed);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->btyp = B_I32;
    s->u.n = reserve_tmp();
}

void i16_to_i64(Symb *s) {
    putq(INDENT TEMP "%d =l extsh ", tmp_seed);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->btyp = B_I64;
    s->u.n = reserve_tmp();
}

void u16_to_u64(Symb *s) {
    putq(INDENT TEMP "%d =l extuh ", tmp_seed);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->btyp = B_U64;
    s->u.n = reserve_tmp();
}

void i32_to_i64(Symb *s) {
    putq(INDENT TEMP "%d =l extsw ", tmp_seed);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->btyp = B_I64;
    s->u.n = reserve_tmp();
}

void u32_to_u64(Symb *s) {
    putq(INDENT TEMP "%d =l extuw ", tmp_seed);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->btyp = B_U64;
    s->u.n = reserve_tmp();
}

void i8_to_f64(Symb *s) {
    i8_to_i64(s);
    putq(INDENT TEMP "%d =d swtof ", tmp_seed);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->btyp = B_F64;
    s->u.n = reserve_tmp();
}

void i16_to_f64(Symb *s) {
    i16_to_i64(s);
    putq(INDENT TEMP "%d =d swtof ", tmp_seed);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->btyp = B_F64;
    s->u.n = reserve_tmp();
}

void i32_to_f64(Symb *s) {
    putq(INDENT TEMP "%d =d swtof ", tmp_seed);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->btyp = B_F64;
    s->u.n = reserve_tmp();
}

void i64_to_f64(Symb *s) {
    putq(INDENT TEMP "%d =d sltof ", tmp_seed);
    emitsymb(*s);
    putq("\n");
    s->t = Tmp;
    s->btyp = B_F64;
    s->u.n = reserve_tmp();
}

#endif //MINC_MINC_H