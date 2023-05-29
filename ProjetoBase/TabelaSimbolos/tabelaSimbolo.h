#ifndef __TABELA_SIMBOLO__
#define __TABELA_SIMBOLO__

#include "simbolo.h"

typedef struct tabela {
  int tam;
  int topo;
  simbolo *pilha;
} tabela;

void inicializa(tabela *t);

void push(tabela *t, simbolo s);

simbolo pop(tabela *t);

void removeN(tabela *t, int n);

simbolo *busca(tabela *t, char *ident);

void atribuiTipo(tabela *t, int tipo, int num);


#endif // __TABELA_SIMBOLO__
