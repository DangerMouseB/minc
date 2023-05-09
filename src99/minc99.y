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

 minc, a minimal C derrived from minic by Quentin Carbonneaux, is supposed to be useful in exploring how to
 generate QBE IR. As well as convering the basics for doing C it also is a starting point for higher level ideas,
 such as inlining, multidispatch, and exception handling.

 The code here should be simple (in the Rich Hickey sense) and easy to understand.

 The yacc grammar was replaced with a popular one found here https://www.quut.com/c/ANSI-C-grammar-y-1999.html.

 Stmt and Node were merged.

 We won't implement the full C99 standard but I'm a firm be believer in designing for the future even whilst
 implementing for the now.

 We will continue to use Quentin's  YACC implementation.

 * to be extendable in ways that don't confirm to the standard such as:
    * adding bones style memory management based on stack, sratch and heap
    * add rust borrow style
    * add bones types
    * add logging for debugging in the background



 *** NAMING CONVENTION ***

 TOKEN            (including T_TYPENAME_)
 OP_OPERATION     (e.g. OP_ADD, except IDENT, LIT_INT, LIT_DEC, LIT_STR)
 T_TYPE



 *** NOTES ***

 OPEN: move the global variables into a struct? Actually we only need to do that if we want the compiler to be
 reentrant in Python. Which we probably don't need.


https://cdecl.org/


 NEXT

 store function definitions with their types -> check types on call AND insert ellipses properly
 need a function struct

 check emission conforms to minic



 registers are 64bit
 so tmps are 32 bit or 64 bit
 only stucts need to be 8 bit etc and want them cache local - stack will be cache local

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
#define TEMP    "%%."
#define PVAR    "%%_"
#define LABEL   "@L"


Symb emitexpr(Node *);

Symb lval(Node *);



enum btyp ptdeclarationspecifiersToBTypeId(Node *ds) {
    // OPEN: convert tokens to the correct hardcoded btyp enum
    enum tok op;  Node *n;  enum btyp baseType = B_ILLEGAL;  int hasSigned = 0;  int hasUnsigned = 0;  int hasConst = 0;
    n = ds->l;
    while (n) {
        op = (enum tok) n->s.btyp;
        switch (n->tok) {

            case pt_storage_class_specifier:
                nyi("pt_function_specifier");
                break;

            case pt_type_specifier:
                switch (op) {
                    default:
                        die("op == %s @ %d", toktopp[op], __LINE__);
                        // OPEN handle long int and long long, and signed and unsigned
                    case T_VOID:
                        if (baseType != B_ILLEGAL) die("2 base types encountered %s and then %s", btyptopp[baseType], btyptopp[B_VOID]);
                        baseType = B_VOID;
                        break;
                    case T_CHAR:
                        if (baseType != B_ILLEGAL) die("2 base types encountered %s and then %s", btyptopp[baseType], btyptopp[B_CHAR_DEFAULT]);
                        baseType = B_CHAR_DEFAULT;
                        break;
                    case T_SHORT:
                        if (baseType != B_ILLEGAL) die("2 base types encountered %s and then %s", btyptopp[baseType], btyptopp[B_I16]);
                        baseType = B_I16;
                        break;
                    case T_INT:
                        if (baseType != B_ILLEGAL) die("2 base types encountered %s and then %s", btyptopp[baseType], btyptopp[B_I32]);
                        baseType = B_I32;
                        break;
                    case T_LONG:
                        if (baseType != B_ILLEGAL) die("2 base types encountered %s and then %s", btyptopp[baseType], btyptopp[B_I64]);
                        baseType = B_I64;
                        break;
                    case T_FLOAT:
                        if (baseType != B_ILLEGAL) die("2 base types encountered %s and then %s", btyptopp[baseType], btyptopp[B_F32]);
                        baseType = B_F32;
                        break;
                    case T_DOUBLE:
                        if (baseType != B_ILLEGAL) die("2 base types encountered %s and then %s", btyptopp[baseType], btyptopp[B_F64]);
                        baseType = B_F64;
                        break;
                    case T_UNSIGNED:
                        if (hasUnsigned) die("unsigned already encountered before unsigned");
                        if (hasSigned) die("signed already encountered before unsigned");
                        hasUnsigned = 1;
                        break;
                    case T_SIGNED:
                        if (hasUnsigned) die("unsigned already encountered before signed");
                        if (hasSigned) die("signed already encountered before signed");
                        hasSigned = 1;
                        break;
                }
                break;

            case pt_type_qualifier:
                switch (op) {
                    default:
                        die("op == %s @ %d", toktopp[op], __LINE__);
                    case T_CONST:
                        if (hasConst) die("const already encountered");
                        hasConst = 1;
                        break;
                }
                break;

            case pt_function_specifier:
                nyi("pt_function_specifier");
                break;

            default:
                die("here");

        }
        n = n->r;
    }
    if (hasSigned) {
        switch (baseType) {
            case B_CHAR_DEFAULT:
                return baseType = B_I8;
                break;
            case B_I16:
                baseType = B_I16;
                break;
            case B_ILLEGAL:
            case B_I32:
                baseType = B_I32;
                break;
            case B_I64:
                baseType = B_I64;
                break;
            default:
                die("illegal type - signed %s @ &d", toktopp[op], __LINE__);
        }
    }
    if (hasUnsigned) {
        switch (baseType) {
            case B_CHAR_DEFAULT:
                return baseType = B_U8;
                break;
            case B_I16:
                baseType = B_U16;
                break;
            case B_ILLEGAL:
            case B_U32:
                baseType = B_U32;
                break;
            case B_U64:
                baseType = B_U64;
                break;
            default:
                die("illegal type - signed %s @ &d", toktopp[op], __LINE__);
        }
    }
    if (hasConst) nyi("const");
    return baseType;
}

char irtyp(enum btyp btyp) {
    // OPEN: sort out ub, sb, uh, sb, b and h
    switch (KIND(btyp)) {
        case B_VOID: return 'V';
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
    return 'l';
}

unsigned int pointerise(enum btyp btyp, Node *ptr, int isarray) {
    // OPEN check for const, volatile, restrict
    while (ptr) {
        assertTok(ptr, "ptr", pt_pointer, __LINE__);
        if (ptr->l->tok == T_PTR) {
            btyp <<= 8;
            btyp |= B_PTR;
        }
        ptr = ptr->r;
    }
    if (isarray) {
        btyp <<= 8;
        btyp |= B_PTR;
    }
    return btyp;
}



// Node construction

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

Node * mkopassign(Node *op, Node *l, Node *r, int lineno) {
    if (op) {
        if (op->l != 0) die("n->l != 0 @ %d", __LINE__);
        if (op->r != 0) die("n->r != 0 @ %d", __LINE__);
        op->l = l;
        op->r = r;
        r = op;
    }
    return node(OP_ASSIGN, l, r, lineno);
}

Node * mktype(int tok, enum btyp t, int lineno) {
    Node * n = node(tok, 0, 0, lineno);
    n->s.btyp = t;
    return n;
}

Node * appendR(Node * start, Node * next) {
    if (start) {
        Node * end = start;
        while (end->r) end = end->r;
        end->r = next;
        return start;
    } else
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

Node * mkspecifierqualifierlist(Node * start, Node * specifierqualifier, int lineno) {
    Node * next = node(pt_specifier_qualifier_list, specifierqualifier, 0, lineno);
    return appendR(start, next);
}

Node * mkargumentexpressionlist(Node * start, Node * expr, int lineno) {
    Node * next = node(pt_argument_expression_list, expr, 0, lineno);
    return appendR(start, next);
}

Node * mkinitdeclarator(Node *declarator, Node *initializer, int lineno) {
    return node(pt_init_declarator, declarator, initializer, lineno);
}



// QBE IR emission

void emitboolop(Node *, int, int);
void emitLocalDecl(enum btyp t, char *varname);

void i8_to_i16(Symb *s);
void i8_to_i32(Symb *s);
void i8_to_i64(Symb *s);
void u8_to_u64(Symb *s);
void i16_to_i32(Symb *s);
void i16_to_i64(Symb *s);
void u16_to_u64(Symb *s);
void i32_to_i64(Symb *s);
void u32_to_u64(Symb *s);

void i8_to_f64(Symb *s);
void i16_to_f64(Symb *s);
void i32_to_f64(Symb *s);
void i64_to_f64(Symb *s);

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

enum btyp prom(int tok, Symb *l, Symb *r) {
    Symb *t;
    int sz;

    if (l->btyp == r->btyp && KIND(l->btyp) != B_PTR)
        return l->btyp;

    // l is pointer
    if (l->btyp == B_I64 && r->btyp == B_I32) {
        i8_to_i32(r);
        return B_I64;
    }
    if (l->btyp == B_I32 && r->btyp == B_I64) {
        i8_to_i32(l);
        return B_I64;
    }
    if (l->btyp == B_F64 && r->btyp == B_I32) {
        i32_to_f64(r);
        return B_F64;
    }
    if (l->btyp == B_F64 && r->btyp == B_I64) {
        i64_to_f64(r);
        return B_F64;
    }

    if (tok == OP_ADD) {
        // OPEN: handle double
        if (KIND(r->btyp) == B_PTR) {
            t = l;
            l = r;
            r = t;
        }
        if (KIND(r->btyp) == B_PTR) die("pointers added");
        goto Scale;
    }

    if (tok == OP_SUB) {
        // OPEN: handle double
        if (KIND(l->btyp) != B_PTR) die("pointer substracted from integer");
        if (KIND(r->btyp) != B_PTR) goto Scale;
        if (l->btyp != r->btyp) die("non-homogeneous pointers in substraction");
        return B_I64;
    }

Scale:
    // OPEN: handle double
    sz = SIZE(DREF(l->btyp));
    if (r->t == Con)
        r->u.n *= sz;
    else {
        switch (r->btyp) {
            case B_I8:
                i8_to_i64(r);
            case B_U8:
                u8_to_u64(r);
            case B_I16:
                i16_to_i64(r);
            case B_U16:
                u16_to_u64(r);
            case B_I32:
                i32_to_i64(r);
            case B_U32:
                u32_to_u64(r);
        }
        putq(INDENT TEMP "%d =l mul %d, ", tmp_seed, sz);
        emitsymb(*r);
        putq("\n");
        r->u.n = reserve_tmp();
    }
    return l->btyp;
}


void emitload(Symb d, Symb s) {
    putq(INDENT);
    emitsymb(d);
    putq(" =%c load%c ", irtyp(d.btyp), irtyp(d.btyp));
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
        putq(" =%c call $%s(", irtyp(sr->btyp), name);
    }
    a = n->r; iArg = 1;
    while (a) {
        if (iArg == iEllipsis) putq("..., ");
        putq("%c ", irtyp(a->s.btyp));
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
    Symb sr, s0, s1, st;
    enum tok o;
    int l;
    char ty[2];

    sr.t = Tmp;
    sr.u.n = reserve_tmp();

    switch (n->tok) {

        // both these short circuit
        case OP_OR:
        case OP_AND:
            l = reserve_lbl(3);
            emitboolop(n, l, l+1);
            putq(LABEL "%d\n", l);
            putq(INDENT "jmp " LABEL "%d\n", l+2);
            putq(LABEL "%d\n", l+1);
            putq(INDENT "jmp " LABEL "%d\n", l+2);
            putq(LABEL "%d\n", l+2);
            putq(INDENT);
            sr.btyp = B_I32;
            emitsymb(sr);
            putq(" =w phi " LABEL "%d 1, " LABEL "%d 0\n", l, l+1);
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
            sr.t = Con;
            sr.u.n = n->s.u.n;
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
            sr.btyp = IDIR(T_INT);   // OPEN ????
            break;

        case OP_CALL:
            emitcall(n, &sr);
            break;

        case OP_DEREF:
            s0 = emitexpr(n->l);
            if (KIND(s0.btyp) != B_PTR)
                die("dereference of a non-pointer");
            sr.btyp = DREF(s0.btyp);
            emitload(sr, s0);
            break;

        case OP_ADDR:
            sr = lval(n->l);
            sr.btyp = IDIR(sr.btyp);
            break;

        case OP_ASSIGN:
            // y = x  => store x, y  => store s0, s1
            s0 = emitexpr(n->r);
            s1 = lval(n->l);        // always a pointer,
            sr = s0;
            if (s1.btyp == B_I16 && s0.btyp == B_I8)  i8_to_i16(&s0);
            if (s1.btyp == B_I32 && s0.btyp == B_I8)  i8_to_i32(&s0);
            if (s1.btyp == B_I64 && s0.btyp == B_I8)  i8_to_i64(&s0);
            if (s1.btyp == B_I32 && s0.btyp == B_I16) i16_to_i32(&s0);
            if (s1.btyp == B_I64 && s0.btyp == B_I16) i16_to_i64(&s0);
            if (s1.btyp == B_I64 && s0.btyp == B_I32) i32_to_i64(&s0);

            if (s1.btyp == B_F64 && s0.btyp == B_I8) i8_to_f64(&s0);
            if (s1.btyp == B_F64 && s0.btyp == B_I16) i16_to_f64(&s0);
            if (s1.btyp == B_F64 && s0.btyp == B_I32) i32_to_f64(&s0);
            if (s1.btyp == B_F64 && s0.btyp == B_I64) i64_to_f64(&s0);

            if (s0.btyp != IDIR(B_VOID) || KIND(s1.btyp) != B_PTR)
                if (s1.btyp != IDIR(B_VOID) || KIND(s0.btyp) != B_PTR)
                    if (s1.btyp != s0.btyp) die("invalid assignment");
            putq(INDENT "store%c ", irtyp(s1.btyp));
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
            // handle all the binary ops
            if ((OP_BIN_START <= n->tok) && (n->tok <= OP_BIN_END)) {
                s0 = emitexpr(n->l);
                s1 = emitexpr(n->r);
                o = n->tok;
            }
            else {
                die("%s is not an expression", toktopp[n->tok]);
                return sr;
            }
        binop:
            // t = op s0 s1
            sr.btyp = prom(o, &s0, &s1);
            if (strchr(neltl, n->tok)) {
                sprintf(ty, "%c", irtyp(sr.btyp));
                sr.btyp = B_I32;            // OPEN: should be a B_BOOL
            } else
                strcpy(ty, "");
            putq(INDENT);
            emitsymb(sr);
            putq(" =%c", irtyp(sr.btyp));
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
        putq(INDENT "store%c ", irtyp(st.btyp));
        emitsymb(sr);
        putq(", ");
        emitsymb(st);
        putq("\n");
        sr = s0;
    }
    return sr;
}


//<:Symb> lval(<:Node&ptr> n) {
//<:Symb> lval(<:pNode> n) {
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
            l = reserve_lbl(1);
            emitboolop(n->l, lt, l);
            putq(LABEL "%d\n", l);
            emitboolop(n->r, lt, lf);
            break;
        case OP_AND:
            l = reserve_lbl(1);
            emitboolop(n->l, l, lf);
            putq(LABEL "%d\n", l);
            emitboolop(n->r, lt, lf);
            break;
    }
}


int emitstmt(Node *s, int b) {
    int l, r;  Symb x;  enum btyp t;  char *varname;  Node *ds, *idl, *id, *d, *ini;

    if (!s) return 0;
    PP(emit, "%s", toktopp[s->tok]);

    switch (s->tok) {
        case pt_declaration:
            assertTok(s, "s", pt_declaration, __LINE__);
            assertExists(ds=s->l, "s->l", __LINE__);
            assertTok(ds, "ds", pt_declaration_specifiers, __LINE__);
            t = ptdeclarationspecifiersToBTypeId(ds);
            idl = s->r;
            while (idl) {
                assertTok(idl, "idl", pt_init_declarator_list, __LINE__);
                assertExists(id=idl->l, "id", __LINE__);
                assertTok(id, "id", pt_init_declarator, __LINE__);
                assertExists(d=id->l, "d", __LINE__);
                assertTok(d, "d", pt_declarator, __LINE__);
                assertExists(d->r, "d->r", __LINE__);
                assertTok(d->r, "d->r", IDENT, __LINE__);
                varname = d->r->s.u.v;
                emitLocalDecl(pointerise(t, d->l, 0), varname);
                if ((ini=id->r)) {
                    emitexpr(node(OP_ASSIGN, d->r, ini, __LINE__));
                }
                idl = idl->r;
            }
            return 0;
        case Ret:
            PP(emit, "Ret");
            if (s->l) {
                x = emitexpr(s->l);
                putq(INDENT "ret ");
                emitsymb(x);
            } else
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
            l = reserve_lbl(2);
            emitboolop(s->l, l, l+1);
            putq(LABEL "%d\n", l);
            emitstmt(s->r, b);
            putq(LABEL "%d\n", l+1);
            return 0;
        case IfElse:
            l = reserve_lbl(3);
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
            l = reserve_lbl(3);
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


void emitGlobals() {
    for (int oglo = 0; oglo < oglo_seed; oglo++)
        if (data_defs[oglo])
            putq("data " GLOBAL "%d = %s\n", oglo, data_defs[oglo]);
};


void startFunc(enum btyp t, char *fnname, NameType *params) {
    NameType *p;  int i, m;
    PP(emit, "startFunc: %s", fnname);

    symadd(fnname, reserve_glo(), FUNC(t));
    if (t == B_VOID)
        putq("export function $%s(", fnname);
    else
        putq("export function %c $%s(", irtyp(t), fnname);
    if ((p=params))
        do {
            symadd(p->name, 0, p->btyp);
            putq("%c ", irtyp(p->btyp));
            putq(TEMP "%d", reserve_tmp());
            p = p->next;
            if (p) putq(", ");
        } while (p);
    putq(") {\n");
    putq(LABEL "start.%d\n", reserve_lbl(1));
    for (i=SEED_START, p=params; p; i++, p=p->next) {
        m = SIZE(p->btyp);
        putq(INDENT PVAR "%s =l alloc%d %d\n", p->name, m, m);
        putq(INDENT "store%c " TEMP "%d", irtyp(p->btyp), i);
        putq(", " PVAR "%s\n", p->name);
    }
    putq(LABEL "body.%d\n", reserve_lbl(1));
}


void finishFunc(Node *s) {
    PP(emit, "finishFunc");
    if (!emitstmt(s, -1)) putq(INDENT "ret\n");    // for the case of a void function with no return statement
    putq("}\n\n");
    symclr();
    tmp_seed = SEED_START;
}


NameType * ptparametertypelistToParameters(Node * ptl) {
    NameType *start=0, *next, *prior=0;  Node *pd, *ds, *d, *id;  int is_array = 0;  enum btyp t;
    if (!ptl) return NULL;
    while(ptl) {
        next = allocInBuckets(&nodes, sizeof (NameType), alignof (NameType));
        if (!start) start = next;
        if (prior) prior->next = next;
        assertTok(ptl, "ptl", pt_parameter_type_list, __LINE__);
        assertExists((pd=ptl->l), "ptl->l", __LINE__);
        assertTok(pd, "pd", pt_parameter_declaration, __LINE__);
        assertExists((d=pd->r), "pd->r", __LINE__);
        assertTok(d, "d", pt_declarator, __LINE__);
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
        assertTok(id, "id", IDENT, __LINE__);
        next->name = id->s.u.v;
        assertExists((ds=pd->l), "pd->l", __LINE__);
        assertTok(ds, "ds", pt_declaration_specifiers, __LINE__);
        t = ptdeclarationspecifiersToBTypeId(ds);
        t = pointerise(t, d->l, is_array);
        next->btyp = t;
        ptl = ptl->r;
        prior = next;
    }
    return start;
}


// declaration_specifiers, declarator, declaration_list, compound_statement
void c99_emit_function_definition(Node *ds, Node *d, Node *dl, Node* cs) {
    NameType *params = 0;  unsigned int t;
    PP(emit, "c99_emit_function_definition");
    assertTok(ds, "ds", pt_declaration_specifiers, __LINE__);
    assertTok(d, "d", pt_declarator, __LINE__);
    t = ptdeclarationspecifiersToBTypeId(ds);
    t = pointerise(t, d->l, 0);
    assertTok(d->r, "d->r", func_def, __LINE__);
    assertExists(d->r->l, "d->r->l", __LINE__);
    assertTok(d->r->l, "d->r->l", IDENT, __LINE__);
    if (d->r->r) {
        assertTok(d->r->r, "d->r->r", pt_parameter_type_list, __LINE__);
        params = ptparametertypelistToParameters(d->r->r);
    }
    startFunc(t, d->r->l->s.u.v, params);
    finishFunc(cs);
}


void emitLocalDecl(enum btyp t, char *varname) {
    PP(emit, "emitLocalDecl\n");
    int s;
    if (t == B_VOID) die("invalid void declaration");
    PPbtyp(emit, t);
    s = SIZE(t);
    symadd(varname, 0, t);
    putq(INDENT PVAR "%s =l alloc%d %d\n", varname, s, s);
}


// declaration
void c99_emit_declaration(Node *n) {
    // declaration_specifiers, init_declarator_list, init_declarator, declarator
    Node *ds, *idl, *id, *d, *fd, *ptl, *pd;  enum btyp btyp, t;  char *name;  int isVoid = 0;
    PP(parse, "c99_emit_declaration\n");
    assertTok(n, "n", pt_declaration, __LINE__);
    // get the common type
    assertTok((ds=n->l), "n->l", pt_declaration_specifiers, __LINE__);
    btyp = ptdeclarationspecifiersToBTypeId(ds);
    // process each declarator
    assertTok((idl=n->r), "n->r", pt_init_declarator_list, __LINE__);
    // OPEN: handle reclaration (don't allow reinit, keep fn and data separate)
    do {
        assertTok((id=idl->l), "idl->l", pt_init_declarator, __LINE__);
        if (id->r) nyi("declarator '=' initializer @ %l", __LINE__);
        if ((d=id->l)->tok != pt_declarator) die("programmer error: d->tok != pt_declarator");
        if (oglo_seed == NGlo) die("too many globals");
        switch (d->r->tok) {
            default:
                die("programmer error");
            case IDENT:
                // variable definition
                name = d->r->s.u.v;
                t = pointerise(btyp, d->l, 0);      // OPEN: handle array
                if (isVoid && (KIND(t) != B_PTR)) die("invalid void declaration @ %d", d->lineno);
                data_defs[oglo_seed] = allocInBuckets(&all_strings, sizeof "{ x 0 }", 1);
                sprintf(data_defs[oglo_seed], "{ %c 0 }", irtyp(t));
                symadd(name, reserve_glo(), t);
                break;
            case func_def:
                fd = d->r;
                name = fd->l->s.u.v;
                ptl = fd->r;
                int i = 1;
                while (ptl) {
                    assertTok(ptl, "fd->r", pt_parameter_type_list, __LINE__);
                    assertExists(pd=ptl->l, "ptl->l", __LINE__);
                    if (pd->tok == T_ELLIPSIS) {i_ellipsis[oglo_seed] = i; break;}
                    assertTok(pd, "pd", pt_parameter_declaration, __LINE__);
                    i++;
                    ptl = ptl->r;
                }
                PP(parse, "c99_emit_declaration encountered %s (ellipsis @ %d) @ %d", toktopp[d->r->tok], i, d->lineno);
                t = pointerise(btyp, d->l, 0);      // OPEN: handle array?
                symadd(name, reserve_glo(), FUNC(t));
                break;
        }
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
| postfix_expression '[' expression ']'                 { PP(pt, "postfix_expression '[' expression ']'   =>   postfix_expression", $%); $$ = mkidx($1, $3, $%); }
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
: logical_or_expression                                             { $$ = $1; PP(pt, "logical_or_expression   =>   conditional_expression"); }
| logical_or_expression '?' expression ':' conditional_expression   { $$ = node(OP_IIF, $1, node(OP_TF, $3, $5, $%), $%); }
;

assignment_expression
: conditional_expression                                        { $$ = $1; PP(pt, "conditional_expression   =>   assignment_expression"); }
| unary_expression assignment_operator assignment_expression    { $$ = mkopassign($2, $1, $3, $%); PP(pt, "unary_expression assignment_operator assignment_expression   =>   assignment_operator"); }
;

assignment_operator
: '='                                                   { $$ = 0; PP(pt, "=   =>   assignment_operator"); }
| MUL_ASSIGN                                            { $$ = node(OP_MUL, 0, 0, $%); PP(pt, "*=   =>   assignment_operator"); }
| DIV_ASSIGN                                            { $$ = node(OP_DIV, 0, 0, $%); PP(pt, "/=   =>   assignment_operator"); }
| MOD_ASSIGN                                            { $$ = node(OP_MOD, 0, 0, $%); PP(pt, "%=   =>   assignment_operator"); }
| ADD_ASSIGN                                            { $$ = node(OP_ADD, 0, 0, $%); PP(pt, "+=   =>   assignment_operator"); }
| SUB_ASSIGN                                            { $$ = node(OP_SUB, 0, 0, $%); PP(pt, "-=   =>   assignment_operator"); }
| LEFT_ASSIGN                                           { $$ = node(OP_LSHIFT, 0, 0, $%); PP(pt, "<<=   =>   assignment_operator"); }
| RIGHT_ASSIGN                                          { $$ = node(OP_RSHIFT, 0, 0, $%); PP(pt, ">>=   =>   assignment_operator"); }
| AND_ASSIGN                                            { $$ = node(OP_BAND, 0, 0, $%); PP(pt, "&=   =>   assignment_operator"); }
| XOR_ASSIGN                                            { $$ = node(OP_BXOR, 0, 0, $%); PP(pt, "^=   =>   assignment_operator"); }
| OR_ASSIGN                                             { $$ = node(OP_BOR, 0, 0, $%); PP(pt, "|=   =>   assignment_operator"); }
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
| declarator '=' initializer                            { PP(pt, "declarator '=' initializer   =>   init_declarator"); $$ = mkinitdeclarator($1, $3, $%); }
;

storage_class_specifier
: TYPEDEF                                               { PP(pt, "TYPEDEF"); $$ = mktype(pt_storage_class_specifier, (enum btyp) T_TYPEDEF, $%); }
| EXTERN                                                { PP(pt, "EXTERN"); $$ = mktype(pt_storage_class_specifier, (enum btyp) T_EXTERN, $%); }
| STATIC                                                { PP(pt, "STATIC"); $$ = mktype(pt_storage_class_specifier, (enum btyp) T_STATIC, $%); }
| AUTO                                                  { PP(pt, "AUTO"); $$ = mktype(pt_storage_class_specifier, (enum btyp) T_AUTO, $%); }
| REGISTER                                              { PP(pt, "REGISTER"); $$ = mktype(pt_storage_class_specifier, (enum btyp) T_REGISTER, $%); }
;

type_specifier
: VOID                                                  { $$ = mktype(pt_type_specifier, (enum btyp) T_VOID, $%); }
| CHAR                                                  { $$ = mktype(pt_type_specifier, (enum btyp) T_CHAR, $%); }
| SHORT                                                 { $$ = mktype(pt_type_specifier, (enum btyp) T_SHORT, $%); }
| INT                                                   { $$ = mktype(pt_type_specifier, (enum btyp) T_INT, $%); }
| LONG                                                  { $$ = mktype(pt_type_specifier, (enum btyp) T_LONG, $%); }
| FLOAT                                                 { $$ = mktype(pt_type_specifier, (enum btyp) T_FLOAT, $%); }
| DOUBLE                                                { $$ = mktype(pt_type_specifier, (enum btyp) T_DOUBLE, $%); }
| SIGNED                                                { $$ = mktype(pt_type_specifier, (enum btyp) T_SIGNED, $%); }
| UNSIGNED                                              { $$ = mktype(pt_type_specifier, (enum btyp) T_UNSIGNED, $%); }
| BOOL                                                  { $$ = mktype(pt_type_specifier, (enum btyp) T_BOOL, $%); }
| COMPLEX                                               { $$ = mktype(pt_type_specifier, (enum btyp) T_COMPLEX, $%); }
| IMAGINARY                                             { $$ = mktype(pt_type_specifier, (enum btyp) T_IMAGINARY, $%); }
| struct_or_union_specifier                             { nyi("@ %d", $%); }
| enum_specifier                                        { nyi("@ %d", $%); }
| TYPE_NAME                                             { nyi("@ %d", $%); }
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
: type_specifier specifier_qualifier_list               { $$ = mkspecifierqualifierlist($1, $2, $%); }
| type_specifier                                        { $$ = mkspecifierqualifierlist($1, 0, $%); }
| type_qualifier specifier_qualifier_list               { $$ = mkspecifierqualifierlist($1, $2, $%); }
| type_qualifier                                        { $$ = mkspecifierqualifierlist($1, 0, $%); }
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
: CONST                                                 { $$ = mktype(pt_type_qualifier, (enum btyp) T_CONST, $%); }
| RESTRICT                                              { $$ = mktype(pt_type_qualifier, (enum btyp) T_RESTRICT, $%); }
| VOLATILE                                              { $$ = mktype(pt_type_qualifier, (enum btyp) T_VOLATILE, $%); }
;

function_specifier
: INLINE                                                { $$ = mktype(T_INLINE, 0, $%); }
;

// node(pt_declarator, l=pointerOrNull, r=pt_direct_declarator)
declarator
: pointer direct_declarator                             { PP(pt, "pointer direct_declarator   =>   declarator"); $$ = node(pt_declarator, $1, $2, $%); }
| direct_declarator                                     { PP(pt, "direct_declarator   =>   declarator"); $$ = node(pt_declarator, 0, $1, $%); }
;

// node()
direct_declarator
: IDENTIFIER                                                                    { PP(pt, "#%s IDENTIFIER   =>   direct_declarator", $1->s.u.v); }
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
: assignment_expression                                 { PP(pt, "assignment_expression   =>   initializer"); }
| '{' initializer_list '}'                              { nyi("@ %d", $%); }
| '{' initializer_list ',' '}'                          { nyi("@ %d", $%); }
;

initializer_list
: initializer                                           { PP(pt, "initializer   =>   initializer_list"); }
| designation initializer                               { $$ = bindr($1, $2, $%); }
| initializer_list ',' initializer                      { nyi("@ %d", $%); }
| initializer_list ',' designation initializer          { nyi("@ %d", $%); }
;

designation
: designator_list '='                                   { PP(pt, "designator_list '='   =>   designation"); $$ = node(OP_ASSIGN, $1, 0, $%); }
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
    int i, c, c2, c3, n;  char v[SYM_NAME_MAX], *p;  double d, s;

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

    // open handle octal and hexadecimal
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
            yylval.n->s.btyp = B_U64;
            PP(lex, "%d ", n);
            return CONSTANT;
        }
    }

    if (isalpha(c) || c == '_') {
        p = v;  n = 0;
        do {
            if (p == &v[SYM_NAME_MAX-1]) die("ident too long");
            *p++ = c;  n++;
            c = getc(inf);
        } while (isalnum(c) || c == '_');
        *p = 0;  n++;
        ungetc(c, inf);
        for (i=0; kwds[i].s; i++)
            if (strcmp(v, kwds[i].s) == 0)
                return kwds[i].t;
        yylval.n = node(IDENT, 0, 0, __LINE__);
        void *buf = allocInBuckets(&all_strings, n, 1);
        yylval.n->s.u.v = buf;
        strcpy(yylval.n->s.u.v, v);
        PP(lex, "IDENT: %s", v);
        // OPEN: check if it's a type name
        return IDENTIFIER;
    }

    // OPEN: handle multichar literals
    if (c == '\'') {
        n = getc(inf);
        if (n == '\\') {
            switch (n = getc(inf)) {    // https://johndecember.com/html/spec/ascii.html
                case '\0':
                    n = 0;      // NUL - null
                    break;
                case 'a':
                    n = 7;      // BEL - bell
                    break;
                case 'b':
                    n = 8;      // BS - backspace
                    break;
                case 'f':
                    n = 12;     // NP/FF - new page / form feed
                    break;
                case 'n':
                    n = 10;     // NL/LF - new line / line feed
                    break;
                case 'r':
                    n = 13;     // CR - carriage return
                    break;
                case 't':
                    n = 9;      // HT - Horizontal Tab
                    break;
                case '\\':
                    n = '\\';
                    break;
                case '\'':
                    n = '\'';
                    break;
                default:
                    nyi("unhandled escape sequence '\\%c'", n);
            }
        }
        yylval.n = node(LIT_CHAR, 0, 0, __LINE__);
        yylval.n->s.u.n = n;
        yylval.n->s.btyp = B_CHAR_DEFAULT;
        c = getc(inf);
        if (c != '\'') nyi("only single char literal supported");
        return CONSTANT;
    }

    if (c == '"') {
        i = 0;
        n = 32;
        p = allocInBuckets(&all_strings, n, 1);
        strcpy(p, "{ b \"");
        for (i=5;; i++) {
            c = getc(inf);
            if (c == EOF) die("unclosed string literal");
            if (i+8 >= n) {
                char* new = reallocInBuckets(&all_strings, p, n*2, 1);
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
        if (oglo_seed == NGlo) die("too many globals");
        data_defs[oglo_seed] = p;
        yylval.n = node(LIT_STR, 0, 0, __LINE__);
        yylval.n->s.u.n = reserve_glo();
        yylval.n->s.btyp = B_CHARS;
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
        case DI('<',':'):
            nyi("get type lang");
            return TYPE_NAME;
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
    initBuckets(&all_strings, 4096);
    initBuckets(&nodes, 4096);
    int ret = yyparse();
    if (ret) die("parse error (%d)", ret);
    emitGlobals();
    freeBuckets(all_strings.first_bucket);
    freeBuckets(nodes.first_bucket);

    return EXIT_SUCCESS;
}

//void t_to_t(enum btyp t1, enum btyp t2, Symb *s) {
//    putq(INDENT TEMP "%d =w extsb ", tmp_seed);
//    emitsymb(*s);
//    putq("\n");
//    s->t = Tmp;
//    s->btyp = t2;
//    s->u.n = reserve_tmp();
//}

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

