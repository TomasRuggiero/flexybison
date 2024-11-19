%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex(); // Declaración de yylex
void yyerror(const char *s) { fprintf(stderr, "Error: %s\n", s); }
%}

%union {
    char *sval;
    int ival;
}

%token <sval> IDENTIFICADOR
%token <ival> CONSTANTE
%token PALABRA_RESERVADA ASIGNACION PUNTOYCOMA COMA PARENIZQ PARENDER SUMA RESTA

%%
programa:
    PALABRA_RESERVADA cuerpo PALABRA_RESERVADA
    ;

cuerpo:
    /* vacío */
    | cuerpo sentencia
    ;

sentencia:
    asignacion
    | entrada_salida
    ;

asignacion:
    IDENTIFICADOR ASIGNACION expresion PUNTOYCOMA
    ;

entrada_salida:
    PALABRA_RESERVADA PARENIZQ lista_ids PARENDER PUNTOYCOMA
    | PALABRA_RESERVADA PARENIZQ lista_expresiones PARENDER PUNTOYCOMA
    ;

lista_ids:
    IDENTIFICADOR
    | lista_ids COMA IDENTIFICADOR
    ;

lista_expresiones:
    expresion
    | lista_expresiones COMA expresion
    ;

expresion:
    termino
    | expresion SUMA termino
    | expresion RESTA termino
    ;

termino:
    CONSTANTE
    | IDENTIFICADOR
    | PARENIZQ expresion PARENDER
    ;
%%