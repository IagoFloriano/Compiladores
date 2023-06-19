#include <string.h>
#include <stdlib.h>
#include "simbolo.h"
#include "tabelaSimbolo.h"

void inicializa(tabela *t){
  t->tam = 1;
  t->topo = -1;
  t->pilha = malloc(sizeof(simb) * 1);
}

void push(tabela *t, simb s){
  if (!t) return;
  if (t->topo + 2 >= t->tam){
    t->pilha = realloc(t->pilha, sizeof(simb) * (t->tam << 1));
    t->tam = t-> tam << 1;
  }
  t->pilha[++(t->topo)] = s;
}

simb pop(tabela *t){
  simb s = t->pilha[t->topo--];
  return s;
}

void removeN(tabela *t, int n){
  t->topo -= n;
}

simb *busca(tabela *t, char *ident){
  if (!t) return NULL;
  simb *s = NULL;
  for (int i = t->topo; i >= 0; i--){
    if (!strcmp(ident, t->pilha[i].identificador)){
      s = &(t->pilha[i]);
      break;
    }
  }
  return s;
}

void atribuiTipo(tabela *t, int tipo, int num){
  for (int i = t->topo; i > t->topo - num; i--){
    t->pilha[i].conteudo.var.tipo = tipo;
    // funciona por conteudo ser union
  }
}
