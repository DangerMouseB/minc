BIN = ../minc11

CFLAGS += -g -Wall

$(BIN): ../src99/yacc minc11.y
	./yacc minc11.y
	$(CC) $(CFLAGS) -o $@ y.tab.c

clean:
	rm -f yacc minc11 y.*

.PHONY: clean
