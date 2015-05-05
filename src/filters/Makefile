# ************************************************************************* #
# Organizacion del Computador II                                            #
#                                                                           #
#   Trabajo Practico 2                                                      #
#                                                                           #
# ************************************************************************* #

all: C_blur.o ASM_blur1.o ASM_blur2.o C_merge.o ASM_merge1.o ASM_merge2.o C_hsl.o ASM_hsl1.o ASM_hsl2.o filter_toX.o aux.o

CFLAGS=-Wall -Wextra -pedantic -ggdb -lm -std=c99
NASMFLAGS=-f elf64 -ggdb -F DWARF

%.o: %.c filters.h
	gcc $(CFLAGS) -c -o $@ $<

%.o: %.asm
	nasm $(NASMFLAGS) -o $@ $<

o0: CFLAGS += -O0
o0: all
	
o3: CFLAGS += -O3
o3: all

o3fast: CFLAGS += (-O3 -ffast-math)
o3fast:  all

shuffle: all
	
shifts:
	mv ASM_hsl2.asm ASM_hsl2.asm.bk &&	mv ASM_hsl2_shifts.asm ASM_hsl2.asm
	make all
	mv ASM_hsl2.asm ASM_hsl2_shifts.asm &&	mv ASM_hsl2.asm.bk ASM_hsl2.asm



clean:
	rm  -f *.o
