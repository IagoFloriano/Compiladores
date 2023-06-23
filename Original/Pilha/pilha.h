#ifndef __PILHA__
#define __PILHA__

#define PILHA_TAM_INCREMENTO 1024
#define PILHA_MAX_TAM_STRING 32

typedef struct pilha {
    unsigned int topo;
    unsigned int tam;
    int *p;
} pilha;

void pilha_init(pilha *p);

void pilha_push(pilha *p, const int num);

void pilha_pop(pilha *p);

int pilha_topo(pilha *p);

int pilha_vazia(pilha *p);

void pilha_destroi(pilha *p);

#endif