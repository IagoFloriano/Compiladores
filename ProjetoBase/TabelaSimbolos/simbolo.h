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
}

/* identificadores especificos para variaveis */
enum tipos_variavel {
  integer_pas,
  boolean_pas,
  indefinido_pas
}

/* indentificador para se parametro é passado por valor ou referencia */
enum tipos_parametro {
  referencia_par,
  valor_par
}

/* struct para cada forma possivel de simbolo */


#endif // __SIMBOLO__
