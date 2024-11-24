%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
void yyerror(const char *s) { fprintf(stderr, "Error: %s\n", s); }

typedef struct Symbol {
    char *symbol;
    int isUsed;
} Symbol;

typedef struct SymbolTable {
    Symbol *symbols;
    int size;
    int capacity;
} SymbolTable;

SymbolTable *symbol_table;

void init_symbol_table() {
    symbol_table = malloc(sizeof(SymbolTable));
    symbol_table->size = 0;
    symbol_table->capacity = 10;
    symbol_table->symbols = malloc(symbol_table->capacity * sizeof(Symbol));
}

void add_symbol(char *symbol) {
    if (symbol_table->size == symbol_table->capacity) {
        symbol_table->capacity *= 2;
        symbol_table->symbols = realloc(symbol_table->symbols, symbol_table->capacity * sizeof(Symbol));
    }
    symbol_table->symbols[symbol_table->size++].symbol = strdup(symbol);
    symbol_table->symbols[symbol_table->size].isUsed = 0;
}

int symbol_exists(char *symbol) {
    for (int i = 0; i < symbol_table->size; i++) {
        if (strcmp(symbol_table->symbols[i].symbol, symbol) == 0) {
            return 1;
        }
    }
    return 0;
}

void use_symbol(char* symbol) {
    for (int i = 0; i < symbol_table->size; i++) {
        if (strcmp(symbol_table->symbols[i].symbol, symbol) == 0) {
            symbol_table->symbols[i].isUsed = 1;
        }
    }
}

void check_unused_variables() {
    for (int i = 0; i < symbol_table->size; i++) {
        if (symbol_table->symbols[i].isUsed == 0)
            printf("Warning: La variable %s es declarada pero no se utiliza\n", symbol_table->symbols[i].symbol);
    }
}

void free_symbol_table() {
    for (int i = 0; i < symbol_table->size; i++) {
        free(symbol_table->symbols[i].symbol);
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
%token INICIO FIN LEER ESCRIBIR ASIGNACION PUNTOYCOMA COMA PARENIZQ PARENDER SUMA RESTA

%%
programa:
    INICIO cuerpo FIN {
        printf("Fin del programa.\n");
        check_unused_variables();
        free_symbol_table();
        exit(0);
    }
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
    LEER PARENIZQ lista_ids PARENDER PUNTOYCOMA
    | ESCRIBIR PARENIZQ lista_expresiones PARENDER PUNTOYCOMA
    ;

lista_ids:
    IDENTIFICADOR {
        if (!symbol_exists($1)) {
            add_symbol($1);
            printf("Declarando identificador: %s\n", $1);
        }
    }
    | lista_ids COMA IDENTIFICADOR {
        if (!symbol_exists($3)) {
            add_symbol($3);
            printf("Declarando identificador: %s\n", $3);
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
        use_symbol($1);
    }
    | PARENIZQ expresion PARENDER
    ;

%%