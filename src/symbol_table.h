#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Data types
typedef enum {
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_VARCHAR,
    TYPE_BOOL
} DataType;

// Field structure
typedef struct Field {
    char *name;
    DataType type;
    int varchar_size;  // For VARCHAR(n)
    struct Field *next;
} Field;

// Table structure
typedef struct Table {
    char *name;
    Field *fields;
    int field_count;
    struct Table *next;
} Table;

// Symbol table structure
typedef struct {
    Table *tables;
    int table_count;
} SymbolTable;

// Function prototypes
SymbolTable* create_symbol_table();
void destroy_symbol_table(SymbolTable *st);
int add_table(SymbolTable *st, const char *table_name);
int remove_table(SymbolTable *st, const char *table_name);
int add_field_to_table(SymbolTable *st, const char *table_name, const char *field_name, DataType type, int varchar_size);
Table* find_table(SymbolTable *st, const char *table_name);
Field* find_field_in_table(Table *table, const char *field_name);
void print_symbol_table(SymbolTable *st);
const char* type_to_string(DataType type);

// Statistics structure
typedef struct {
    char *table_name;
    int field_count;
    char **field_names;
    int has_where;
    int condition_count;
    int logical_operators_count;
    int value_count;
} QueryStats;

QueryStats* create_query_stats();
void destroy_query_stats(QueryStats *stats);
void print_select_stats(QueryStats *stats);
void print_insert_stats(QueryStats *stats);
void print_update_stats(QueryStats *stats);

#endif
