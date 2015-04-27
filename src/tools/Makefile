# ************************************************************************* #
# Organizacion del Computador II                                            #
#                                                                           #
#   Trabajo Practico 2                                                      #
#                                                                           #
# ************************************************************************* #

all: diff pixeldump

CFLAGS=-Wall -Wextra -pedantic -O0 -ggdb -lm -std=c99

diff: diff.c ../bmp/bmp.o
	gcc $(CFLAGS) diff.c ../bmp/bmp.o -o diff
	cp diff ../../bin/
	
pixeldump: pixeldump.c ../bmp/bmp.o
	gcc $(CFLAGS) pixeldump.c ../bmp/bmp.o -o pixeldump
	cp pixeldump ../../bin/

clean:
	rm  -f *.o diff