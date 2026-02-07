#include "symbol_table.h"

// Create a new symbol table
SymbolTable* create_symbol_table() {
    SymbolTable *st = malloc(sizeof(SymbolTable));
    st->tables = NULL;
    st->table_count = 0;
    return st;
}

// Destroy symbol table and free memory
void destroy_symbol_table(SymbolTable *st) {
    if (!st) return;

    Table *current_table = st->tables;
    while (current_table) {
        Table *next_table = current_table->next;

        // Free fields
        Field *current_field = current_table->fields;
        while (current_field) {
            Field *next_field = current_field->next;
            free(current_field->name);
            free(current_field);
            current_field = next_field;
        }

        free(current_table->name);
        free(current_table);
        current_table = next_table;
    }

    free(st);
}

// Add a new table
int add_table(SymbolTable *st, const char *table_name) {
    if (!st || !table_name) return 0;

    // Check if table already exists
    if (find_table(st, table_name)) {
        return 0; // Table already exists
    }

    Table *new_table = malloc(sizeof(Table));
    new_table->name = malloc(strlen(table_name) + 1);
    strcpy(new_table->name, table_name);
    new_table->fields = NULL;
    new_table->field_count = 0;
    new_table->next = st->tables;

    st->tables = new_table; // the head of the liked list
    st->table_count++;

    return 1; // Success
}

// Remove a table
int remove_table(SymbolTable *st, const char *table_name) {
    if (!st || !table_name) return 0;

    Table *current = st->tables;
    Table *prev = NULL;

    while (current) {
        if (strcmp(current->name, table_name) == 0) {
            // Found the table, remove it
            if (prev) {
                prev->next = current->next;
            } else {
                st->tables = current->next;
            }

            // Free fields
            Field *current_field = current->fields;
            while (current_field) {
                Field *next_field = current_field->next;
                free(current_field->name);
                free(current_field);
                current_field = next_field;
            }

            // Free table
            free(current->name);
            free(current);
            st->table_count--;

            return 1; // Success
        }
        prev = current;
        current = current->next;
    }

    return 0; // Table not found
}

// Add a field to a table
int add_field_to_table(SymbolTable *st, const char *table_name, const char *field_name, DataType type, int varchar_size) {
    if (!st || !table_name || !field_name) return 0;

    Table *table = find_table(st, table_name);
    if (!table) return 0; // Table not found

    // Check if field already exists
    if (find_field_in_table(table, field_name)) {
        return 0; // Field already exists
    }

    Field *new_field = malloc(sizeof(Field));
    new_field->name = malloc(strlen(field_name) + 1);
    strcpy(new_field->name, field_name);
    new_field->type = type;
    new_field->varchar_size = varchar_size;
    new_field->next = table->fields;

    table->fields = new_field;
    table->field_count++;

    return 1; // Success
}

// Find a table by name
Table* find_table(SymbolTable *st, const char *table_name) {
    if (!st || !table_name) return NULL;

    Table *current = st->tables;
    while (current) {
        if (strcmp(current->name, table_name) == 0) {
            return current;
        }
        current = current->next;
    }

    return NULL;
}

// Find a field in a table
Field* find_field_in_table(Table *table, const char *field_name) {
    if (!table || !field_name) return NULL;

    Field *current = table->fields;
    while (current) {
        if (strcmp(current->name, field_name) == 0) {
            return current;
        }
        current = current->next;
    }

    return NULL;
}

// Convert data type to string
const char* type_to_string(DataType type) {
    switch (type) {
        case TYPE_INT: return "INT";
        case TYPE_FLOAT: return "FLOAT";
        case TYPE_VARCHAR: return "VARCHAR";
        case TYPE_BOOL: return "BOOL";
        default: return "UNKNOWN";
    }
}

// Print symbol table contents
void print_symbol_table(SymbolTable *st) {
    if (!st) return;

    printf("\n=== SYMBOL TABLE ===\n");
    printf("Total tables: %d\n\n", st->table_count);

    Table *current_table = st->tables;
    while (current_table) {
        printf("Table: %s (%d fields)\n", current_table->name, current_table->field_count);

        Field *current_field = current_table->fields;
        while (current_field) {
            printf("  - %s: %s", current_field->name, type_to_string(current_field->type));
            if (current_field->type == TYPE_VARCHAR) {
                printf("(%d)", current_field->varchar_size);
            }
            printf("\n");
            current_field = current_field->next;
        }
        printf("\n");
        current_table = current_table->next;
    }
}

// Query statistics functions
QueryStats* create_query_stats() {
    QueryStats *stats = malloc(sizeof(QueryStats));
    stats->table_name = NULL;
    stats->field_count = 0;
    stats->field_names = NULL;
    stats->has_where = 0;
    stats->condition_count = 0;
    stats->logical_operators_count = 0;
    stats->value_count = 0;
    return stats;
}

void destroy_query_stats(QueryStats *stats) {
    if (!stats) return;

    if (stats->table_name) free(stats->table_name);

    if (stats->field_names) {
        for (int i = 0; i < stats->field_count; i++) {
            if (stats->field_names[i]) free(stats->field_names[i]);
        }
        free(stats->field_names);
    }

    free(stats);
}

void print_select_stats(QueryStats *stats) {
    if (!stats) return;

    printf("\nRequête SELECT analysée :\n");
    printf("- Table : %s\n", stats->table_name ? stats->table_name : "N/A");
    // N/A means Not Available or Not Applicable
    printf("- Nombre de champs : %d", stats->field_count);

    if (stats->field_count > 0 && stats->field_names) {
        printf(" (");
        for (int i = 0; i < stats->field_count; i++) {
            if (i > 0) printf(", ");
            printf("%s", stats->field_names[i]);
        }
        printf(")");
    }

    printf("\n- Clause WHERE : %s\n", stats->has_where ? "OUI" : "NON");
    printf("- Nombre de conditions : %d\n", stats->condition_count);
    printf("- Opérateurs logiques : %d\n", stats->logical_operators_count);
}

void print_insert_stats(QueryStats *stats) {
    if (!stats) return;

    printf("\nRequête INSERT analysée :\n");
    printf("- Table : %s\n", stats->table_name ? stats->table_name : "N/A");
    printf("- Nombre de valeurs : %d\n", stats->value_count);
}

void print_update_stats(QueryStats *stats) {
    if (!stats) return;

    printf("\nRequête UPDATE analysée :\n");
    printf("- Table : %s\n", stats->table_name ? stats->table_name : "N/A");
    printf("- Nombre de champs à modifier : %d\n", stats->field_count);
    printf("- Clause WHERE : %s\n", stats->has_where ? "OUI" : "NON");
}
