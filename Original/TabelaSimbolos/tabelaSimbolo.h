#ifndef __TABELA_SIMBOLO__
#define __TABELA_SIMBOLO__

#include "simbolo.h"

typedef struct tabela {
  int tam;
  int topo;
  simb *pilha;
} tabela;

void inicializa(tabela *t);

void push(tabela *t, simb s);

simb pop(tabela *t);

void removeN(tabela *t, int n);

simb *busca(tabela *t, char *ident);

void atribuiTipo(tabela *t, int tipo, int num);

void removeAte(tabela *t, int nvLex);


#endif // __TABELA_SIMBOLO__