BIN = ../minc

CFLAGS += -g -Wall

$(BIN): yacc minc.y
	./yacc minc.y
	$(CC) $(CFLAGS) -o $@ y.tab.c

clean:
	rm -f yacc minc y.*

.PHONY: clean
