/*
 * Header para definir o tipo SIMBOLO que vai estar na tabela de simbolos
 * Dentro desse SIMBOLO tera uma seção para especificar qual tipo de simbolo é
 * Os tipo possíveis são: procedimento, variável, parametro
*/
#ifndef __SIMBOLO__
#define __SIMBOLO__


enum tipos_simbolo {
  procedimento,
  variavel,
  parametro
};

/* identificadores especificos para variaveis */
enum tipos_variavel {
  indefinido_pas = 0,
  integer_pas = 1,
  boolean_pas = 2
};

/* indentificador para se parametro é passado por valor ou referencia */
enum tipos_parametro {
  referencia_par,
  valor_par
};

/* struct para cada forma possivel de simbolo */
struct variavel {
  int tipo; // enum tipos_variavel
  int deslocamento;
};

struct parametro {
  int tipo;          // enum tipos_variavel
  int deslocamento;
  int tipo_passagem; // enum tipos_parametro
};

struct procedimento {
  int tipo_retorno;   // enum tipos_variavel (0 se for procedimento)
  int deslocamento;   // so usar caso seja função
  int rotulo;
  struct parametro lista[64];
};

/* typedef do simbolo em si */
typedef union t_conteudo {
  struct variavel var;
  struct parametro par;
  struct procedimento proc;
} t_conteudo;

typedef struct simb {
  char *identificador;
  int tipo_simbolo;
  int nivel_lexico;
  t_conteudo conteudo;
} simb;

simb criaSimbolo(char *ident, int tipo_simbolo, int nivel, t_conteudo cont);

#endif // __SIMBOLO__
