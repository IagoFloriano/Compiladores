DEBUG_FLAGS = -g -DDEBUG
CFLAGS = -Wall -lm
EXE = teste

#------------------------------------------------------------------------------
.PHONY : all clean

#------------------------------------------------------------------------------
all : pilha.o

debug: CFLAGS += $(DEBUG_FLAGS)
debug: all

pilha.o: pilha.c pilha.h
	gcc $(CFLAGS) -c pilha.c
	cp pilha.o ../

#------------------------------------------------------------------------------
clean :
	$(RM) *.o
