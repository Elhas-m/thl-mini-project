#include <stdio.h>
#include <stdlib.h>
#include "symbol_table.h"

extern int yyparse();
extern FILE *yyin;
extern SymbolTable *symbol_table;
extern int semantic_errors;

int main(int argc, char *argv[]) {
    printf("=== GLSimpleSQL Interpreter ===\n");
    printf("Interpréteur de requêtes SQL simplifiées\n");
    printf("Développé avec Flex et Bison\n\n");

    // Initialize symbol table
    symbol_table = create_symbol_table();
    semantic_errors = 0;

    // Set input source
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            printf("Erreur : Impossible d'ouvrir le fichier %s\n", argv[1]);
            return 1;
        }
        yyin = file;
        printf("Lecture du fichier : %s\n\n", argv[1]);
    } else {
        printf("Lecture depuis l'entrée standard (tapez Ctrl+D pour terminer)\n\n");
        yyin = stdin;
    }

    // Parse input
    int result = yyparse();

    // Display results
    printf("\n=== RÉSUMÉ D'ANALYSE ===\n");

    if (result == 0 && semantic_errors == 0) {
        printf("✓ Analyse terminée avec succès !\n");
        printf("  Aucune erreur détectée.\n");
    } else {
        printf("✗ Analyse terminée avec des erreurs :\n");
        if (result != 0) {
            printf("  - Erreurs syntaxiques détectées\n");
        }
        if (semantic_errors > 0) {
            printf("  - %d erreur(s) sémantique(s) détectée(s)\n", semantic_errors);
        }
    }

    // Print symbol table if not empty
    if (symbol_table->table_count > 0) {
        print_symbol_table(symbol_table);
    }

    // Cleanup
    destroy_symbol_table(symbol_table);

    if (argc > 1) {
        fclose(yyin);
    }

    return (result == 0 && semantic_errors == 0) ? 0 : 1;
}
