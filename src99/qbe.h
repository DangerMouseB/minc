#ifndef MINC_QBE_H
#define MINC_QBE_H "qbe.h"

#include "minc.h"


// code gen constants - PVAR is the pointer to the memory that backs a C variable
#define GLOBAL  "$"
#define QEXTERN "$"
#define STRING  "$.s"
#define TEMP    "%%."
#define PVAR    "%%_"
#define LABEL   "@"
#define QINDENT "    "



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


struct Promoted{
    struct Symb s0;
    struct Symb s1;
    enum btyp btyp;
};

Node * node(int tok, Node *l, Node *r, int lineno);

int emitstmt(Node *n, int b);
Symb emitexpr(Node *n);


void emitsymb(Symb s) {
    switch (s.styp) {
        case Con:
            putq("%d", s.u.n);
            break;
        case Str:
            putq(STRING "%d", s.i);
            break;
        case Tmp:
            putq(TEMP "%d", s.u.n);
            break;
        case Var:
            putq(PVAR "%s", s.u.v);
            break;
        case Glo:
            putq(GLOBAL "%s", s.u.v);
            break;
        case Ext:
            putq("extern " QEXTERN "%s", s.u.v);
            break;
        default:
            bug("emitsymb");
    }
}

int emit_sb_to_w(Symb s) {
    putq(QINDENT TEMP "%d =w extsb ", tmp_seed);
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}

int emit_sb_to_l(Symb s) {
    putq(QINDENT TEMP "%d =l extsb ", tmp_seed);
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}

int emit_ub_to_w(Symb s) {
    putq(QINDENT TEMP "%d =w extub ", tmp_seed);
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}

int emit_ub_to_l(Symb s) {
    putq(QINDENT TEMP "%d =l extub ", tmp_seed);
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}

int emit_sh_to_w(Symb s) {
    putq(QINDENT TEMP "%d =w extsh ", tmp_seed);
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}

int emit_sh_to_l(Symb s) {
    putq(QINDENT TEMP "%d =l extsh ", tmp_seed);
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}

int emit_uh_to_w(Symb s) {
    putq(QINDENT TEMP "%d =w extuh ", tmp_seed);
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}

int emit_uh_to_l(Symb s) {
    putq(QINDENT TEMP "%d =l extuh ", tmp_seed);
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}

int emit_sw_to_l(Symb s) {
    putq(QINDENT TEMP "%d =l extsw ", tmp_seed);
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}

int emit_uw_to_l(Symb s) {
    putq(QINDENT TEMP "%d =l extuw ", tmp_seed);
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}

int emit_sw_to_d(Symb s) {
    putq(QINDENT TEMP "%d =d swtof ", tmp_seed);
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}

int emit_uw_to_d(Symb s) {
    putq(QINDENT TEMP "%d =d swtof ", tmp_seed);
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}

int emit_sl_to_d(Symb s) {
    putq(QINDENT TEMP "%d =d sltof ", tmp_seed);
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}

int emit_ul_to_d(Symb s) {
    putq(QINDENT TEMP "%d =d ultof ", tmp_seed);
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}

int emit_int_to_WL(enum btyp btyp, Symb s, char t) {
    switch (btyp) {
        case B_I8:
            putq(QINDENT TEMP "%d =%c extsb ", tmp_seed, t);
            break;
        case B_U8:
            putq(QINDENT TEMP "%d =%c extub ", tmp_seed, t);
            break;
        case B_I16:
            putq(QINDENT TEMP "%d =%c extsh ", tmp_seed, t);
            break;
        case B_U16:
            putq(QINDENT TEMP "%d =%c extuh ", tmp_seed, t);
            break;
        case B_I32:
            putq(QINDENT TEMP "%d =%c extsw ", tmp_seed, t);
            break;
        case B_U32:
            putq(QINDENT TEMP "%d =%c extuw ", tmp_seed, t);
            break;
        default:
            die("illegal extension");
    }
    emitsymb(s);
    putq("\n");
    return reserve_tmp();
}


// we use w (32 bit) temps except for B_U64 and B_I64 which uses l (64 bit) temps

char regtyp(enum btyp btyp) {
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
        case B_FN: return 'l';
        case B_F32: return 's';
        case B_F64: return 'd';
    }
    die("unhandled type %s @ %d", btyptopp[KIND(btyp)], __LINE__);
    return 0;
}

char * fntyp(enum btyp btyp) {
    switch (btyp & 0xff) {
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
        case B_FN: return "l";
        case B_F32: return "s";
        case B_F64: return "d";
    }
    die("unhandled type %s @ %d", btyptopp[KIND(btyp)], __LINE__);
    return 0;
}

Symb lval(Node *n) {
    Symb s, *_s;
    switch (n->tok) {
        default:
            die("invalid lvalue");
        case IDENT:
            _s = symget(n->s.u.v);
            if (!_s) {
                PP(error, "%s is not defined\n", n->s.u.v);
                die("undefined variable");
            }
            s = *_s;
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
    int sz = SIZE(decl->s.btyp);
    putq(QINDENT PVAR "%s =l alloc%d %d\n", decl->l->s.u.v, sz, sz);
    if (decl->r) emitexpr(node(OP_ASSIGN, decl->l, decl->r, __LINE__));
}

Symb emitload(Symb tmp, Symb m) {    // tmp is temp, m is memory
    int isFn;
    isFn = (tmp.btyp == m.btyp) && fitsWithin(tmp.btyp, B_FN);
    if (fitsWithin(tmp.btyp, B_EXTERN)) tmp.btyp = minus(tmp.btyp, B_EXTERN);
    putq(QINDENT);
    emitsymb(tmp);
    if (isFn)
        putq(" =%c add ", regtyp(tmp.btyp & 0xffffff7f));
    else
        putq(" =%c load%s ", regtyp(tmp.btyp & 0xffffff7f), fntyp(tmp.btyp & 0xffffff7f));
    emitsymb(m);
    if (isFn) putq(", 0");
    putq("\n");
    return tmp;
}

void emitcall(Node *n, Symb *sr) {
    Node *a;  int iEllipsis, iArg;  Symb *ps, s, sfn;  int isExtern=0;
    char *name = n->l->s.u.v;
    if (!(ps = symget(name))) die("undeclared function %s", name);
    s = *ps;
    if ((s.styp != Glo) && (s.styp != Ext) && (s.styp != Fn))
        bug(MINC_QBE_H ">>emitcall @ %d", __LINE__);
    isExtern = fitsWithin(s.btyp, B_EXTERN);
    for (a = n->r; a; a = a->r)
        a->s = emitexpr(a->l);                      // mutate the node with the allocated symbol
    if ((KIND(s.btyp) & 0x7f) == B_FN) {
        sr->btyp = tRet(s.btyp) & 0x7f7f7f7f;
        putq(QINDENT);
        if (sr->btyp == B_VOID) {
            putq("call ");
            if (isExtern) putq("extern ");
            putq("$%s(", name);
        } else {
            emitsymb(*sr);
            putq(" =%s call ", fntyp(sr->btyp));
            if (isExtern) putq("extern ");
            putq("$%s(", name);
        }
    }
    else if (KIND(s.btyp) == B_PTR && KIND(DREF(s.btyp)) == B_FN) {
        sr->btyp = tRet(DREF(s.btyp)) & 0x7f7f7f7f;
        isExtern = fitsWithin(s.btyp, B_EXTERN);
        sfn.styp = Tmp;
        sfn.u.n = reserve_tmp();
        sfn.btyp = s.btyp;
        sfn = emitload(sfn, s);
        putq(QINDENT);
        if (sfn.btyp == B_VOID) {
            putq("call ");
            if (isExtern) putq("extern ");
            emitsymb(sfn);
            putq("(");
        } else {
            emitsymb(*sr);
            putq(" =%s call ", fntyp(sr->btyp));
            if (isExtern) putq("extern ");
            emitsymb(sfn);
            putq("(");
        }
    }
    else
        bug(MINC_QBE_H ">>emitcall @ %d", __LINE__);
    a = n->r;  iArg = 1;  iEllipsis = s.i;
    while (a) {
        if (iArg == iEllipsis) putq("..., ");
        putq("%s ", fntyp(a->s.btyp & 0xffffff7f));
        emitsymb(a->s);
        a = a->r;
        if (a) putq(", ");
        iArg++;
    }
    putq(")\n");
    // OPEN: extend sub word return types?
}

void emitboolop(Node *n, char *tlabel, int tn, char*flabel, int fn) {
    Symb s;  int l;
    switch (n->tok) {
        default:
            s = emitexpr(n); /* OPEN: insert comparison to 0 with proper type */
            putq(QINDENT "jnz ");
            emitsymb(s);
            putq(", " LABEL);
            putq(tlabel, tn);
            putq(", " LABEL);
            putq(flabel, fn);
            putq("\n");
            break;
        case OP_OR:
            l = reserve_lbl(1);
            emitboolop(n->l, tlabel, tn, "or.%d.false", l);
            putq(LABEL "or.%d.false\n", l);
            emitboolop(n->r, tlabel, tn, flabel, fn);
            break;
        case OP_AND:
            l = reserve_lbl(1);
            emitboolop(n->l, "and.%d.true", l, flabel, fn);
            putq(LABEL "and.%d.true\n", l);
            emitboolop(n->r, tlabel, tn, flabel, fn);
            break;
    }
}

void emitbreak(Node *n, int b) {
    if (b < 0) die("break not in loop");
    putq(QINDENT "jmp " LABEL "while.end.%d\n", b);
}

void emitret(Node *n) {
    Symb x;
    if (n->l) {
        x = emitexpr(n->l);
        putq(QINDENT "ret ");
        emitsymb(x);
    } else
        putq(QINDENT "ret");
    putq("\n");
}

void emitif(Node *n, int b) {
    int l;
    l = reserve_lbl(1);
    putq(LABEL "if.%d\n", l);
    emitboolop(n->l, "if.%d.true", l, "if.%d.end", l);
    putq(LABEL "if.%d.true\n", l);
    emitstmt(n->r, b);
    putq(LABEL "if.%d.end\n", l);
}

int emitifelse(Node *n, int b) {
    int l, r;  Node *e;
    l = reserve_lbl(1);
    putq(LABEL "if.%d\n", l);
    emitboolop(n->l, "if.%d.true", l, "if.%d.false", l);
    putq(LABEL "if.%d.true\n", l);
    e = n->r;
    if (!(r=emitstmt(e->l, b)))
        putq(QINDENT "jmp " LABEL "if.%d.end\n", l);
    putq(LABEL "if.%d.false\n", l);
    if (!(r &= emitstmt(e->r, b)))
        putq(LABEL "if.%d.end\n", l);
    return e->r && r;
}

void emitwhile(Node *n) {
    int l;
    l = reserve_lbl(1);
    putq(LABEL "while.%d.cond\n", l);
    emitboolop(n->l, "while.%d.body", l, "while.%d.end", l);
    putq(LABEL "while.%d.body\n", l);
    if (!emitstmt(n->r, 1))
        putq(QINDENT "jmp " LABEL "while.%d.cond\n", l);
    putq(LABEL "while.%d.end\n", l);
}

void emitfunc(enum btyp tRet, char *fnname, NameType *params, Node *stmts) {
    NameType *p;  int i, sz;
    PP(emit, "emitFunc: %s", fnname);
    if (tRet == B_VOID)
        putq("export function $%s(", fnname);
    else
        putq("export function %s $%s(", fntyp(tRet), fnname);
    if ((p=params))
        do {
            putq("%s ", fntyp(p->btyp));
            putq(TEMP "%d", reserve_tmp());
            p = p->next;
            if (p) putq(", ");
        } while (p);
    putq(") {\n");
    putq(LABEL "start.%d\n", reserve_lbl(1));
    for (i=TMP_START, p=params; p; i++, p=p->next) {
        sz = SIZE(p->btyp);
        putq(QINDENT PVAR "%s =l alloc%d %d\n", p->name, sz, sz);
        putq(QINDENT "store%c " TEMP "%d", storetyp(p->btyp), i);
        putq(", " PVAR "%s\n", p->name);
    }
    putq(LABEL "body.%d\n", reserve_lbl(1));
    if (!emitstmt(stmts, -1)) putq(QINDENT "ret\n");    // for the case of a void function with no return statement
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

static enum btyp _emitpromotion(enum tok tok, Symb *l, Symb *r) {
    Symb *t;  int sz;

    if ((KIND(l->btyp) != B_PTR) && (KIND(r->btyp) != B_PTR)) {
        // 2 non pointers
        if (l->btyp == r->btyp) return l->btyp;

//        if (l->btyp == B_I64) {
//            switch (r->btyp) {
//                case B_I8:
//                    *r = emit_sb_to_l(*r);
//                    break;
//                case B_I16:
//                    *r = emit_sh_to_l(*r);
//                    break;
//                case B_I32:
//                    *r = emit_sw_to_l(*r);
//                    break;
//            }
//            return B_I64;
//        }
//
//        if (r->btyp == B_I64) {
//            switch (l->btyp) {
//                case B_I8:
//                    *l = emit_sb_to_l(*l);
//                    break;
//                case B_I16:
//                    *l = emit_sh_to_l(*l);
//                    break;
//                case B_I32:
//                    *l = emit_sw_to_l(*l);
//                    break;
//            }
//            return B_I64;
//        }
//
//        if (l->btyp == B_I32) {
//            switch (r->btyp) {
//                case B_I8:
//                    *r = emit_sb_to_w(*r);
//                    break;
//                case B_I16:
//                    *r = emit_sh_to_w(*r);
//                    break;
//            }
//            return B_I32;
//        }
//
//        if (r->btyp == B_I32) {
//            switch (l->btyp) {
//                case B_I8:
//                    *l = emit_sb_to_w(*l);
//                    break;
//                case B_I16:
//                    *l = emit_sh_to_w(*l);
//                    break;
//            }
//            return B_I32;
//        }
//
//        if (l->btyp == B_F64 && r->btyp == B_I32) {
//            *r = emit_sw_to_d(*r);
//            return B_F64;
//        }
//
//        if (l->btyp == B_F64 && r->btyp == B_I64) {
//            *r = emit_sl_to_d(*r);
//            return B_F64;
//        }

        nyi("oh dear @ %d", __LINE__);
    }
    else {
        // we have 1 or more pointers
        if (tok == OP_ADD) {
            if (KIND(r->btyp) == B_PTR) {
                if (KIND(l->btyp) == B_PTR) die("can't add pointers");
                t = l;
                l = r;
                r = t;
            }
            goto Scale;
        }

        if (tok == OP_SUB) {
            if (KIND(l->btyp) != B_PTR)
                die("pointer substracted from integer");
            if (KIND(r->btyp) != B_PTR) goto Scale;
            if (l->btyp != r->btyp) die("non-homogeneous pointers in substraction");
            return B_I64;
        }

    Scale:
        sz = SIZE(DREF(l->btyp));
        if (r->styp == Con)
            r->u.n *= sz;
        else {
            switch (r->btyp) {
                case B_I8:
                case B_U8:
                case B_I16:
                case B_U16:
                case B_I32:
                case B_U32:
                    r->u.n = emit_int_to_WL(r->btyp, *r, 'l');
                    r->styp = Tmp;
                    break;
                case B_I64:
                case B_U64:
                    break;
                default:
                    die("oh dear @ ", __LINE__);
                    break;
            }
            putq(QINDENT TEMP "%d =l mul %d, ", tmp_seed, sz);
            emitsymb(*r);
            putq("\n");
            r->u.n = reserve_tmp();
        }
        return l->btyp;
    }
}


//// the bst node will need to have a function pointer to the correct one
//
//// ww -> w
//Symb emitadd2_1(Node *n) {
//    putq(QINDENT);
//    emitsymb(sr);
//    putq(" =w", regtyp(sr.btyp));
//    putq(" add ", otoa[o], ty);
//}
//
//// wl -> w
//Symb emitadd2_2(Node *n) {
//    putq(QINDENT);
//    emitsymb(sr);
//    putq(" =w", regtyp(sr.btyp));
//    putq(" add ", otoa[o], ty);
//}
//
//// lw -> w
//Symb emitadd2_3(Node *n) {
//    putq(QINDENT);
//    emitsymb(sr);
//    putq(" =w", regtyp(sr.btyp));
//    putq(" add ", otoa[o], ty);
//}
//
//// and so on


Symb emitexpr(Node *n) {
    Symb sr, s0, s1, st;  enum tok o;  int l;  char ty[2];

    sr.styp = Tmp;
    sr.u.n = reserve_tmp();
    sr.btyp = 0;

    switch (n->tok) {

        case OP_OR:
        case OP_AND:
            l = reserve_lbl(3);
            emitboolop(n, "bool.%d.true", l, "bool.%d.false", l);
            putq(LABEL "bool.%d.true\n", l);
            putq(QINDENT "jmp " LABEL "bool.%d.end\n", l);
            putq(LABEL "bool.%d.false\n", l);
            putq(QINDENT "jmp " LABEL "bool.%d.end\n", l);
            putq(LABEL "bool.%d.end\n", l);
            putq(QINDENT);
            sr.btyp = B_I32;
            emitsymb(sr);
            putq(" =w phi " LABEL "bool.%d.true 1, " LABEL "bool.%d.false 0\n", l, l);
            break;

        case IDENT:
            // NEXT: need to handle pointers to functions as they are a little different semantically
            // is there a hack to get this working in the short term? probably
            s0 = lval(n);
            sr.btyp = s0.btyp;
            sr = emitload(sr, s0);
            break;

        case LIT_DEC:
            sr.styp = Con;
            sr.u.d = n->s.u.d;
            sr.btyp = B_F64;
            break;

        case LIT_INT:
            // OPEN: might need literal unsigned long or maybe just L for long
            sr.styp = Con;
            sr.u.n = n->s.u.n;
            sr.btyp = n->s.btyp;
            sr.btyp = B_I32;
            break;

        case LIT_CHAR:
            sr.styp = Con;
            sr.u.n = n->s.u.n;
            sr.btyp = B_CHAR;
            break;

        case LIT_STR:
            sr.styp = Str;
            sr.i = n->s.i;
            sr.btyp = B_CHAR_STAR;
            break;

        case OP_CALL:
            emitcall(n, &sr);
            break;

        case OP_DEREF:
            s0 = emitexpr(n->l);
            if (!fitsWithin(s0.btyp, B_PTR)) die("dereference of a non-pointer");
            sr.btyp = DREF(s0.btyp);
            sr = emitload(sr, s0);
            break;

        case OP_ADDR:
            sr = lval(n->l);
            sr.btyp = IDIR(sr.btyp);
            break;

        case OP_NEG:
            if (!z) {
                z = node(LIT_INT, 0, 0, 0);
                z->s.styp = Con;
                z->s.u.n = 0;
            }
            z->s.btyp = B_I8;
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
            if (s0.btyp == 0)
                die("s0.btyp == 0");
            s1 = lval(n->l);        // always memory
            sr = s0;                // consider for example `if (x=1+1) {`

            // OPEN: think through how to make this clearer and simpler - there's 100 possibilities

            // OPEN: do not change the btype
            // https://stackoverflow.com/questions/19262851/what-is-the-rule-for-c-to-cast-between-short-and-int
            // https://stackoverflow.com/questions/67550041/assigning-a-short-to-int-fails
            if (s1.btyp == B_I16 && s0.btyp == B_I8)  emit_sb_to_w(s0);
            if (s1.btyp == B_I32 && s0.btyp == B_I8)  emit_sb_to_w(s0);
            if (s1.btyp == B_I64 && s0.btyp == B_I8)  emit_sb_to_l(s0);
            if (s1.btyp == B_I32 && s0.btyp == B_I16) emit_sh_to_w(s0);
            if (s1.btyp == B_I64 && s0.btyp == B_I16) emit_sh_to_l(s0);
            if (s1.btyp == B_I64 && s0.btyp == B_I32) emit_sw_to_l(s0);

            // OPEN: sort LIT_INT https://www.tutorialspoint.com/cprogramming/c_constants.htm#:~:text=Integer%20Literals,for%20unsigned%20and%20long%2C%20respectively.
            if (s1.btyp == B_I32 && s0.btyp == B_I64 && n->r->tok == LIT_INT) s0.btyp = B_I32;   // HACK - need to figure how to cast LIT_INT properly
            if (s1.btyp == B_I32 && s0.btyp == B_I64 && n->r->tok == OP_SUB) s0.btyp = B_I32;   // HACK - need to figure how to cast LIT_INT properly

            if (s1.btyp == B_F64 && s0.btyp == B_I8) emit_sw_to_d(s0);
            if (s1.btyp == B_F64 && s0.btyp == B_I16) emit_sw_to_d(s0);
            if (s1.btyp == B_F64 && s0.btyp == B_I32) emit_sw_to_d(s0);
            if (s1.btyp == B_F64 && s0.btyp == B_I64) emit_sl_to_d(s0);

            if (
                    (fitsWithin(s1.btyp, B_PTR) && s0.btyp == B_VOID_STAR) ||
                    ((s1.btyp == B_VOID_STAR && fitsWithin(s0.btyp, B_PTR)))
                ) {}
            else if (
                    fitsWithin(s1.btyp, B_FN_PTR) && fitsWithin(KIND(s0.btyp), B_FN)
                )
            {}
            else {
                if (s1.btyp != s0.btyp) {
                    s0 = emitexpr(n->r);
                    die("invalid assignment");
                }
            }
            // END OPEN:

            putq(QINDENT "store%c ", storetyp(s1.btyp));
            goto emit_s0_s1;

        case OP_INC:
        case OP_DEC:
            o = n->tok == OP_INC ? OP_ADD : OP_SUB;    // e.g. x += 1  => x = x + 1
            st = lval(n->l);
            s0.styp = Tmp;
            s0.u.n = reserve_tmp();
            s0.btyp = st.btyp;
            s0 = emitload(s0, st);
            s1.styp = Con;
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
            sr.btyp = _emitpromotion(o, &s0, &s1);
            if (strchr(neltl, n->tok)) {
                sprintf(ty, "%c", regtyp(sr.btyp));
                sr.btyp = B_I32;            // OPEN: should be a B_BOOL
            } else
                strcpy(ty, "");
            putq(QINDENT);
            emitsymb(sr);
            putq(" =%c", regtyp(sr.btyp));
            putq(" %s%s ", otoa[o], ty);
        emit_s0_s1:
            emitsymb(s0);
            putq(", ");
            emitsymb(s1);
            putq("\n");
            break;
    }
    if (n->tok == OP_SUB  &&  fitsWithin(s0.btyp, B_PTR)  &&  fitsWithin(s1.btyp, B_PTR)) {
        putq(QINDENT TEMP "%d =l div ", tmp_seed);
        emitsymb(sr);
        putq(", %d\n", SIZE(DREF(s0.btyp)));
        sr.u.n = reserve_tmp();
    }
    if (n->tok == OP_INC  ||  n->tok == OP_DEC) {
        putq(QINDENT "store%c ", storetyp(st.btyp));
        emitsymb(sr);
        putq(", ");
        emitsymb(st);
        putq("\n");
        sr = s0;
    }
    return sr;
}

#endif //MINC_MINC_H