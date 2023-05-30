#include <string.h>
#include <stdlib.h>
#include "simbolo.h"
#include "tabelaSimbolo.h"

void inicializa(tabela *t){
  t->tam = 1;
  t->topo = -1;
  t->pilha = malloc(sizeof(simbolo) * 1);
}

void push(tabela *t, simbolo s){
  if (!t) return;
  if (t->topo + 2 >= t->tam){
    t->pilha = realloc(t->pilha, sizeof(simbolo) * (t->tam << 1));
    t->tam = t-> tam << 1;
  }
  t->pilha[++(t->topo)] = s;
}

simbolo pop(tabela *t){
  //if (!t || t->topo < 0) return;

  simbolo s = t->pilha[t->topo--];
  return s;
}

void removeN(tabela *t, int n){
}

simbolo *busca(tabela *t, char *ident){
  return NULL;
}

void atribuiTipo(tabela *t, int tipo, int num){
}
