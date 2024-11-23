#include <stdio.h>
extern int yyparse();

int main() {
    init_symbol_table();
    if (yyparse() == 0) {
        printf("El programa es válido.\n");
    } else {
        printf("El programa tiene errores.\n");
    }
    free_symbol_table();
    return 0;
}