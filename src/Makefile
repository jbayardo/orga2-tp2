# ************************************************************************* #
# Organizacion del Computador II                                            #
#                                                                           #
#   Trabajo Practico 2                                                      #
#                                                                           #
# ************************************************************************* #

all: makes tp2

CFLAGS=-Wall -Wextra -pedantic -O0 -ggdb -lm -std=c99

makes:
	make -C bmp
	make -C tools
	make -C filters
	make -C tests

%.o: %.c run.h
	gcc $(CFLAGS) -c -o $@ $<

tp2: run.o tp2.o makes
	gcc $(CFLAGS) tp2.o run.o filters/*.o bmp/*.o -o tp2 -lm
	cp tp2 ../bin/

clean:
	make -C bmp clean
	make -C tools clean
	make -C filters clean
	make -C tests clean
	rm  -f *.o tp2
