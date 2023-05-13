#ifndef MINC_QBE_H
#define MINC_QBE_H

#include "minc.h"


// helpers to emit QBE IR from an AST and a symbol table
// needs knowledge of Node, Symb and btyp and the symbol table

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


int emitstmt(Node *n, int b);
Symb emitexpr(Node *n);
enum btyp prom(enum tok tok, Symb *l, Symb *r);

Symb i8_to_i16(Symb s);        // INTEGER CONVERSIONS
Symb i8_to_i32(Symb s);
Symb i8_to_i64(Symb s);
Symb u8_to_u64(Symb s);
Symb i16_to_i32(Symb s);
Symb i16_to_i64(Symb s);
Symb u16_to_u64(Symb s);
Symb i32_to_i64(Symb s);
Symb u32_to_u64(Symb s);
Symb i8_to_f64(Symb s);        // FLOAT CONVERSIONS
Symb i16_to_f64(Symb s);
Symb i32_to_f64(Symb s);
Symb i64_to_f64(Symb s);


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

Symb emitexpr(Node *n) {
    Symb sr, s0, s1, st;  enum tok o;  int l;  char ty[2];

    sr.t = Tmp;
    sr.u.n = reserve_tmp();
    sr.btyp = B_NAT;

    switch (n->tok) {

        case OP_OR:
        case OP_AND:
            l = reserve_lbl(3);
            emitboolop(n, l, "bool.true", l+1, "bool.false");
            putq(LABEL "bool.true.%d\n", l);
            putq(INDENT "jmp " LABEL "bool.end.%d\n", l+2);
            putq(LABEL "bool.false.%d\n", l+1);
            putq(INDENT "jmp " LABEL "bool.end.%d\n", l+2);
            putq(LABEL "bool.end.%d\n", l+2);
            putq(INDENT);
            sr.btyp = B_I32;
            emitsymb(sr);
            putq(" =w phi " LABEL "bool.true.%d 1, " LABEL "bool.false.%d 0\n", l, l+1);
            break;

        case IDENT:
            s0 = lval(n);
            sr.btyp = s0.btyp;
            emitload(sr, s0);
            break;

        case LIT_DEC:
            sr.t = Con;
            sr.u.d = n->s.u.d;
            sr.btyp = B_F64;
            break;

        case LIT_INT:
            // OPEN: might need literal unsigned long or maybe just L for long
            sr.t = Con;
            sr.u.n = n->s.u.n;
            sr.btyp = n->s.btyp;
            sr.btyp = B_I32;
            break;

        case LIT_CHAR:
            sr.t = Con;
            sr.u.n = n->s.u.n;
            sr.btyp = B_CHAR_DEFAULT;
            break;

        case LIT_STR:
            sr.t = Glo;
            sr.u.n = n->s.u.n;
            sr.btyp = IDIR(B_U8);
            break;

        case OP_CALL:
            emitcall(n, &sr);
            break;

        case OP_DEREF:
            s0 = emitexpr(n->l);
            if (KIND(s0.btyp) != B_PTR) die("dereference of a non-pointer");
            sr.btyp = DREF(s0.btyp);
            emitload(sr, s0);
            break;

        case OP_ADDR:
            sr = lval(n->l);
            sr.btyp = IDIR(sr.btyp);
            break;

        case OP_NEG:
            if (!z) {
                z = node(LIT_INT, 0, 0, 0);
                z->s.t = Con;
                z->s.u.n = 0;
            }
            z->s.btyp = B_I8;       // always initialise as can be promoted (which will change the btyp)
            n->r = n->l;
            n->l = z;
            n->tok = OP_SUB;
            sr = emitexpr(n);
            break;

        case OP_BINV:
            nyi("OP_BINV");

        case OP_NOT:
            nyi("OP_NOT");

        case OP_ASSIGN:
            // s1 = s0  => store s0, s1
            // where s1 is qbe type m, i.e. memory, which could be a C variable, struct, array or pointer)
            // if the storage size of s1 is larger than the storage size of s0 then we need to either zero extend or
            // sign extend s0.
            // we only ever store the correct number of bytes from s0 into s1
            s0 = emitexpr(n->r);
            if (s0.btyp == B_NAT) {
                s0 = emitexpr(n->r);
                die("s0.btyp == B_NAT");
            }
            s1 = lval(n->l);        // always memory
            sr = s0;

            // OPEN: think through how to make this clearer and simpler
            if (s1.btyp == B_I16 && s0.btyp == B_I8)  s0 = i8_to_i16(s0);
            if (s1.btyp == B_I32 && s0.btyp == B_I8)  s0 = i8_to_i32(s0);
            if (s1.btyp == B_I64 && s0.btyp == B_I8)  s0 = i8_to_i64(s0);
            if (s1.btyp == B_I32 && s0.btyp == B_I16) s0 = i16_to_i32(s0);
            if (s1.btyp == B_I64 && s0.btyp == B_I16) s0 = i16_to_i64(s0);
            if (s1.btyp == B_I64 && s0.btyp == B_I32) s0 = i32_to_i64(s0);

            if (s1.btyp == B_I32 && s0.btyp == B_I64 && n->r->tok == LIT_INT) s0.btyp = B_I32;   // HACK - need to figure how to cast LIT_INT properly
            if (s1.btyp == B_I32 && s0.btyp == B_I64 && n->r->tok == OP_SUB) s0.btyp = B_I32;   // HACK - need to figure how to cast LIT_INT properly

            if (s1.btyp == B_F64 && s0.btyp == B_I8) s0 = i8_to_f64(s0);
            if (s1.btyp == B_F64 && s0.btyp == B_I16) s0 = i16_to_f64(s0);
            if (s1.btyp == B_F64 && s0.btyp == B_I32) s0 = i32_to_f64(s0);
            if (s1.btyp == B_F64 && s0.btyp == B_I64) s0 = i64_to_f64(s0);

            if (
                    (KIND(s1.btyp) == B_PTR && s0.btyp == IDIR(B_VOID)) ||
                    ((s1.btyp == IDIR(B_VOID) && KIND(s0.btyp) == B_PTR))
                    ) {}
            else {
                if (s1.btyp != s0.btyp) {
                    s0 = emitexpr(n->r);
                    die("invalid assignment");
                }
            }
            // END OPEN:

            putq(INDENT "store%c ", storetyp(s1.btyp));
            goto emit_s0_s1;

        case OP_INC:
        case OP_DEC:
            o = n->tok == OP_INC ? OP_ADD : OP_SUB;    // e.g. x += 1  => x = x + 1
            st = lval(n->l);
            s0.t = Tmp;
            s0.u.n = reserve_tmp();
            s0.btyp = st.btyp;
            emitload(s0, st);
            s1.t = Con;
            s1.u.n = 1;
            s1.btyp = st.btyp;
            goto binop;

        default:
            // handle the binary ops
            if ((OP_BIN_START <= n->tok) && (n->tok <= OP_BIN_END)) {
                s0 = emitexpr(n->l);
                s1 = emitexpr(n->r);
                o = n->tok;
            }
            else
                die("%s is not an expression", toktopp[n->tok]);

        binop:
            // t = op s0 s1
            sr.btyp = prom(o, &s0, &s1);
            if (strchr(neltl, n->tok)) {
                sprintf(ty, "%c", vtyp(sr.btyp));
                sr.btyp = B_I32;            // OPEN: should be a B_BOOL
            } else
                strcpy(ty, "");
            putq(INDENT);
            emitsymb(sr);
            putq(" =%c", vtyp(sr.btyp));
            putq(" %s%s ", otoa[o], ty);
        emit_s0_s1:
            emitsymb(s0);
            putq(", ");
            emitsymb(s1);
            putq("\n");
            break;
    }
    if (n->tok == OP_SUB  &&  KIND(s0.btyp) == B_PTR  &&  KIND(s1.btyp) == B_PTR) {
        putq(INDENT TEMP "%d =l div ", tmp_seed);
        emitsymb(sr);
        putq(", %d\n", SIZE(DREF(s0.btyp)));
        sr.u.n = reserve_tmp();
    }
    if (n->tok == OP_INC  ||  n->tok == OP_DEC) {
        putq(INDENT "store%c ", storetyp(st.btyp));
        emitsymb(sr);
        putq(", ");
        emitsymb(st);
        putq("\n");
        sr = s0;
    }
    return sr;
}


Symb i8_to_i16(Symb s) {
    putq(INDENT TEMP "%d =w extsb ", tmp_seed);
    emitsymb(s);
    putq("\n");
    s.t = Tmp;
    s.btyp = B_I16;
    s.u.n = reserve_tmp();
    return s;
}

Symb i8_to_i32(Symb s) {
    putq(INDENT TEMP "%d =w extsb ", tmp_seed);
    emitsymb(s);
    putq("\n");
    s.t = Tmp;
    s.btyp = B_I32;
    s.u.n = reserve_tmp();
    return s;
}

Symb i8_to_i64(Symb s) {
    putq(INDENT TEMP "%d =l extsb ", tmp_seed);
    emitsymb(s);
    putq("\n");
    s.t = Tmp;
    s.btyp = B_I64;
    s.u.n = reserve_tmp();
    return s;
}

Symb u8_to_u64(Symb s) {
    putq(INDENT TEMP "%d =l extub ", tmp_seed);
    emitsymb(s);
    putq("\n");
    s.t = Tmp;
    s.btyp = B_U64;
    s.u.n = reserve_tmp();
    return s;
}

Symb i16_to_i32(Symb s) {
    putq(INDENT TEMP "%d =w extsh ", tmp_seed);
    emitsymb(s);
    putq("\n");
    s.t = Tmp;
    s.btyp = B_I32;
    s.u.n = reserve_tmp();
    return s;
}

Symb i16_to_i64(Symb s) {
    putq(INDENT TEMP "%d =l extsh ", tmp_seed);
    emitsymb(s);
    putq("\n");
    s.t = Tmp;
    s.btyp = B_I64;
    s.u.n = reserve_tmp();
    return s;
}

Symb u16_to_u64(Symb s) {
    putq(INDENT TEMP "%d =l extuh ", tmp_seed);
    emitsymb(s);
    putq("\n");
    s.t = Tmp;
    s.btyp = B_U64;
    s.u.n = reserve_tmp();
    return s;
}

Symb i32_to_i64(Symb s) {
    putq(INDENT TEMP "%d =l extsw ", tmp_seed);
    emitsymb(s);
    putq("\n");
    s.t = Tmp;
    s.btyp = B_I64;
    s.u.n = reserve_tmp();
    return s;
}

Symb u32_to_u64(Symb s) {
    putq(INDENT TEMP "%d =l extuw ", tmp_seed);
    emitsymb(s);
    putq("\n");
    s.t = Tmp;
    s.btyp = B_U64;
    s.u.n = reserve_tmp();
    return s;
}

Symb i8_to_f64(Symb s) {
    i8_to_i64(s);
    putq(INDENT TEMP "%d =d swtof ", tmp_seed);
    emitsymb(s);
    putq("\n");
    s.t = Tmp;
    s.btyp = B_F64;
    s.u.n = reserve_tmp();
    return s;
}

Symb i16_to_f64(Symb s) {
    i16_to_i64(s);
    putq(INDENT TEMP "%d =d swtof ", tmp_seed);
    emitsymb(s);
    putq("\n");
    s.t = Tmp;
    s.btyp = B_F64;
    s.u.n = reserve_tmp();
    return s;
}

Symb i32_to_f64(Symb s) {
    putq(INDENT TEMP "%d =d swtof ", tmp_seed);
    emitsymb(s);
    putq("\n");
    s.t = Tmp;
    s.btyp = B_F64;
    s.u.n = reserve_tmp();
    return s;
}

Symb i64_to_f64(Symb s) {
    putq(INDENT TEMP "%d =d sltof ", tmp_seed);
    emitsymb(s);
    putq("\n");
    s.t = Tmp;
    s.btyp = B_F64;
    s.u.n = reserve_tmp();
    return s;
}

#endif //MINC_MINC_H