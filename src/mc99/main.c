// ---------------------------------------------------------------------------------------------------------------------
// Copyright 2025 David Briant, https://github.com/coppertop-bones. Licensed under the Apache License, Version 2.0
// ---------------------------------------------------------------------------------------------------------------------

#include <unistd.h>
#include "lex.c"



void emitglobals() {
    btypeid_t btyp;  int isExtern;  int emitGloHeader = 1, emitStrHeader = 1;
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


pvt void die_(char const *preamble, char const *msg, va_list args) {
    fprintf(stderr, "\nbefore end of line %d: ", isrcline);
    fprintf(stderr, "%s", preamble);
    vfprintf(stderr, msg, args);
    fprintf(stderr, "\nin %s\n\n", srcFfn);
    // OPEN: use setjmp and longjmp with deallocation of linked list of arenas
    exit(1);
}


int main(int argc, char const *argv[]) {
    int res;  char cwd[PATH_MAX];  char const *ffn;  FILE *f;

    if (argc == 2) {
        ffn = argv[1];
        f = fopen(ffn, "r");
        if (!f) {
            getcwd(cwd, sizeof(cwd));
            PP(error, "Error opening file - %s/%s", cwd, ffn);
            return EXIT_FAILURE;
        }
        inf = f;
        strcpy(srcFfn, ffn);
    } else {
        PP(info, "no file specified");
        return EXIT_FAILURE;
    }

    g_logging_level = parse | emit | error | pt | lex;
    of = stdout;

    mm = MM_create();
    Buckets_init(&kbuckets, BUCKETS_CHUNK_SIZE);
    kernel = K_create(mm, &kbuckets);

    Buckets_init(&all_strings, BUCKETS_CHUNK_SIZE);
    Buckets_init(&nodes, BUCKETS_CHUNK_SIZE);

    res = yyparse();
    if (res) die("parse error (%d)", res);
    emitglobals();
    Buckets_finalise(&all_strings);
    Buckets_finalise(&nodes);

    mm = kernel->mm;
    Buckets_finalise(&kbuckets);
    res = K_trash(kernel);
    if (res) PP(error, "%s: K_trash failed", FN_NAME);
    res = MM_trash(mm);
    if (res) PP(error, "%s: MM_trash failed", FN_NAME);

    return EXIT_SUCCESS;
}

