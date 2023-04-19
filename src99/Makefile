BIN = ../minc99

CFLAGS += -g -Wall

$(BIN): yacc minc99.y
	./yacc minc99.y
	$(CC) $(CFLAGS) -o $@ y.tab.c

clean:
	rm -f yacc minc99 y.*

.PHONY: clean
