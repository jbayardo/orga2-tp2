all: generate runTests

CFLAGS=-Wall -Wextra -pedantic -ggdb -lm -std=c99

%.o: %.c bmp.h
	gcc $(CFLAGS) -c -o $@ $<

generate: generateImages.c
	gcc $(CFLAGS) generateImages.c ../bmp/bmp.o -o generate
	cp generate ../../exp/

runTests: runTests.c
	gcc $(CFLAGS) runTests.c ../filters/*.o ../bmp/bmp.o -o runTests -lm
	cp runTests ../../exp/

clean:
	rm  -f *.o generate runTests



o0:
	CFLAGS+=-O0
	make all
	
o3:
	CFLAGS+=-O3
	make all

o3fast:
	CFLAGS+=-O3 -ffast-math
	make all

shuffle:
	make all
	
shifts:
	cd ../filters/ &&	mv ASM_hsl2.asm ASM_hsl2.asm.bk &&	mv ASM_hsl2_shifts.asm ASM_hsl2.asm
	make all
	cd ../filters/ &&	mv ASM_hsl2.asm ASM_hsl2_shifts.asm &&	mv ASM_hsl2.asm.bk ASM_hsl2.asm


