#include <stdio.h>
extern int yyparse();
extern void init_symbol_table();

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Uso: %s <archivo>\n", argv[0]);
        return 1;
    }

    if (freopen(argv[1], "r", stdin) == NULL) {
        perror("Error al abrir el archivo");
        return 1;
    }

    init_symbol_table();

    if (yyparse() == 0) {
        printf("El programa es válido.\n");
    } else {
        printf("El programa tiene errores.\n");
    }

    return 0;
}
