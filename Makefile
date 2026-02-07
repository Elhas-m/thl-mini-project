# Makefile for GLSimpleSQL Interpreter
# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -g
FLEX = flex
BISON = bison

# Directories
SRC_DIR = src
BUILD_DIR = build
BIN_DIR = bin

# Target executable
TARGET = $(BIN_DIR)/glsimplesql

# Source files
LEXER_SRC = $(SRC_DIR)/sql_lexer.l
PARSER_SRC = $(SRC_DIR)/sql_parser.y
MAIN_SRC = $(SRC_DIR)/main.c
SYMBOL_TABLE_SRC = $(SRC_DIR)/symbol_table.c
SYMBOL_TABLE_HDR = $(SRC_DIR)/symbol_table.h

# Generated files
LEXER_C = $(BUILD_DIR)/lex.yy.c
PARSER_C = $(BUILD_DIR)/sql_parser.tab.c
PARSER_H = $(BUILD_DIR)/sql_parser.tab.h

# Object files
LEXER_O = $(BUILD_DIR)/lex.yy.o
PARSER_O = $(BUILD_DIR)/sql_parser.tab.o
MAIN_O = $(BUILD_DIR)/main.o
SYMBOL_TABLE_O = $(BUILD_DIR)/symbol_table.o

# All object files
OBJS = $(PARSER_O) $(LEXER_O) $(MAIN_O) $(SYMBOL_TABLE_O)

# Default target
all: directories $(TARGET)

# Create necessary directories
directories:
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(BIN_DIR)

# Build the executable
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) -lfl

# Compile parser
$(PARSER_C) $(PARSER_H): $(PARSER_SRC)
	$(BISON) -d -o $(PARSER_C) $(PARSER_SRC)

$(PARSER_O): $(PARSER_C) $(PARSER_H) $(SYMBOL_TABLE_HDR)
	$(CC) $(CFLAGS) -c $(PARSER_C) -o $@ -I$(SRC_DIR) -I$(BUILD_DIR)

# Compile lexer
$(LEXER_C): $(LEXER_SRC)
	$(FLEX) -o $(LEXER_C) $(LEXER_SRC)

$(LEXER_O): $(LEXER_C) $(PARSER_H)
	$(CC) $(CFLAGS) -c $(LEXER_C) -o $@ -I$(BUILD_DIR)

# Compile main
$(MAIN_O): $(MAIN_SRC) $(SYMBOL_TABLE_HDR) $(PARSER_H)
	$(CC) $(CFLAGS) -c $(MAIN_SRC) -o $@ -I$(SRC_DIR) -I$(BUILD_DIR)

# Compile symbol table
$(SYMBOL_TABLE_O): $(SYMBOL_TABLE_SRC) $(SYMBOL_TABLE_HDR)
	$(CC) $(CFLAGS) -c $(SYMBOL_TABLE_SRC) -o $@ -I$(SRC_DIR)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)
	rm -f *~ $(SRC_DIR)/*~

# Run the interpreter (interactive mode)
run: $(TARGET)
	./$(TARGET)

# Run with a test file
test: $(TARGET)
	@echo "Running test file..."
	./$(TARGET) tests/test.sql

# Display help
help:
	@echo "GLSimpleSQL Interpreter - Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  all       - Build the project (default)"
	@echo "  clean     - Remove all build artifacts"
	@echo "  run       - Build and run in interactive mode"
	@echo "  test      - Build and run with test.sql file"
	@echo "  help      - Display this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make              # Build the project"
	@echo "  make clean        # Clean build files"
	@echo "  make run          # Run interactive mode"
	@echo "  ./bin/glsimplesql myfile.sql  # Run with a file"

.PHONY: all clean run test help directories
