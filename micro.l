%{
#include "micro.tab.h"
int yywrap() { return 1; }  // Finaliza el análisis léxico cuando se termina el archivo
%}

DIGITO          [0-9]
LETRA           [a-zA-Z]
IDENTIFICADOR   {LETRA}({LETRA}|{DIGITO}){0,31}
CONSTANTE       {DIGITO}+

%%
[inicio|fin|leer|escribir] { return PALABRA_RESERVADA; }
":="            { return ASIGNACION; }
";"             { return PUNTOYCOMA; }
","             { return COMA; }
"("             { return PARENIZQ; }
")"             { return PARENDER; }
"+"             { return SUMA; }
"-"             { return RESTA; }
{IDENTIFICADOR} { yylval.sval = strdup(yytext); return IDENTIFICADOR; }
{CONSTANTE}     { yylval.ival = atoi(yytext); return CONSTANTE; }
[ \t\n]         { /* Ignorar espacios en blanco */ }
.               { printf("Caracter inesperado: %s\n", yytext); exit(1); }
%%
