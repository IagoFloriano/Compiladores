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
#include "Pilha/pilha.h"


char mepaTemp[256];
char rotrTemp[256];
int num_vars;
int qtTipoAtual;
int tipoAtual;
int nivelLexico;
int chamandoProc;
int numParamProc;
simb simboloTemp;
simb *simboloPtr;
simb *simbVarProcPtr;
simb *simbFuncDeclara;
simb simbCallProc;
simb simbAtribuicao;
t_conteudo conteudoTemp;
tabela t;
pilha rotulos;
pilha num_vars_p;
int proxRotulo;
int tipoAtual;
int numParamCallProc;
int ignoraVariavelFunc;

struct parametro *paramsProcAtual;
int parVarRef;

pilha numProcs;

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
      printf("%2d, %2d, %s, %d\n",
          s.nivel_lexico, s.conteudo.var.deslocamento, tiposVar[s.conteudo.var.tipo],
          s.conteudo.proc.num_parametros);
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
%token WRITE READ

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

%nonassoc "lower_than_else"
%nonassoc ELSE

%%

// REGRA 01
programa    :{
             geraCodigo(NULL, "INPP");
             inicializa(&t);
             pilha_init(&rotulos);
             pilha_init(&num_vars_p);
             pilha_pop(&numProcs);
             proxRotulo = 0;
             nivelLexico = 0;
             }
             PROGRAM IDENT
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
             bloco PONTO {
             pilha_pop(&num_vars_p);
             geraCodigo(NULL, "PARA");
             }
;

// REGRA 02
bloco       :
              parte_declara_vars {
                sprintf(mepaTemp, "DSVS R%02d", proxRotulo);
                geraCodigo(NULL, mepaTemp);
                pilha_push(&rotulos, proxRotulo);
                proxRotulo++;

                nivelLexico++;
              }
              parte_declara_subrotinas {
                nivelLexico--;

                sprintf(rotrTemp, "R%02d", pilha_topo(&rotulos));
                geraCodigo(rotrTemp, "NADA");
                pilha_pop(&rotulos);
              }

              comando_composto{
                sprintf(mepaTemp, "DMEM %d", pilha_topo(&num_vars_p));
                removeN(&t, pilha_topo(&num_vars_p));
                pilha_pop(&num_vars_p);
                geraCodigo(NULL, mepaTemp);
              }
              ;

// REGRA 08
parte_declara_vars: {
                  num_vars = 0;
                  } VAR declara_vars {
                    sprintf(mepaTemp, "AMEM %d", num_vars);
                    geraCodigo(NULL, mepaTemp);
                    pilha_push(&num_vars_p, num_vars);
                  }
                  | {pilha_push(&num_vars_p, 0);}
;

// REGRA 09
declara_vars: declara_vars declara_var
            | declara_var
;

declara_var : {}
              lista_id_var DOIS_PONTOS
              {}
              tipo
              {qtTipoAtual = 0;
              }
              PONTO_E_VIRGULA
;

tipo        : IDENT {
            tipoAtual = strToType(token);
            atribuiTipo(&t, tipoAtual, qtTipoAtual);
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

// REGRA 11
parte_declara_subrotinas: parte_declara_subrotinas declara_proc PONTO_E_VIRGULA
                        | parte_declara_subrotinas declara_func PONTO_E_VIRGULA
                        |
;

// REGRA 12
declara_proc:
            PROCEDURE
            IDENT {
              conteudoTemp.proc.tipo_retorno = indefinido_pas;
              conteudoTemp.proc.rotulo = proxRotulo;
              conteudoTemp.proc.num_parametros = 0;
              simboloTemp = criaSimbolo(token, procedimento, nivelLexico, conteudoTemp);
              push(&t, simboloTemp);
              paramsProcAtual = busca(&t, token)->conteudo.proc.lista;
              simbFuncDeclara = busca(&t, token);
              numParamProc = 0;
            }
            talvez_params_formais
            {
              sprintf(mepaTemp, "ENPR %d", nivelLexico);
              sprintf(rotrTemp, "R%02d", proxRotulo);
              geraCodigo(rotrTemp, mepaTemp);
              atribuiDeslocamento(&t, numParamProc);

              proxRotulo++;
            }
            PONTO_E_VIRGULA
            bloco
            {
              removeAte(&t, nivelLexico);
              sprintf(mepaTemp, "RTPR %d, %d", nivelLexico, topo(&t).conteudo.proc.num_parametros);
              geraCodigo(NULL, mepaTemp);

              printTabela(t);
            }
;

// REGRA 13
declara_func:
            FUNCTION
            IDENT {
              conteudoTemp.proc.tipo_retorno = indefinido_pas;
              conteudoTemp.proc.rotulo = proxRotulo;
              conteudoTemp.proc.num_parametros = 0;
              simboloTemp = criaSimbolo(token, procedimento, nivelLexico, conteudoTemp);
              printSimbolo(simboloTemp, 0);
              push(&t, simboloTemp);
              paramsProcAtual = busca(&t, token)->conteudo.proc.lista;
              simbFuncDeclara = busca(&t, token);
              numParamProc = 0;
            }
            talvez_params_formais
            {
              sprintf(mepaTemp, "ENPR %d", nivelLexico);
              sprintf(rotrTemp, "R%02d", proxRotulo);
              geraCodigo(rotrTemp, mepaTemp);
              atribuiDeslocamento(&t, numParamProc);

              proxRotulo++;
              printTabela(t);
            }
            DOIS_PONTOS
            tipo
            {
              simbFuncDeclara = busca(&t, simbFuncDeclara->identificador);
              simbFuncDeclara->conteudo.proc.tipo_retorno = tipoAtual;
              printTabela(t);
            }
            PONTO_E_VIRGULA
            bloco
            {
              removeAte(&t, nivelLexico);
              sprintf(mepaTemp, "RTPR %d, %d", nivelLexico, topo(&t).conteudo.proc.num_parametros);
              geraCodigo(NULL, mepaTemp);

            }
;

// REGRA 14
talvez_params_formais: params_formais |
;

params_formais: ABRE_PARENTESES parametros FECHA_PARENTESES
;

parametros: secoes_parametros {
            printf("\n\n\n");
            simbFuncDeclara = busca(&t, simbFuncDeclara->identificador);
            for(int i = numParamProc-1; i >= 0; i--){
              printf("%d %d\n", paramsProcAtual[i].tipo, paramsProcAtual[i].tipo_passagem);
            }
            memcpy(simbFuncDeclara->conteudo.proc.lista, paramsProcAtual, numParamProc*sizeof(struct parametro));
            printTabela(t);
            for(int i = numParamProc-1; i >= 0; i--){
              printf("%d %d\n",
                simbFuncDeclara->conteudo.proc.lista[i].tipo,
                simbFuncDeclara->conteudo.proc.lista[i].tipo_passagem);
            }
            printf("\n\n\n");
          }
;

secoes_parametros:
                 secoes_parametros PONTO_E_VIRGULA{qtTipoAtual =0;}
                 lista_de_parametros DOIS_PONTOS tipo{
                   for(int i = numParamProc - qtTipoAtual;
                       i < numParamProc;
                       i++){
                       paramsProcAtual[i].tipo = tipoAtual;
                       printf("Tipo atual = %d, tipo salvo = %d\n",
                       tipoAtual, paramsProcAtual[i].tipo);
                   }
                 }
                 |{qtTipoAtual =0;}
                 lista_de_parametros DOIS_PONTOS tipo{
                   for(int i = numParamProc - qtTipoAtual;
                       i < numParamProc;
                       i++){
                       paramsProcAtual[i].tipo = tipoAtual;
                       printf("Tipo atual = %d, tipo salvo = %d\n",
                       tipoAtual, paramsProcAtual[i].tipo);
                   }
                   printf("FOI ULTIMO TIPO\n");
                 }
;

lista_de_parametros:
                   lista_de_parametros VIRGULA talvez_var param {
                   }
                   | talvez_var param {
                   }
;

param: IDENT {
       conteudoTemp.par.tipo_passagem = parVarRef;
       simboloTemp = criaSimbolo(token, parametro, nivelLexico, conteudoTemp);
       push(&t, simboloTemp);
       qtTipoAtual++;
       paramsProcAtual[numParamProc].tipo_passagem = parVarRef;
       numParamProc++;
     }
;

talvez_var: VAR {parVarRef = referencia_par;}
          | {parVarRef = valor_par;}
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
comando_sem_rotulo: atribuicao_proc_ou_func
                  | comando_repetitivo
                  | comando_condicional
                  | comando_composto
                  | leitura
                  | escrita
                  |
;

leitura: READ ABRE_PARENTESES itens_leitura FECHA_PARENTESES
;

itens_leitura: itens_leitura VIRGULA item_leitura | item_leitura
;

item_leitura: IDENT
            {
              simboloPtr = busca(&t, token);
              if (!simboloPtr){
                fprintf(stderr, "COMPILATION ERROR\n Cannot read to varible %s is not in scope\n",
                token);
                exit(1);
              }
              simboloTemp = *simboloPtr;
              geraCodigo(NULL, "LEIT");
              sprintf(mepaTemp, "ARMZ %d, %d", simboloTemp.nivel_lexico,
                simboloTemp.conteudo.var.deslocamento);
              geraCodigo(NULL, mepaTemp);
            }
;

escrita: WRITE ABRE_PARENTESES itens_escrita FECHA_PARENTESES
;

itens_escrita: itens_escrita VIRGULA expressao {geraCodigo(NULL, "IMPR");}
             | expressao {geraCodigo(NULL, "IMPR");}
;

atribuicao_proc_ou_func: IDENT
                       {
                        simbVarProcPtr = busca(&t, token);
                        if (!simbVarProcPtr) {
                          fprintf(stderr, "COMPILATION ERROR!\n Variable, procedure or function %s was not declared.\n"
                          , token); 
                          exit(1);
                        }
                       }
                       a_continua
                       {
                       }
;

a_continua:
          {
            simbAtribuicao = *simbVarProcPtr;
          }
          ATRIBUICAO atribuicao
          | proc_sem_param
          | proc_com_param
;


// REGRA 19
atribuicao:
          expressao
          {
            if ($1 != simbAtribuicao.conteudo.var.tipo) {
              fprintf(stderr, "COMPILATION ERROR!\n Atributing wrong type to variable\n");
              exit(1);
            }
            // armazena em variavel e função
            if (simbAtribuicao.tipo_simbolo == variavel ||
              simbAtribuicao.tipo_simbolo == procedimento){
              sprintf(mepaTemp, "ARMZ %d, %d",
              simbAtribuicao.nivel_lexico, simbAtribuicao.conteudo.var.deslocamento);
              geraCodigo(NULL, mepaTemp);
            }
            else if (simbAtribuicao.tipo_simbolo == parametro){
              //salvar por valor
              if (simbAtribuicao.conteudo.par.tipo_passagem == valor_par){
                sprintf(mepaTemp, "ARMZ %d, %d",
                simbAtribuicao.nivel_lexico, simbAtribuicao.conteudo.var.deslocamento);
                geraCodigo(NULL, mepaTemp);
              }
              //salvar por referencia
              else {
                sprintf(mepaTemp, "ARMI %d, %d",
                simbAtribuicao.nivel_lexico, simbAtribuicao.conteudo.var.deslocamento);
                geraCodigo(NULL, mepaTemp);
              }
            }
          }
;

proc_sem_param:{
                simboloTemp = *simbVarProcPtr;
                if(simboloTemp.tipo_simbolo != procedimento) {
                  fprintf(stderr, "COMPILATION ERROR!\n Symbol %s is not procedure\n"
                  ,token);
                  exit(1);
                }
                if (simboloTemp.conteudo.proc.num_parametros != 0) {
                    fprintf(stderr, "COMPILATION ERROR!\n Procedure called incorrectly\n");
                    exit(1);
                }
                if (simboloTemp.conteudo.proc.tipo_retorno != indefinido_pas){
                    geraCodigo(NULL, "AMEM 1");
                }
                sprintf(mepaTemp, "CHPR R%02d, %d", simboloTemp.conteudo.proc.rotulo, nivelLexico);
                geraCodigo(NULL, mepaTemp);
              }
;

// REGRA 20
proc_com_param:
              {
                simbCallProc = *simbVarProcPtr;
                if (simbCallProc.tipo_simbolo != procedimento ||
                    simbCallProc.conteudo.proc.num_parametros == 0) {
                    fprintf(stderr, "COMPILATION ERROR!\n Procedure called incorrectly\n");
                    exit(1);
                }
                if (simbCallProc.conteudo.proc.tipo_retorno){
                    geraCodigo(NULL, "AMEM 1");
                }
                chamandoProc = 1;
              }
              ABRE_PARENTESES
              {numParamCallProc = 0;}
              lista_de_expressoes
              {
                if (numParamCallProc != simbCallProc.conteudo.proc.num_parametros){
                  fprintf(stderr, "COMPILATION ERROR!\n Procedure with wrong number of params\n");
                  fprintf(stderr, "%d\n", numParamCallProc);
                  exit(1);
                }
                sprintf(mepaTemp, "CHPR R%02d, %d", simbCallProc.conteudo.proc.rotulo,
                nivelLexico);
                geraCodigo(NULL, mepaTemp);
                chamandoProc = 0;
              }
              FECHA_PARENTESES
;

// REGRA 22
comando_condicional:
                  IF expressao {
                    // desvia falso pra else
                    if ($2 != boolean_pas){
                      fprintf(stderr, "COMPILATION ERROR\n Cannot do if with integer expression\n");
                      exit(1);
                    }
                    sprintf(mepaTemp, "DSVF R%02d", proxRotulo+1);
                    geraCodigo(NULL, mepaTemp);
                    // empilha rotulo
                    pilha_push(&rotulos, proxRotulo);
                    proxRotulo+=2;
                  }
                  THEN comando_sem_rotulo {
                    // desvia sempre fim else
                    sprintf(mepaTemp, "DSVS R%02d", pilha_topo(&rotulos));
                    geraCodigo(NULL, mepaTemp);

                    // rotulo else
                    sprintf(rotrTemp, "R%02d", pilha_topo(&rotulos)+1);
                    geraCodigo(rotrTemp, "NADA");
                  }
                  talvez_else {
                    // rotulo fim else
                    sprintf(rotrTemp, "R%02d", pilha_topo(&rotulos));
                    geraCodigo(rotrTemp, "NADA");

                    pilha_pop(&rotulos);
                  }
;

talvez_else: ELSE comando_sem_rotulo
           | %prec "lower_than_else"
;

// REGRA 23
comando_repetitivo: WHILE {
                      pilha_push(&rotulos, proxRotulo);
                      sprintf(rotrTemp, "R%02d", proxRotulo);
                      geraCodigo(rotrTemp, "NADA");

                      proxRotulo += 2;
                    }
                    expressao
                    DO {
                      sprintf(mepaTemp, "DSVF R%02d", pilha_topo(&rotulos)+1);
                      geraCodigo(NULL, mepaTemp);
                    } comando_sem_rotulo {
                      
                      sprintf(mepaTemp, "DSVS R%02d", pilha_topo(&rotulos));
                      geraCodigo(NULL, mepaTemp);
                      
                      sprintf(rotrTemp, "R%02d", pilha_topo(&rotulos)+1);
                      geraCodigo(rotrTemp, "NADA");

                      pilha_pop(&rotulos);
                    }
;

// REGRA 24
lista_de_expressoes: lista_de_expressoes VIRGULA {numParamCallProc++;}expressao 
                   |  {numParamCallProc++;}expressao 
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
fator: variavel_ou_func {
      int passarPara = valor_par;
      if (chamandoProc){
        passarPara = simbCallProc.conteudo.proc.lista[numParamCallProc-1].tipo_passagem;
        printSimbolo(simbCallProc, 3);
      }
      printSimbolo(simboloTemp, 0);
      printf("%d\n",numParamCallProc-1);
      printf("%d\n",passarPara);
      printf("%s\n", token);

      if (ignoraVariavelFunc) {
        ignoraVariavelFunc = 0;
      }
      else{
        if (simboloTemp.tipo_simbolo == variavel){
          // passar pra um q pede por valor ou carregar normal
          if (passarPara){
            sprintf(mepaTemp, "CRVL %d, %d",
              simboloTemp.nivel_lexico, simboloTemp.conteudo.var.deslocamento);
            geraCodigo(NULL, mepaTemp);
          }
          // passar pra um q pede por referencia
          else {
            sprintf(mepaTemp, "CREN %d, %d",
              simboloTemp.nivel_lexico, simboloTemp.conteudo.var.deslocamento);
            geraCodigo(NULL, mepaTemp);
          }
        }
        else if (simboloTemp.tipo_simbolo == procedimento){
          sprintf(mepaTemp, "AMEM 1");
          geraCodigo(NULL, mepaTemp);
          sprintf(mepaTemp, "CHPR R%02d, %d", simboloTemp.conteudo.proc.rotulo, nivelLexico);
          geraCodigo(NULL, mepaTemp);
        }
        else if (simboloTemp.tipo_simbolo == parametro){
          //se foi passado por valor
          if (simboloTemp.conteudo.par.tipo_passagem == valor_par){
            printf("PASSANDO TOKEN %s\n%d\n\n",simboloTemp.identificador,passarPara);
            if(passarPara){
              sprintf(mepaTemp, "CRVL %d, %d",
                simboloTemp.nivel_lexico, simboloTemp.conteudo.var.deslocamento);
              geraCodigo(NULL, mepaTemp);
            }
            else{
              sprintf(mepaTemp, "CREN %d, %d",
                simboloTemp.nivel_lexico, simboloTemp.conteudo.var.deslocamento);
              geraCodigo(NULL, mepaTemp);
            }
          }
          //se foi passado por referencia
          else {
            if(passarPara){
              sprintf(mepaTemp, "CRVI %d, %d",
                simboloTemp.nivel_lexico, simboloTemp.conteudo.var.deslocamento);
              geraCodigo(NULL, mepaTemp);
            }
            else{
              sprintf(mepaTemp, "CRVL %d, %d",
                simboloTemp.nivel_lexico, simboloTemp.conteudo.var.deslocamento);
              geraCodigo(NULL, mepaTemp);
            }
          }
        }
      }
      $$ = simboloTemp.conteudo.var.tipo;
    }
    | NUMERO {
      sprintf(mepaTemp, "CRCT %s", token);
      geraCodigo(NULL, mepaTemp);
      $$ = integer_pas;
    }
    | ABRE_PARENTESES expressao FECHA_PARENTESES { $$ = $2; }
;

// REGRA 30
variavel_ou_func: IDENT {
          simboloPtr = busca(&t, token);
          if (!simboloPtr) {
            fprintf(stderr, "COMPILATION ERROR\n Variable %s not declared\n", token);
            exit(1);
          }
          simboloTemp = *simboloPtr;
          ignoraVariavelFunc = 0;
        }
        talvez_params_func
;

talvez_params_func: ABRE_PARENTESES
                  {
                   geraCodigo(NULL, "AMEM 1");
                   numParamCallProc = 0;
                   chamandoProc = 1;
                   simbCallProc = simboloTemp;
                  }
                  lista_params_reais
                  FECHA_PARENTESES
                  {
                  printf("FECHA PARAMETROS FUNCAO\n");
                  chamandoProc = 0;
                  sprintf(mepaTemp, "CHPR R%02d, %d", simbCallProc.conteudo.proc.rotulo, nivelLexico);
                  geraCodigo(NULL, mepaTemp);
                  ignoraVariavelFunc = 1;
                  }
                  | {printf("NAO TEM PARAMETROS DE FUNC\n");}
;

lista_params_reais: lista_params_reais VIRGULA {printf("COMEÇO EXPRESSAO SIMPLES\n"); numParamCallProc++;}expressao_simples
                  {printf("FIM DE EXPRESSÃO SIMPLES\n");}
                  | {printf("COMEÇO EXPRESSAO SIMPLES\n"); numParamCallProc++;}expressao_simples
                  {printf("FIM DE EXPRESSÃO SIMPLES\n");}
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