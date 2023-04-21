# minc
A minimal C compiler with a QBE backend (based on minic)

Starting with minic I moved much of the c code in from the yacc section into the C section, handled line 
comments, defined some constants for ops, and generally tidied up a bit.

Next I took the yacc grammar from https://www.quut.com/c/ANSI-C-grammar-y-1999.html (C99), adding the lexer 
and helper fucntions from above. Overall the intention here is to implement enough C to handle my needs - 
principally to develop my understanding of how to generate QBE IR. I can then use minc99 generated IR in bones, 
e.g. for common libraries, or as a sanity check the bones IR emmision. Another possibility may be to make a 
minc99 dynamic library to use in Python as part of a JIT. However that would need propper memory management 
and other stuff.


https://c9x.me/compile/ \
https://c9x.me/yacc/ \
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
