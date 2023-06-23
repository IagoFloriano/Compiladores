#include <string.h>
#include <stdlib.h>
#include "simbolo.h"

simb criaSimbolo(char *ident, int tipo_simbolo, int nivel, t_conteudo cont){
  simb s;
  s.identificador = malloc(strlen(ident) + 1);
  strcpy(s.identificador, ident);

  s.tipo_simbolo = tipo_simbolo;
  s.nivel_lexico = nivel;
  s.conteudo = cont;
  return s;
}