
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "TabelaSimbolos/simbolo.h"
#include "TabelaSimbolos/tabelaSimbolo.h"


char mepaTemp[256];
int num_vars;
int qtTipoAtual;
int tipoAtual;
int nivelLexico;
simb simboloTemp;
t_conteudo conteudoTemp;
tabela t;

int strToType(const char *str){
  if (!strcmp(str, "integer")) return integer_pas;
  if (!strcmp(str, "boolean")) return boolean_pas;
  return indefinido_pas;
}

void printSimbolo(simb s, int tablevel){
  for(int i = 0; i < tablevel; i++){printf("\t");}
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

void printTabela(tabela t){
  for(int i = t.topo; i >= 0; i--){
    printSimbolo(t.pilha[i], 1);
  }
}
%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR NUMERO IDENT ATRIBUICAO
%token LABEL TYPE ARRAY PROCEDURE FUNCTION
%token GOTO IF THEN ELSE WHILE DO
%token OR DIV AND NOT OF VEZES
%token MAIOR MAIOR_IGUAL MENOR MENOR_IGUAL DIFERENTE IGUAL

// %union{
//    char *str;  // define o tipo str
//    int int_val; // define o tipo int_val
//    simb *simbPtr;
// }

// %type <int_val> tipo;

%%

// REGRA 01
programa    :{
             geraCodigo (NULL, "INPP");
             inicializa(&t);
             nivelLexico = 0;
             }
             PROGRAM IDENT
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
             bloco PONTO {
             geraCodigo (NULL, "PARA");
             }
;

// REGRA 02
bloco       :
              parte_declara_vars
              {
              }

              comando_composto
              ;

// REGRA 08
parte_declara_vars: {
                  num_vars = 0;
                  } VAR declara_vars {
                    sprintf(mepaTemp, "AMEM %d", num_vars);
                    geraCodigo(NULL, mepaTemp);
                  }
                  | {printf("sem vars");}
;

// REGRA 09
declara_vars: declara_vars declara_var
            | declara_var
;

declara_var : {}
              lista_id_var DOIS_PONTOS
              tipo
              {
              }
              PONTO_E_VIRGULA
;

tipo        : IDENT {
            atribuiTipo(&t, strToType(token), qtTipoAtual);
            printTabela(t);
            qtTipoAtual = 0;
            }
;


// REGRA 10
lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;

lista_id_var: lista_id_var VIRGULA var
            | var
;

var: IDENT  {
   conteudoTemp.var.deslocamento = num_vars;
   simboloTemp = criaSimbolo(token, variavel, nivelLexico, conteudoTemp);
   push(&t, simboloTemp);
   qtTipoAtual++;
   num_vars++;
   }
;

// REGRA 16
comando_composto: T_BEGIN comandos T_END

comandos: comandos PONTO_E_VIRGULA comando
        | comando
;

// REGRA 17
comando: NUMERO DOIS_PONTOS comando_sem_rotulo
       | comando_sem_rotulo
;

// REGRA 18
comando_sem_rotulo:

;

// REGRA 24
lista_de_expressoes: lista_de_expressoes VIRGULA {/* num_params++ */} expressao
                   | expressao
;

// REGRA 25
expressao: expressao_simples
         | expressao_simples relacao expressao_simples
            {
               /* testa se é possível comparar as duas expressoes */
            }
;

// REGRA 26
relacao: IGUAL
         { }
       | DIFERENTE
         { }  
       | MENOR
         { }
       | MENOR_IGUAL
         { }
       | MAIOR
         { }
       | MAIOR_IGUAL
         { }
;

// REGRA 27
expressao_simples:
;

// REGRA 28
termo: fator vezes_div_or fator
         {

         }
     | fator
;

vezes_div_or: VEZES {}
            | DIV {}
            | OR {}
;

// REGRA 29
/* ta errado essa */
fator: variavel
     | NUMERO
     | chamada_func
     | ABRE_PARENTESES expressao FECHA_PARENTESES
     | NOT fator
;

// REGRA 30
variavel: IDENT
        | IDENT lista_de_expressoes
;

// REGRA 31
chamada_func:
;

%%

int main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc<2 || argc>2) {
         printf("usage compilador <arq>a %d\n", argc);
         return(-1);
      }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compilador <arq>b\n");
      return(-1);
   }


/* -------------------------------------------------------------------
 *  Inicia a Tabela de S�mbolos
 * ------------------------------------------------------------------- */

   yyin=fp;
   yyparse();

   return 0;
}
