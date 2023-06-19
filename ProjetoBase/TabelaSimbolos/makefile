DEBUG_FLAGS = -g -DDEBUG
CFLAGS = -Wall -lm
EXE = teste

#------------------------------------------------------------------------------
.PHONY : all clean

#------------------------------------------------------------------------------
all : $(EXE)

debug: CFLAGS += $(DEBUG_FLAGS)
debug: all

$(EXE): simbolo.o tabelaSimbolo.o $(EXE).o
	gcc -o $@ $^ $(CFLAGS)
	cp tabelaSimbolo.o ../
	cp simbolo.o ../

%.o: %.c
	gcc $(CFLAGS) -c $^

#------------------------------------------------------------------------------
clean :
	$(RM) *.o

purge : clean
	$(RM) $(EXE)
