# minc
A minimal C compiler with a QBE backend (based on minic)

Starting with minic I moved much of the c code in from the yacc section into the C section, handled line 
comments, defined some constants for ops, and generally tidied up a bit.

Next I took the yacc grammar from https://www.quut.com/c/ANSI-C-grammar-y-1999.html (C99), adding the lexer 
and helper fucntions from above. Overall the intention here is to implement enough C to handle my needs - 
principally to develop my understanding of how to generate QBE IR. I can then use minic99 generated IR in bones, 
e.g. for common libraries, or as a sanity check the bones IR emmision. Another possibility may be to make a 
minic99 dynamic library to use in Python as part of a JIT. However that would need propper memory management 
and other stuff.
