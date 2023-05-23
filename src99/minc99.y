%{

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


/*Beginning of C declarations*/

#define MINC_MINC99_Y "minc99.y"

#include <stdarg.h>
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include "minc.h"
#include "qbe.h"


int yylex(void);
void yyerror(char const *);



// ---------------------------------------------------------------------------------------------------------------------
// NODE CONSTRUCTION
// ---------------------------------------------------------------------------------------------------------------------

Node * node(int tok, Node *l, Node *r, int lineno) {
    Node *n = allocInBuckets(&nodes, sizeof *n, alignof (n));
    n->tok = tok;
    n->l = l;
    n->r = r;
    n->lineno = lineno;
    return n;
}

Node * bindl(Node *n, Node *l, int lineno) {
    if (!n) return l;
    if (n->l != 0) {
        PP(parse, "bindl from @%d", lineno);
        die("node.l already bound");
    }
    n->l = l;
    return n;
}

Node * bindr(Node *n, Node *r, int lineno) {
    if (!n) return r;
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

Symb emitexpr(Node *);

enum btyp prom(enum tok tok, Symb *l, Symb *r) {
    Symb *t;  int sz;

    if ((KIND(l->btyp) != B_PTR) && (KIND(r->btyp) != B_PTR)) {
        if (l->btyp == r->btyp) return l->btyp;

        if (l->btyp == B_I64) {
            switch (r->btyp) {
                case B_I8:
                    *r = i8_to_i64(*r);
                    break;
                case B_I16:
                    *r = i16_to_i64(*r);
                    break;
                case B_I32:
                    *r = i32_to_i64(*r);
                    break;
            }
            return B_I64;
        }

        if (r->btyp == B_I64) {
            switch (l->btyp) {
                case B_I8:
                    *l = i8_to_i64(*l);
                    break;
                case B_I16:
                    *l = i16_to_i64(*l);
                    break;
                case B_I32:
                    *l = i32_to_i64(*l);
                    break;
            }
            return B_I64;
        }

        if (l->btyp == B_I32) {
            switch (r->btyp) {
                case B_I8:
                    *r = i8_to_i32(*r);
                    break;
                case B_I16:
                    *r = i16_to_i32(*r);
                    break;
            }
            return B_I32;
        }

        if (r->btyp == B_I32) {
            switch (l->btyp) {
                case B_I8:
                    *l = i8_to_i32(*l);
                    break;
                case B_I16:
                    *l = i16_to_i32(*l);
                    break;
            }
            return B_I32;
        }

        if (l->btyp == B_F64 && r->btyp == B_I32) {
            *r = i32_to_f64(*r);
            return B_F64;
        }

        if (l->btyp == B_F64 && r->btyp == B_I64) {
            *r = i64_to_f64(*r);
            return B_F64;
        }

        nyi("oh dear");
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
        if (KIND(l->btyp) != B_PTR)
            die("pointer substracted from integer");
        if (KIND(r->btyp) != B_PTR) goto Scale;
        if (l->btyp != r->btyp) die("non-homogeneous pointers in substraction");
        return B_I64;
    }

Scale:
    // OPEN: handle double
    sz = SIZE(DREF(l->btyp));
    if (r->styp == Con)
        r->u.n *= sz;
    else {
        switch (r->btyp) {
            case B_I8:
                *r = i8_to_i64(*r);
                break;
            case B_U8:
                *r = u8_to_u64(*r);
                break;
            case B_I16:
                *r = i16_to_i64(*r);
                break;
            case B_U16:
                *r = u16_to_u64(*r);
                break;
            case B_I32:
                *r = i32_to_i64(*r);
                break;
            case B_U32:
                *r = u32_to_u64(*r);
                break;
            default:
                break;
        }
        putq(QINDENT TEMP "%d =l mul %d, ", tmp_seed, sz);
        emitsymb(*r);
        putq("\n");
        r->u.n = reserve_tmp();
    }
    return l->btyp;
}


// ---------------------------------------------------------------------------------------------------------------------
// PARSE TREE HELPERS
// ---------------------------------------------------------------------------------------------------------------------

int ptdeclarationspecifiersForExtern(Node *ds) {
    Node *n;
    n = ds->l;
    if (n && (n->tok == pt_storage_class_specifier) && (n->s.btyp == T_EXTERN)) return 1;
    return 0;
}

enum btyp ptdeclarationspecifiersToBTypeId(Node *ds) {
    // OPEN: convert tokens to the correct hardcoded btyp enum
    enum tok op;  Node *n;  enum btyp baseType = 0;  int hasSigned = 0, hasUnsigned = 0, hasConst = 0;
    n = ds->l;
    while (n) {
        op = (enum tok) n->s.btyp;
        switch (n->tok) {

            case pt_storage_class_specifier:
                switch (n->s.btyp) {
                    case T_TYPEDEF:
                        die("pt_storage_class_specifier, T_TYPEDEF should not be possible");
                    case T_EXTERN:
                        // ds( scs(), ds(ts() )
                        n = ds->r->l; // extern handled else where
                        break;
                    case T_STATIC:
                        nyi("pt_storage_class_specifier, T_STATIC");
                    case T_AUTO:
                        nyi("pt_storage_class_specifier, T_AUTO");
                    case T_REGISTER:
                        nyi("pt_storage_class_specifier, T_REGISTER");
                }
                break;

            case pt_type_specifier:
                switch (op) {
                    default:
                        nyi("op == %s @ %d", toktopp[op], __LINE__);
                        // OPEN handle long int and long long, and signed and unsigned
                    case T_VOID:
                        if (baseType != 0) die("2 base types encountered %s and then %s", btyptopp[baseType], btyptopp[B_VOID]);
                        baseType = B_VOID;
                        break;
                    case T_CHAR:
                        if (baseType != 0) die("2 base types encountered %s and then %s", btyptopp[baseType], btyptopp[B_CHAR]);
                        baseType = B_CHAR;
                        break;
                    case T_SHORT:
                        if (baseType != 0) die("2 base types encountered %s and then %s", btyptopp[baseType], btyptopp[B_I16]);
                        baseType = B_I16;
                        break;
                    case T_INT:
                        if (baseType != 0) die("2 base types encountered %s and then %s", btyptopp[baseType], btyptopp[B_I32]);
                        baseType = B_I32;
                        break;
                    case T_LONG:
                        if (baseType != 0) die("2 base types encountered %s and then %s", btyptopp[baseType], btyptopp[B_I64]);
                        baseType = B_I64;
                        break;
                    case T_FLOAT:
                        if (baseType != 0) die("2 base types encountered %s and then %s", btyptopp[baseType], btyptopp[B_F32]);
                        baseType = B_F32;
                        break;
                    case T_DOUBLE:
                        if (baseType != 0) die("2 base types encountered %s and then %s", btyptopp[baseType], btyptopp[B_F64]);
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
                n = n->r;
                break;

            case pt_type_qualifier:
                switch (op) {
                    default:  // T_RESTRICT, T_VOLATILE
                        nyi("op == %s @ %d", toktopp[op], __LINE__);
                    case T_CONST:
                        if (hasConst) die("const already encountered");
                        hasConst = 1;
                        n = n->r;
                        break;
                }
                break;

            case pt_function_specifier:
                if (op != T_INLINE) die("op != T_INLINE");
                nyi("pt_function_specifier");
                break;

            default:
                die("here");

        }
    }
    if (hasSigned) {
        switch (baseType) {
            case B_CHAR:
                return baseType = B_I8;
                break;
            case B_I16:
                baseType = B_I16;
                break;
            case 0:
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
            case B_CHAR:
                return baseType = B_U8;
                break;
            case B_I16:
                baseType = B_U16;
                break;
            case 0:
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


NameType * ptparametertypelistToParameters(Node * ptl) {
    NameType *start=0, *next, *prior=0;  Node *pd, *ds, *d, *id;  int is_array = 0;  enum btyp t;
    if (!ptl) return NULL;
    for (; ptl; next->btyp=t, ptl=ptl->r, prior=next) {
        next = allocInBuckets(&nodes, sizeof (NameType), alignof (NameType));
        if (!start) start = next;
        if (prior) prior->next = next;
        assertTok(ptl, "ptl", pt_parameter_type_list, __LINE__);
        assertExists((pd=ptl->l), "ptl->l", __LINE__);
        switch (pd->tok) {
            case pt_parameter_declaration:
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
                if (ptdeclarationspecifiersForExtern(ds)) die("illegal extern in parameter list");
                t = pointerise(t, d->l, is_array);
                break;
            case T_ELLIPSIS:
                nyi("ELLIPSIS @ %d", __LINE__);
                break;
            default:
                bug("ptparametertypelistToParameters @ %d", __LINE__);
        }
        assertTok(pd, "pd", pt_parameter_declaration, __LINE__);

    }
    return start;
}

int argNumOfEllipsis(Node *fd) {
    Node *ptl, *pd;  int i = 1;
    globals[next_oglo].i = 0;
    for (ptl = fd->r; ptl; ptl = ptl->r, i++) {
        assertTok(ptl, "fd->r", pt_parameter_type_list, __LINE__);
        assertExists(pd = ptl->l, "ptl->l", __LINE__);
        if (pd->tok == T_ELLIPSIS) {
            globals[next_oglo].i = i;
            break;
        }
        assertTok(pd, "pd", pt_parameter_declaration, __LINE__);
    }
    return i;
}

void process_function_definition(Node *ds, Node *d, Node* cs) {
    NameType *params = 0, *p;  enum btyp tRet;  char *fnname;  int oglo;
    PP(emit, "process_function_definition");
    assertTok(ds, "ds", pt_declaration_specifiers, __LINE__);
    assertTok(d, "d", pt_declarator, __LINE__);
    tRet = ptdeclarationspecifiersToBTypeId(ds);
    if (ptdeclarationspecifiersForExtern(ds)) die("illegal extern in function definition");
    tRet = pointerise(tRet, d->l, 0);
    assertTok(d->r, "d->r", func_def, __LINE__);
    assertExists(d->r->l, "d->r->l", __LINE__);
    assertTok(d->r->l, "d->r->l", IDENT, __LINE__);
    if (d->r->r) {
        assertTok(d->r->r, "d->r->r", pt_parameter_type_list, __LINE__);
        params = ptparametertypelistToParameters(d->r->r);
    }
    fnname = d->r->l->s.u.v;

    oglo = reserve_oglo();
    globals[oglo].styp = Fn;
    globals[oglo].i = argNumOfEllipsis(d->r);;
    globals[oglo].btyp = FUNC(tRet);
    globals[oglo].u.v = fnname;
    symadd(fnname, oglo, FUNC(tRet));
    for (p=params; p; p = p->next)
        symadd(p->name, 0, p->btyp);

    emitfunc(tRet, fnname, params, cs);
    symclr();
    tmp_seed = TMP_START;
}

Node * parseInitDeclPt(Node *id, enum btyp baseType, int isExtern) {
    Node *d, *decl, *fd, *d2;  char *name;  enum btyp btyp, btypFn;  int isPtrToFn=0;
    assertTok(id, "id", pt_init_declarator, __LINE__);
    assertExists(d = id->l, "d", __LINE__);
    assertTok(d, "d", pt_declarator, __LINE__);
    assertExists(d->r, "d->r", __LINE__);
    switch (d->r->tok) {

        case IDENT:
            // variable declaration - local or global - optionally with init, not added to symbol table
            // OPEN: handle brackets e.g. int (*p);
            name = d->r->s.u.v;
            btyp = pointerise(baseType, d->l, 0);      // OPEN: handle array
            if (btyp == B_VOID) die("invalid void declaration for %s", name);
            decl = node(DeclVar, d->r, id->r, __LINE__);
            if (isExtern) {
                btyp = BTIntersect(btyp, B_EXTERN);
                decl->s.styp = Ext;     // will be added to globals later
            }
            else
                decl->s.styp = Var;     // changed later to Glo if it turns out that declaration is global
            decl->s.btyp = btyp;
            decl->s.u.v = name;
            symadd(name, 0, btyp);
            return decl;

        case func_def:
            // function declaration - can only be global so is added to symbol table
            fd = d->r;
            if (fd->l->tok == pt_LP_declarator_RP) {
                // OPEN: for mo just catch pointer to function, parse properly later
                assertMissing(fd->l->r, "fd->l->r", __LINE__);
                assertExists(fd->l->l, "fd->l->l", __LINE__);
                assertTok(d2=fd->l->l, "fd->l->l", pt_declarator, __LINE__);
                assertExists(d2->l, "d2->l", __LINE__);
                assertExists(d2->r, "d2->r", __LINE__);
                assertTok(d2->l, "d2->l", pt_pointer, __LINE__);
                assertTok(d2->r, "d2->r", IDENT, __LINE__);
                name = d2->r->s.u.v;
                isPtrToFn = 1;
            }
            else {
                name = fd->l->s.u.v;
            }
            btyp = pointerise(baseType, d->l, 0);      // OPEN: handle array, e.g. char *[] fred();
            btypFn = FUNC(btyp);
            if (isExtern) {
                btypFn = BTIntersect(btypFn, B_EXTERN);
                globals[next_oglo].styp = Ext;
            }
            else if (isPtrToFn) {
                btypFn = IDIR(btypFn);
                globals[next_oglo].styp = Glo;
            }
            else
                globals[next_oglo].styp = Fn;
            globals[next_oglo].btyp = btypFn;
            globals[next_oglo].u.v = name;
            globals[next_oglo].i = argNumOfEllipsis(fd);
            symadd(name, reserve_oglo(), btypFn);
            return 0;

        default:
            bug(MINC_MINC99_Y ">>parseInitDeclPt @ %d", __LINE__);
            return 0;
    }
}


void process_external_declaration(Node *decls) {
    PP(emit, "process_external_declaration");
    Node * decl;
    if (!decls) return;
    assertTok(decls, "decls", DeclVars, __LINE__);
    for (; decls; decls=decls->r) {
        decl = decls->l;
        globals[next_oglo].styp = (decl->s.styp == Var) ? Glo : decl->s.styp;
        globals[next_oglo].btyp = decl->s.btyp;
        globals[next_oglo].u.v = decl->s.u.v;
        symset(decl->s.u.v, reserve_oglo(), decl->s.btyp);
    }
}


Node * mkDeclarations(Node *ds, Node *idl, int lineno) {
    enum btyp baseType;  Node *start=0, *next, *current, *id, *decl;  int isExtern=0;
    assertTok(ds, "ds", pt_declaration_specifiers, __LINE__);
    baseType = ptdeclarationspecifiersToBTypeId(ds);
    isExtern = ptdeclarationspecifiersForExtern(ds);
    assertTok(idl, "idl", pt_init_declarator_list, __LINE__);
    for (; idl; idl=idl->r) {
        assertTok(idl, "idl", pt_init_declarator_list, __LINE__);
        assertExists(id=idl->l, "id", __LINE__);
        if (decl=parseInitDeclPt(id, baseType, isExtern)) {
            next = node(DeclVars, decl, 0, lineno);
            if (!start) current = start = next;
            else {
                current->r = next;
                current = next;
            }
        }
    }
    return start;
}


/*End of C declarations*/
%}


%union {
    Node *n;
//    TLLHead *t;
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
| postfix_expression '.' IDENTIFIER                     { nyi("@ %d", $%); }  // OP_ATR
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

unary_operator                                          // LHS is completed in unary_operator cast_expression   =>   unary_expression
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
| logical_and_expression AND_OP inclusive_or_expression { $$ = node(OP_AND, $1, $3, $%); }
;

logical_or_expression
: logical_and_expression                                { $$ = $1; }
| logical_or_expression OR_OP logical_and_expression    { $$ = node(OP_OR, $1, $3, $%); }
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

declaration
: declaration_specifiers ';'                            { nyi("declaration_specifiers ';'   =>   declaration"); }
| declaration_specifiers init_declarator_list ';'       { PP(pt, "declaration_specifiers init_declarator_list ';'  =>  declaration"); $$ = mkDeclarations($1, $2, $%); }
;

// reverse of init_declarator_list
declaration_specifiers
: storage_class_specifier                               { PP(pt, "storage_class_specifier   =>   declaration_specifiers"); $$ = node(pt_declaration_specifiers, $1, 0, $%); }
| storage_class_specifier declaration_specifiers        { PP(pt, "storage_class_specifier declaration_specifiers   =>   declaration_specifiers"); $$ = node(pt_declaration_specifiers, $1, $2, $%); }
| type_specifier                                        { PP(pt, "%s - type_specifier   =>   declaration_specifiers", toktopp[$1->tok]); $$ = node(pt_declaration_specifiers, $1, 0, $%); }
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
: TYPEDEF                                               { PP(pt, "TYPEDEF  =>  storage_class_specifier"); $$ = mktype(pt_storage_class_specifier, (enum btyp) T_TYPEDEF, $%); }
| EXTERN                                                { PP(pt, "EXTERN  =>  storage_class_specifier"); $$ = mktype(pt_storage_class_specifier, (enum btyp) T_EXTERN, $%); }
| STATIC                                                { PP(pt, "STATIC  =>  storage_class_specifier"); $$ = mktype(pt_storage_class_specifier, (enum btyp) T_STATIC, $%); }
| AUTO                                                  { PP(pt, "AUTO  =>  storage_class_specifier"); $$ = mktype(pt_storage_class_specifier, (enum btyp) T_AUTO, $%); }
| REGISTER                                              { PP(pt, "REGISTER  =>  storage_class_specifier"); $$ = mktype(pt_storage_class_specifier, (enum btyp) T_REGISTER, $%); }
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
| '(' declarator ')'                                                            { $$ = nodepp(pt_LP_declarator_RP, $2, 0, $%, pt, "'(' declarator ')'   =>   direct_declarator");}
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
| designation initializer                               { nyi("@ %d", $%); }
| initializer_list ',' initializer                      { nyi("@ %d", $%); }
| initializer_list ',' designation initializer          { nyi("@ %d", $%); }
;

designation
: designator_list '='                                   { nyi("@ %d", $%); }
;

designator_list
: designator                                            { nyi("@ %d", $%); }
| designator_list designator                            { nyi("@ %d", $%); }
;

designator
: '[' constant_expression ']'                           { nyi("@ %d", $%); }
| '.' IDENTIFIER                                        { nyi("@ %d", $%); }
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
: WHILE '(' expression ')' statement                                    { PP(pt, "WHILE '(' expression ')' statement "); $$ = node(While, $3, $5, $%); }
| DO statement WHILE '(' expression ')' ';'                             { PP(pt, "DO statement WHILE '(' expression ')' ';'"); $$ = node(While, $5, $2, $%); }
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
: function_definition                                   // handled in the function_definition rule
| declaration                                           { PP(pt, "declaration   =>   external_declaration"); process_external_declaration($1); }
;

function_definition
: declaration_specifiers declarator declaration_list compound_statement     { PP(pt, "declaration_specifiers declarator declaration_list compound_statement   =>   function_definition"); process_function_definition($1, $2, $4); }  // declarations are already captured so declaration list can be ignored
| declaration_specifiers declarator compound_statement                      { PP(pt, "declaration_specifiers declarator compound_statement   =>   function_definition"); process_function_definition($1, $2, $3); }
;

declaration_list
: declaration
| declaration_list declaration                          { $$ = node(Seq, $1, $2, $%); }
;

%%


struct {
    char *s;
    int yacct;
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
            yylval.n->s.btyp = B_I64;
            PP(lex, "%d ", n);
            return CONSTANT;
        }
    }

    if (isalpha(c) || c == '_') {
        p = v;  n = 0;
        do {
            if (p == &v[SYM_NAME_MAX-1]) die("identifier is too long");
            *p++ = c;  n++;
            c = getc(inf);
        } while (isalnum(c) || c == '_');
        *p = 0;  n++;
        ungetc(c, inf);
        for (i=0; kwds[i].s; i++)
            if (strcmp(v, kwds[i].s) == 0)
                return kwds[i].yacct;
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
        yylval.n->s.btyp = B_CHAR;
        c = getc(inf);
        if (c != '\'') nyi("only single char literal supported");
        return CONSTANT;
    }

    if (c == '"') {
        i = 0;
        n = 32;
        p = allocInBuckets(&all_strings, n, 1);     // OPEN use reallocInBuckets rather than tracking buffersize ourselves?
        for (i=0;; i++) {
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
                        p[i] = 0;
                        ungetc(c2, inf);
                        break;
                    }
                    else
                        i--;
                }
            }
        }
        // OPEN: reallocate p to the correct size
        // OPEN: reuse strings?
        if (next_oglo == NGlo) die("too many globals");
        // store the char * in the globals for emission later on, OPEN: add a strings array
        globals[next_oglo].styp = Str;
        globals[next_oglo].btyp = B_CHAR_STAR;
        globals[next_oglo].u.v = p;
        globals[next_oglo].i = next_str;
        // keep the id of the string on the LIT_STR node
        yylval.n = node(LIT_STR, 0, 0, __LINE__);
        yylval.n->s.btyp = B_CHAR_STAR;
        yylval.n->s.i = next_str;
        reserve_str();
        reserve_oglo();
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

// OPEN: refactor this so globals and ir emission are not complected
void emitglobals() {
    enum btyp btyp;  int isExtern;  int emitGloHeader = 1, emitStrHeader = 1;
    for (int oglo = 0; oglo < next_oglo; oglo++) {
        btyp = globals[oglo].btyp;
        isExtern = fitsWithin(btyp, B_EXTERN);
        // OPEN: add alignment and maybe use z to init the memory to 0
        if (globals[oglo].styp == Glo && !isExtern) {
            if (emitGloHeader) {
                putq("\n# GLOBAL VARIABLES\n");
                emitGloHeader = 0;
            }
            putq("data " GLOBAL "%s = { %c 0 }\n", globals[oglo].u.v, regtyp(btyp));
        }
    }
    for (int oglo = 0; oglo < next_oglo; oglo++)
        if ((globals[oglo].styp == Str) && (globals[oglo].btyp == B_CHAR_STAR)) {
            if (emitStrHeader) {
                putq("\n# STRING CONSTANTS\n");
                emitStrHeader = 0;
            }
            putq("data " STRING "%d = { b \"%s\", b 0 }\n", globals[oglo].i, globals[oglo].u.v);
        }
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
    emitglobals();
    freeBuckets(all_strings.first_bucket);
    freeBuckets(nodes.first_bucket);

    return EXIT_SUCCESS;
}



