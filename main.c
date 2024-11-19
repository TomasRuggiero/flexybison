#include <stdio.h>
extern int yyparse();

int main() {
    printf("Ingrese el programa en Micro:\n");
    if (yyparse() == 0) {
        printf("El programa es válido.\n");
    } else {
        printf("El programa tiene errores.\n");
    }
    return 0;
}