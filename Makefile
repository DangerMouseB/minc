# MAKE CHEATSHEET
# see
#	https://makefiletutorial.com/
# 	https://github.com/vampy/Makefile
#
# why make? "make is the only build system with more pros than cons"
# Makefiles must be indented using TABs and not spaces or make will fail.
#
# syntax
# targets: prerequisites
#	command
#
#
# Reference variables using either ${} or $()


MINIYACC_BIN = bin/_my
MC99_BIN = bin/_mc99
CFLAGS += -g -Wall


$(MC99_BIN) : $(MINIYACC_BIN) src/mc99/mc99.y
	$(MINIYACC_BIN) src/mc99/mc99.y
	mv y.tab.c src/mc99/y.tab.c
#	$(CC) $(CFLAGS) -o $@ src/mc99/y.tab.c



clean:
	rm -f yacc src/mc99 y.*

.PHONY: clean
