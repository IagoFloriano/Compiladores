
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
simb *simboloPtr;
simb simbAtribuicao;
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
%token OR DIV AND NOT OF VEZES MAIS MENOS
%token MAIOR MAIOR_IGUAL MENOR MENOR_IGUAL DIFERENTE IGUAL
%token ABRE_COLCHETES FECHA_COLCHETES ABRE_CHAVES FECHA_CHAVES

%union{
   char *str;  // define o tipo str
   int int_val; // define o tipo int_val
//    simb *simbPtr;
}

%type <str> vezes_div_and;
%type <str> mais_menos_or;
%type <str> mais_menos_vazio;
%type <str> relacao;
%type <int_val> expressao;
%type <int_val> expressao_simples;
%type <int_val> fator;
%type <int_val> termo;

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
comando_sem_rotulo: atribuicao
                  |

;

// REGRA 19
atribuicao: IDENT { 
            simboloPtr = busca(&t, token);
            if (!simboloPtr) {
              fprintf(stderr, "COMPILATION ERROR!\n Variable %s was not declared.\n"
              , token); 
              exit(1);
            }
            simbAtribuicao = *simboloPtr;
          }
          ATRIBUICAO expressao
          {
            if ($4 != simbAtribuicao.conteudo.var.tipo) {
              fprintf(stderr, "COMPILATION ERROR!\n Atributing wrong type to variable\n");
              exit(1);
            }
            sprintf(mepaTemp, "ARMZ %d %d",
            simbAtribuicao.nivel_lexico, simbAtribuicao.conteudo.var.deslocamento);
            geraCodigo(NULL, mepaTemp);
          }
;

// REGRA 24
lista_de_expressoes: lista_de_expressoes VIRGULA {} expressao
                   | expressao
                   |
;

// REGRA 25
expressao: expressao_simples { $$ = $1; }
         | expressao_simples relacao expressao_simples
            {
            if ($1 != $3 ) {
              fprintf(stderr, "COMPILATION ERROR!\n Cannot compare expressions with diferent types\n");
              exit(1);
            }
            geraCodigo(NULL, $2);
            $$ = boolean_pas;
            }
;

// REGRA 26
relacao: IGUAL       { $$ = "CMIG"; }
       | DIFERENTE   { $$ = "CMDG"; }
       | MENOR       { $$ = "CMME"; }
       | MENOR_IGUAL { $$ = "CMEG"; }
       | MAIOR       { $$ = "CMMA"; }
       | MAIOR_IGUAL { $$ = "CMAG"; }
;

// REGRA 27
expressao_simples: expressao_simples mais_menos_or termo {
                  if (!strcmp($2, "DISJ")){
                    if($1 != boolean_pas || $3 != boolean_pas){
                      fprintf(stderr, "COMPILATION ERROR!\n Operation OR must be between two booleans\n");
                      exit(1);
                    }
                    $$ = boolean_pas;
                  }
                  else {
                    if($1 != integer_pas || $3 != integer_pas){
                      fprintf(stderr, "COMPILATION ERROR!\n Operation + and - must be between two integers\n");
                      exit(1);
                    }
                    $$ = integer_pas;
                  }
                  geraCodigo(NULL, $2);
                }
                |
                mais_menos_vazio termo {
                  if (strcmp($1, "VAZIO")){
                    if ($2 != boolean_pas) {
                      fprintf(stderr, "COMPILATION ERROR!\n Signed variable must be integer\n");
                      exit(1);
                    }
                  }
                  $$ = $2;

                  if (!strcmp($1, "MENOS"))
                    geraCodigo(NULL, "INVR");
                }
;

mais_menos_or:
             MAIS  {$$ = "SOMA"; }|
             MENOS {$$ = "SUBT"; }|
             OR    {$$ = "DISJ"; }
;

mais_menos_vazio:
             MAIS  { $$ = "MAIS"; }|
             MENOS { $$ = "MENOS";}|
                   { $$ = "VAZIO";}
;

// REGRA 28
termo: termo vezes_div_and fator
    {
      if (!strcmp($2, "CONJ")) {
        if ($1 != boolean_pas || $3 != boolean_pas){
          fprintf(stderr, "COMPILATION ERROR!\n Operation AND must be made between booleans\n");
          exit(1);
        }
      }
      else {
        if ($1 != integer_pas || $3 != integer_pas){
          fprintf(stderr, "COMPILATION ERROR!\n Operation must be made between integers\n");
          exit(1);
        }
      }
      $$ = $3;

      geraCodigo(NULL, $2);
    }
    | fator { $$ = $1; }
;

vezes_div_and:
              VEZES { $$ = "MULT"; }
            | DIV { $$ = "DIVI"; }
            | AND { $$ = "CONJ"; }
;

// REGRA 29
// incompleta vai ter q mudar depois
fator: variavel {
      sprintf(mepaTemp, "CRVL %d %d",
      simboloTemp.nivel_lexico, simboloTemp.conteudo.var.deslocamento);
      geraCodigo(NULL, mepaTemp);
      $$ = simboloTemp.conteudo.var.tipo;
    }
    | NUMERO {
      sprintf(mepaTemp, "CRCT %s", token);
      geraCodigo(NULL, mepaTemp);
      $$ = integer_pas;
    }
//     | chamada_func
    | ABRE_PARENTESES expressao FECHA_PARENTESES { $$ = $2; }
//     | NOT fator
;

// REGRA 30
variavel: IDENT {
          simboloPtr = busca(&t, token);
          if (!simboloPtr) {
            fprintf(stderr, "COMPILATION ERROR\n Variable %s not declared\n", token);
            exit(1);
          }
          simboloTemp = *simboloPtr;
        }
        //| IDENT lista_de_expressoes
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
