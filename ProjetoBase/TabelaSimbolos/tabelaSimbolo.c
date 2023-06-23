#include <string.h>
#include <stdlib.h>
#include "simbolo.h"
#include "tabelaSimbolo.h"

void inicializa(tabela *t){
  t->tam = 1000;
  t->topo = -1;
  t->pilha = malloc(sizeof(simb) * 1000);
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

void removeAte(tabela *t, int nvLex){
  int q = t->topo;
  while(
      (t->pilha[q].nivel_lexico >= nvLex && t->pilha[q].tipo_simbolo != procedimento)
    ||(t->pilha[q].nivel_lexico > nvLex && t->pilha[q].tipo_simbolo == procedimento) ){
    q--;
  }
  t->topo = q;
}

void atribuiDeslocamento(tabela *t, int quantParam){
  int q = t->topo;
  int currDeslocamento = -4;
  while ( t->pilha[q].tipo_simbolo != procedimento ){
    t->pilha[q].conteudo.par.deslocamento = currDeslocamento;
    currDeslocamento--;
    q--;
  }
  t->pilha[q].conteudo.proc.deslocamento = currDeslocamento;
  t->pilha[q].conteudo.proc.num_parametros = quantParam;
}

simb topo(tabela *t){
  return t->pilha[t->topo];
}

simb *procTopo(tabela *t){
  int q = t->topo;
  while (t->pilha[q].tipo_simbolo != procedimento && q >= 0) q--;
  if (q < 0) return NULL;
  return &(t->pilha[q]);
}
