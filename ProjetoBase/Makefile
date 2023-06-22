 # -------------------------------------------------------------------
 #            Arquivo: Makefile
 # -------------------------------------------------------------------
 #              Autor: Bruno Müller Junior
 #               Data: 08/2007
 #      Atualizado em: [09/08/2020, 19h:01m]
 #
 # -------------------------------------------------------------------

$DEPURA=1

compilador: lex.yy.c compilador.tab.c compilador.o compilador.h simbolo.o tabelaSimbolo.o pilha.o
	gcc lex.yy.c compilador.tab.c compilador.o simbolo.o tabelaSimbolo.o pilha.o -o compilador -lfl -L /usr/lib/x86_64-linux-gnu -ly -lc

lex.yy.c: compilador.l compilador.h
	flex compilador.l

compilador.tab.c: compilador.y compilador.h
	bison compilador.y -d -v

compilador.o : compilador.h compiladorF.c
	gcc -c compiladorF.c -o compilador.o

pilha.o: Pilha/pilha.c
	make -C Pilha

tabelaSimbolo.o: TabelaSimbolos/tabelaSimbolo.c
	make -C TabelaSimbolos

simbolo.o: TabelaSimbolos/simbolo.c
	make -C TabelaSimbolos

clean :
	rm -f compilador.tab.* lex.yy.c compilador.o compilador
