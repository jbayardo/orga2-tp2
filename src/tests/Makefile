all: generate runTests

CFLAGS=-Wall -Wextra -pedantic -O0 -ggdb -lm -std=c99

%.o: %.c bmp.h
	gcc $(CFLAGS) -c -o $@ $<

generate: generateImages.c
	gcc $(CFLAGS) generateImages.c ../bmp/bmp.o -o generate

runTests: runTests.c
	gcc $(CFLAGS) runTests.c ../filters/*.o ../bmp/bmp.o -o runTests -lm

clean:
	rm  -f *.o generate runTests