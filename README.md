# minc
A minimal C compiler with a QBE backend (based on minic by Quentin Carbonneaux)

- uses c99 grammar from https://www.quut.com/c/ANSI-C-grammar-y-1999.html
- added line numbers and comments to miniyacc - https://c9x.me/yacc/
- added extern linkage keyword to QBE and macos aarch64 abi features to link to GOT
- added buckets memory management
- adding bone type system - initial for the front end, maybe later as an extension to C

goals:
- learn QBE IR to use in bones
- learn C-ABI (including C++ exception handling)
- learn GAS
- develop components for bones type system, bones vm and a Python in memory compiler (the most basic form of JIT),
  - code generation
  - memory management
  - type system
  - multidispatch
  - exception handling
  - debugging

next:
- sort extension and promotion
- clean code gen
- add intersections and api
- add nominals and move fully to bones types
- add <: .... > to lexer and output a TYPE
- type-lang parser (use miniyacc)
- get ... working, e.g.
  //void PP(char *msg, ...) {
  //    va_list args;
  //    va_start(args, msg);
  //    vfprintf(stderr, msg, args);
  //    fprintf(stderr, "\n");
  //    va_end(args);
  //}


references: \
https://c9x.me/compile/ \
https://c9x.me/articles/gthreads/intro.html \
https://github.com/DoctorWkt/acwj \
https://docs.python.org/3/library/ctypes.html \
https://developers.redhat.com/blog/2021/04/27/the-mir-c-interpreter-and-just-in-time-jit-compiler \
https://git.sr.ht/~mcf/cproc \
https://github.com/michaelforney/cproc

https://www.lysator.liu.se/c/ANSI-C-grammar-y.html

YACC - https://arcb.csc.ncsu.edu/~mueller/codeopt/codeopt00/y_man.pdf \
https://silcnitc.github.io/yacc.html#:~:text=2.1%20Declarations&text=The%20C%20Declarations%20are%20delimited,section%20into%20the%20generated%20y. \
https://github.com/ibara/yacc

https://github.com/ShamithaUdupa/Simple-C-Compiler

https://cdecl.org/




