
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"

int num_vars;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR NUMERO IDENT ATRIBUICAO
%token LABEL TYPE ARRAY PROCEDURE FUNCTION
%token GOTO IF THEN ELSE WHILE DO
%token OR DIV AND NOT OF VEZES
%token MAIOR MAIOR_IGUAL MENOR MENOR_IGUAL DIFERENTE IGUAL

%%

// REGRA 01
programa    :{
             geraCodigo (NULL, "INPP");
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
parte_declara_vars:  var
;


var         : { } VAR declara_vars
            |
;

// REGRA 09
declara_vars: declara_vars declara_var
            | declara_var
;

declara_var : { }
              lista_id_var DOIS_PONTOS
              tipo
              { /* AMEM */
              }
              PONTO_E_VIRGULA
;

tipo        : IDENT
;

lista_id_var: lista_id_var VIRGULA IDENT
              { /* insere ultima vars na tabela de simbolos */ }
            | IDENT { /* insere vars na tabela de simbolos */}
;

// REGRA 10
lista_idents: lista_idents VIRGULA IDENT
            | IDENT
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
