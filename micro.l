%{
#include <stdio.h>
#include <string.h>
#include "micro.tab.h"
int yywrap(void) { return 1; }  // Finaliza el análisis léxico cuando se termina el archivo
%}

DIGITO          [0-9]
LETRA           [a-zA-Z]
IDENTIFICADOR   {LETRA}({LETRA}|{DIGITO}){0,31}
CONSTANTE       {DIGITO}+

%%
inicio           {
    printf("Token leído: inicio\n");
    return INICIO;
}
fin              {
    printf("Token leído: fin\n");
    return FIN;
}
leer            {
    printf("Token leído: leer\n");
    return LEER;
}
escribir        {
    printf("Token leído: escribir\n");
    return ESCRIBIR;
}
":="            {
    printf("Token leído: :=\n");
    return ASIGNACION;
}
";"             {
    printf("Token leído: ;\n");
    return PUNTOYCOMA;
}
","             {
    printf("Token leído: ,\n");
    return COMA;
}
"("             {
    printf("Token leído: (\n");
    return PARENIZQ;
}
")"             {
    printf("Token leído: )\n");
    return PARENDER;
}
"+"             {
    printf("Token leído: +\n");
    return SUMA;
}
"-"             {
    printf("Token leído: -\n");
    return RESTA;
}
{IDENTIFICADOR} {
    printf("Token leído: IDENTIFICADOR (%s)\n", yytext);
    yylval.sval = strdup(yytext);
    return IDENTIFICADOR;
}
{CONSTANTE}     {
    printf("Token leído: CONSTANTE (%s)\n", yytext);
    yylval.ival = atoi(yytext);
    return CONSTANTE;
}
[ \t\n]         { /* Ignorar espacios en blanco */ }
.               {
    printf("Caracter inesperado: %s\n", yytext);
    exit(1);
}
%%
