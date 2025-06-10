// ---------------------------------------------------------------------------------------------------------------------
// Copyright 2025 David Briant, https://github.com/coppertop-bones. Licensed under the Apache License, Version 2.0
// ---------------------------------------------------------------------------------------------------------------------

#ifndef SRC_MC99_LEX_C
#define SRC_MC99_LEX_C "mc99/lex.c"


#include "y.tab.c"



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



#endif  // SRC_MC99_LEX_C
