%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
void yyerror(const char *s) { fprintf(stderr, "Error: %s\n", s); }

typedef struct Simbolo {
    char *simbolo;
    int es_usada;
} Simbolo;

typedef struct TablaSimbolos {
    Simbolo *simbolos;
    int tamanio;
    int capacidad;
} TablaSimbolos;

TablaSimbolos *tabla_simbolos;

void init_tabla_simbolos() {
    tabla_simbolos = malloc(sizeof(TablaSimbolos));
    tabla_simbolos->tamanio = 0;
    tabla_simbolos->capacidad = 10;
    tabla_simbolos->simbolos = malloc(tabla_simbolos->capacidad * sizeof(Simbolo));
}

void agregar_simbolo(char *simbolo) {
    if (tabla_simbolos->tamanio == tabla_simbolos->capacidad) {
        tabla_simbolos->capacidad *= 2;
        tabla_simbolos->simbolos = realloc(tabla_simbolos->simbolos, tabla_simbolos->capacidad * sizeof(Simbolo));
    }
    tabla_simbolos->simbolos[tabla_simbolos->tamanio++].simbolo = strdup(simbolo);
    tabla_simbolos->simbolos[tabla_simbolos->tamanio].es_usada = 0;
}

int existe_simbolo(char *simbolo) {
    for (int i = 0; i < tabla_simbolos->tamanio; i++) {
        if (strcmp(tabla_simbolos->simbolos[i].simbolo, simbolo) == 0) {
            return 1;
        }
    }
    return 0;
}

void use_symbol(char* simbolo) {
    for (int i = 0; i < tabla_simbolos->tamanio; i++) {
        if (strcmp(tabla_simbolos->simbolos[i].simbolo, simbolo) == 0) {
            tabla_simbolos->simbolos[i].es_usada = 1;
        }
    }
}

void verificar_vars_no_usadas() {
    for (int i = 0; i < tabla_simbolos->tamanio; i++) {
        if (tabla_simbolos->simbolos[i].es_usada == 0)
            printf("Warning: La variable %s es declarada pero no se utiliza\n", tabla_simbolos->simbolos[i].simbolo);
    }
}

void free_tabla_simbolos() {
    for (int i = 0; i < tabla_simbolos->tamanio; i++) {
        free(tabla_simbolos->simbolos[i].simbolo);
    }
    free(tabla_simbolos->simbolos);
    free(tabla_simbolos);
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
        verificar_vars_no_usadas();
        free_tabla_simbolos();
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
        if (!existe_simbolo($1)) {
            agregar_simbolo($1);
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
        if (!existe_simbolo($1)) {
            agregar_simbolo($1);
            printf("Declarando identificador: %s\n", $1);
        }
    }
    | lista_ids COMA IDENTIFICADOR {
        if (!existe_simbolo($3)) {
            agregar_simbolo($3);
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
        if (!existe_simbolo($1)) {
            fprintf(stderr, "Error: El identificador '%s' no está declarado.\n", $1);
        }
        use_symbol($1);
    }
    | PARENIZQ expresion PARENDER
    ;

%%