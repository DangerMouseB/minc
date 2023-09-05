BIN = ../_minc99
INC = -I../bk/include -I../bk/src
#SRC_DIR = ../bk/src

CFLAGS += -g -Wall $(INC)

$(BIN): yacc minc99.y
	./yacc minc99.y
	$(CC) $(CFLAGS) -o $@ y.tab.c

clean:
	rm -f yacc minc99 y.*

.PHONY: clean
