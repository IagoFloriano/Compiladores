#include "simbolo.h"
#include "tabelaSimbolo.h"
#include <stdio.h>

void printSimbolo(simbolo s){
  char *tipos[] = {"PROC", "VAR", "PARAM"};
  //    ident  tipo  infos
  printf("%s\t%s\t",s.identificador,
      tipos[s.tipo_simbolo]);

  char *tiposVar[] = {"erro","int","bool"};
  switch(s.tipo_simbolo){
    case variavel:
      printf("%2d, %2d, %s\n",
          s.nivel_lexico, s.conteudo.var.deslocamento, tiposVar[s.conteudo.var.tipo]);
      break;
    case procedimento:
      break;
    case parametro:
      printf("%2d, %2d, %s, %s\n",
          s.nivel_lexico, s.conteudo.par.deslocamento, tiposVar[s.conteudo.par.tipo],
          s.conteudo.par.tipo_passagem ? "vlr" : "ref");
      break;
    default:
      printf("ERRO\n");
  }
}

int main(){
  t_conteudo c;
  c.var.deslocamento = 3;
  c.var.tipo = integer_pas;
  c.par.tipo_passagem = valor_par;
  simbolo s = criaSimbolo("teste", parametro, 0, c);
  tabela t;
  inicializa(&t);
  push(&t, s);

  printSimbolo(s);
  return 0;
}
