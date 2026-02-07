%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

extern int yylex();
extern int yylineno;
void yyerror(const char *s);

/* Global symbol table */
SymbolTable *symbol_table;

/* Global statistics */
QueryStats *current_stats;

/* Error handling */
int semantic_errors = 0;

/* Helper functions */
void semantic_error(const char *message);
int check_table_exists(const char *table_name);
int check_field_exists(const char *table_name, const char *field_name);
void add_field_to_stats(const char *field_name);

%}

%union {
    int ival;
    float fval;
    char *sval;
    int bval;
}

%type <sval> data_type

/* Token declarations */
%token <ival> INT_VAL
%token <fval> FLOAT_VAL
%token <sval> STRING_VAL IDENTIFIER
%token <bval> BOOL_VAL

%token SELECT FROM WHERE INSERT INTO VALUES CREATE TABLE UPDATE SET DELETE DROP
%token AND OR NOT
%token INT_TYPE FLOAT_TYPE VARCHAR_TYPE BOOL_TYPE
%token EQ NE LT GT LE GE
%token LPAREN RPAREN COMMA SEMICOLON ASTERISK
%token ERROR

/* Precedence and associativity */
%left OR
%left AND
%right NOT
%left EQ NE LT GT LE GE

%start program

%%

program:
    statement_list
    ;

statement_list:
    statement
    | statement_list statement
    ;

statement:
    create_table_stmt SEMICOLON {
        printf("Requête CREATE TABLE analysée avec succès.\n");
    }
    | insert_stmt SEMICOLON {
        print_insert_stats(current_stats);
        destroy_query_stats(current_stats);
        current_stats = NULL;
    }
    | select_stmt SEMICOLON {
        print_select_stats(current_stats);
        destroy_query_stats(current_stats);
        current_stats = NULL;
    }
    | update_stmt SEMICOLON {
        print_update_stats(current_stats);
        destroy_query_stats(current_stats);
        current_stats = NULL;
    }
    | delete_stmt SEMICOLON {
        printf("Requête DELETE analysée avec succès.\n");
    }
    | drop_table_stmt SEMICOLON {
        printf("Requête DROP TABLE analysée avec succès.\n");
    }
    | error SEMICOLON {
        yyerrok;
    }
    ;

/* CREATE TABLE statement */
create_table_stmt:
    CREATE TABLE IDENTIFIER {
        if (!add_table(symbol_table, $3)) {
            char error_msg[256];
            sprintf(error_msg, "La table '%s' existe déjà.", $3);
            semantic_error(error_msg);
        }
    } LPAREN field_def_list RPAREN {
        free($3);
    }
    ;

field_def_list:
    field_def
    | field_def_list COMMA field_def
    ;

field_def:
    IDENTIFIER data_type {
        /* Add field to the most recently created table */
        Table *last_table = symbol_table->tables;
        if (last_table) {
            DataType type;
            int varchar_size = 0;

            if (strcmp($2, "INT") == 0) type = TYPE_INT;
            else if (strcmp($2, "FLOAT") == 0) type = TYPE_FLOAT;
            else if (strcmp($2, "BOOL") == 0) type = TYPE_BOOL;
            else {
                type = TYPE_VARCHAR;
                varchar_size = 255; // Default size
            }

            add_field_to_table(symbol_table, last_table->name, $1, type, varchar_size);
        }
        free($1);
        if ($2) free($2);
    }
    | IDENTIFIER VARCHAR_TYPE LPAREN INT_VAL RPAREN {
        Table *last_table = symbol_table->tables;
        if (last_table) {
            add_field_to_table(symbol_table, last_table->name, $1, TYPE_VARCHAR, $4);
        }
        free($1);
    }
    ;

data_type:
    INT_TYPE { $$ = strdup("INT"); }
    | FLOAT_TYPE { $$ = strdup("FLOAT"); }
    | BOOL_TYPE { $$ = strdup("BOOL"); }
    ;

/* INSERT statement */
insert_stmt:
    INSERT INTO IDENTIFIER {
        current_stats = create_query_stats();
        current_stats->table_name = strdup($3);

        if (!check_table_exists($3)) {
            char error_msg[256];
            sprintf(error_msg, "La table '%s' n'existe pas.", $3);
            semantic_error(error_msg);
        }
    } VALUES LPAREN value_list RPAREN {
        // Check field count vs value count
        if (current_stats->table_name) {
            Table *table = find_table(symbol_table, current_stats->table_name);
            if (table && table->field_count != current_stats->value_count) {
                char error_msg[256];
                sprintf(error_msg, "INSERT INTO %s : %d valeurs fournies mais %d champs attendus.",
                        current_stats->table_name, current_stats->value_count, table->field_count);
                semantic_error(error_msg);
            }
        }
        free($3);
    }
    | INSERT INTO IDENTIFIER {
        current_stats = create_query_stats();
        current_stats->table_name = strdup($3);

        if (!check_table_exists($3)) {
            char error_msg[256];
            sprintf(error_msg, "La table '%s' n'existe pas.", $3);
            semantic_error(error_msg);
        }
    } LPAREN field_list RPAREN VALUES LPAREN value_list RPAREN {
        // Check field count vs value count
        if (current_stats->field_count != current_stats->value_count) {
            char error_msg[256];
            sprintf(error_msg, "INSERT INTO %s : %d valeurs fournies mais %d champs attendus.",
                    current_stats->table_name, current_stats->value_count, current_stats->field_count);
            semantic_error(error_msg);
        }
        free($3);
    }
    ;

/* SELECT statement */
select_stmt:
    SELECT {
        current_stats = create_query_stats();
    } field_list FROM IDENTIFIER {
        if (current_stats) {
            current_stats->table_name = strdup($5);
        }

        if (!check_table_exists($5)) {
            char error_msg[256];
            sprintf(error_msg, "La table '%s' n'existe pas.", $5);
            semantic_error(error_msg);
        } else {
            // Check field existence for SELECT after we have table name
            if (current_stats->field_names) {
                for (int i = 0; i < current_stats->field_count; i++) {
                    if (!check_field_exists($5, current_stats->field_names[i])) {
                        char error_msg[256];
                        sprintf(error_msg, "Le champ '%s' n'existe pas dans la table '%s'.",
                                current_stats->field_names[i], $5);
                        semantic_error(error_msg);
                    }
                }
            }
        }

        free($5);
    } opt_where_clause
    ;

opt_where_clause:
    /* empty */ {
        if (current_stats) {
            current_stats->has_where = 0;
        }
    }
    | WHERE condition {
        if (current_stats) {
            current_stats->has_where = 1;
        }
    }
    ;

/* UPDATE statement */
update_stmt:
    UPDATE IDENTIFIER {
        current_stats = create_query_stats();
        current_stats->table_name = strdup($2);
        current_stats->field_count = 0;

        if (!check_table_exists($2)) {
            char error_msg[256];
            sprintf(error_msg, "La table '%s' n'existe pas.", $2);
            semantic_error(error_msg);
        }
    } SET assignment_list WHERE condition {
        if (current_stats) {
            current_stats->has_where = 1;
        }
        free($2);
    }
    ;

assignment_list:
    assignment {
        if (current_stats) current_stats->field_count = 1;
    }
    | assignment_list COMMA assignment {
        if (current_stats) current_stats->field_count++;
    }
    ;

assignment:
    IDENTIFIER EQ value {
        if (current_stats && current_stats->table_name) {
            if (!check_field_exists(current_stats->table_name, $1)) {
                char error_msg[256];
                sprintf(error_msg, "Le champ '%s' n'existe pas dans la table '%s'.",
                        $1, current_stats->table_name);
                semantic_error(error_msg);
            }
        }
        free($1);
    }
    ;

/* DELETE statement */
delete_stmt:
    DELETE FROM IDENTIFIER WHERE condition {
        if (!check_table_exists($3)) {
            char error_msg[256];
            sprintf(error_msg, "La table '%s' n'existe pas.", $3);
            semantic_error(error_msg);
        }
        free($3);
    }
    | DELETE FROM IDENTIFIER {
        if (!check_table_exists($3)) {
            char error_msg[256];
            sprintf(error_msg, "La table '%s' n'existe pas.", $3);
            semantic_error(error_msg);
        }
        free($3);
    }
    ;

/* DROP TABLE statement */
drop_table_stmt:
    DROP TABLE IDENTIFIER {
        if (!check_table_exists($3)) {
            char error_msg[256];
            sprintf(error_msg, "La table '%s' n'existe pas.", $3);
            semantic_error(error_msg);
        } else {
            remove_table(symbol_table, $3);
        }
        free($3);
    }
    ;

/* Field list */
field_list:
    ASTERISK {
        if (current_stats) {
            current_stats->field_count = -1; // Special value for SELECT *
        }
    }
    | field_name_list
    ;

field_name_list:
    IDENTIFIER {
        if (current_stats) {
            current_stats->field_count = 1;
            add_field_to_stats($1);
        }
        free($1);
    }
    | field_name_list COMMA IDENTIFIER {
        if (current_stats) {
            current_stats->field_count++;
            add_field_to_stats($3);
        }
        free($3);
    }
    ;

/* Value list */
value_list:
    value {
        if (current_stats) current_stats->value_count = 1;
    }
    | value_list COMMA value {
        if (current_stats) current_stats->value_count++;
    }
    ;

value:
    INT_VAL
    | FLOAT_VAL
    | STRING_VAL { free($1); }
    | BOOL_VAL
    ;

/* Conditions */
condition:
    simple_condition {
        if (current_stats && current_stats->has_where) {
            current_stats->condition_count = 1;
        }
    }
    | condition AND condition {
        if (current_stats) current_stats->logical_operators_count++;
    }
    | condition OR condition {
        if (current_stats) current_stats->logical_operators_count++;
    }
    | NOT condition
    | LPAREN condition RPAREN
    ;

simple_condition:
    IDENTIFIER comparison_op value {
        if (current_stats && current_stats->table_name && !check_field_exists(current_stats->table_name, $1)) {
            char error_msg[256];
            sprintf(error_msg, "Le champ '%s' n'existe pas dans la table '%s'.",
                    $1, current_stats->table_name);
            semantic_error(error_msg);
        }
        free($1);
    }
    ;

comparison_op:
    EQ | NE | LT | GT | LE | GE
    ;

%%

/* Helper functions */
void semantic_error(const char *message) {
    printf("ERREUR SÉMANTIQUE ligne %d :\n  %s\n", yylineno, message);
    semantic_errors++;
}

int check_table_exists(const char *table_name) {
    return find_table(symbol_table, table_name) != NULL;
}

int check_field_exists(const char *table_name, const char *field_name) {
    Table *table = find_table(symbol_table, table_name);
    if (!table) return 0;
    return find_field_in_table(table, field_name) != NULL;
}

void add_field_to_stats(const char *field_name) {
    if (!current_stats) return;

    if (!current_stats->field_names) {
        current_stats->field_names = malloc(sizeof(char*));
    } else {
        current_stats->field_names = realloc(current_stats->field_names,
                                            sizeof(char*) * current_stats->field_count);
    }

    current_stats->field_names[current_stats->field_count - 1] = strdup(field_name);
}
