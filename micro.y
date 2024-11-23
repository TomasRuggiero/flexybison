%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex(); // Declaración de yylex
void yyerror(const char *s) { fprintf(stderr, "Error: %s\n", s); }

typedef struct SymbolTable {
    char **symbols;   // Lista de identificadores
    int size;         // Cantidad actual de identificadores
    int capacity;     // Capacidad de la tabla
} SymbolTable;

SymbolTable *symbol_table;

void init_symbol_table() {
    symbol_table = malloc(sizeof(SymbolTable));
    symbol_table->size = 0;
    symbol_table->capacity = 10;
    symbol_table->symbols = malloc(symbol_table->capacity * sizeof(char *));
}

void add_symbol(char *symbol) {
    if (symbol_table->size == symbol_table->capacity) {
        symbol_table->capacity *= 2;
        symbol_table->symbols = realloc(symbol_table->symbols, symbol_table->capacity * sizeof(char *));
    }
    symbol_table->symbols[symbol_table->size++] = strdup(symbol);
}

int symbol_exists(char *symbol) {
    for (int i = 0; i < symbol_table->size; i++) {
        if (strcmp(symbol_table->symbols[i], symbol) == 0) {
            return 1; // Existe
        }
    }
    return 0; // No existe
}

void free_symbol_table() {
    for (int i = 0; i < symbol_table->size; i++) {
        free(symbol_table->symbols[i]);
    }
    free(symbol_table->symbols);
    free(symbol_table);
}
%}

%union {
    char *sval;
    int ival;
    void *list;
}

%token <sval> IDENTIFICADOR
%token <ival> CONSTANTE
%type <list> lista_ids
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
    IDENTIFICADOR ASIGNACION expresion PUNTOYCOMA {
        if (!symbol_exists($1)) {
            add_symbol($1);  // Si no está en la tabla, agrégalo
            printf("Declarando identificador: %s\n", $1);
        }
    }
    ;

entrada_salida:
    PALABRA_RESERVADA PARENIZQ lista_ids PARENDER PUNTOYCOMA
    | PALABRA_RESERVADA PARENIZQ lista_expresiones PARENDER PUNTOYCOMA
    ;

lista_ids:
    IDENTIFICADOR {
        if (!symbol_exists($1)) {
            fprintf(stderr, "Error: El identificador '%s' no está declarado.\n", $1);
            exit(1);
        }
    }
    | lista_ids COMA IDENTIFICADOR {
        if (!symbol_exists($1)) {
            fprintf(stderr, "Error: El identificador '%s' no está declarado.\n", $1);
            exit(1);
        }
    }
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
    | IDENTIFICADOR {
        if (!symbol_exists($1)) {
            fprintf(stderr, "Error: El identificador '%s' no está declarado.\n", $1);
            exit(1);  // Termina con error
        }
    }
    | PARENIZQ expresion PARENDER
    ;

%%