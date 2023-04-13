
%{
#include <stdio.h>
%}

%token IDENT BIDENT MAIS MENOS AND OR ASTERISCO DIV ABRE_PARENTESES FECHA_PARENTESES

%%

start      : expr |
             bexpr |
;

expr       : expr MAIS termo {printf ("+"); } |
             expr MENOS termo {printf ("-"); } | 
             termo
;

termo      : termo ASTERISCO fator  {printf ("*"); }| 
             termo DIV fator  {printf ("/"); }|
             fator
;

fator      : IDENT {printf ("A"); }
;

bexpr       : bexpr AND btermo {printf (" AND "); } |
              bexpr OR btermo {printf (" OR "); } | 
              btermo
;

btermo      : BIDENT {printf ("B"); }
;

%%

main (int argc, char** argv) {
   yyparse();
   printf("\n");
}

