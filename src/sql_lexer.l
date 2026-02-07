%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sql_parser.tab.h"

extern int yylineno;
void yyerror(const char *s);

%}

%option yylineno
%option noyywrap

/* Regular expressions for tokens */
DIGIT       [0-9]
LETTER      [a-zA-Z]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT}|_)*
INTEGER     [+-]?{DIGIT}+
FLOAT       [+-]?{DIGIT}+\.{DIGIT}+
STRING      '([^'\\]|\\.)*'|\"([^\"\\]|\\.)*\"

%%

    /* SQL Keywords (case-insensitive) */
(?i:"SELECT")        { return SELECT; }
(?i:"FROM")          { return FROM; }
(?i:"WHERE")         { return WHERE; }
(?i:"INSERT")        { return INSERT; }
(?i:"INTO")          { return INTO; }
(?i:"VALUES")        { return VALUES; }
(?i:"CREATE")        { return CREATE; }
(?i:"TABLE")         { return TABLE; }
(?i:"UPDATE")        { return UPDATE; }
(?i:"SET")           { return SET; }
(?i:"DELETE")        { return DELETE; }
(?i:"DROP")          { return DROP; }
(?i:"AND")           { return AND; }
(?i:"OR")            { return OR; }
(?i:"NOT")           { return NOT; }

    /* Data types (case-insensitive) */
(?i:"INT")           { return INT_TYPE; }
(?i:"FLOAT")         { return FLOAT_TYPE; }
(?i:"VARCHAR")       { return VARCHAR_TYPE; }
(?i:"BOOL")          { return BOOL_TYPE; }

    /* Boolean values (case-insensitive) */
(?i:"TRUE")          { yylval.bval = 1; return BOOL_VAL; }
(?i:"FALSE")         { yylval.bval = 0; return BOOL_VAL; }

    /* Operators */
"="             { return EQ; }
"!="            { return NE; }
"<"             { return LT; }
">"             { return GT; }
"<="            { return LE; }
">="            { return GE; }

    /* Punctuation */
"("             { return LPAREN; }
")"             { return RPAREN; }
","             { return COMMA; }
";"             { return SEMICOLON; }
"*"             { return ASTERISK; }

    /* Literals */
{INTEGER}       { yylval.ival = atoi(yytext); return INT_VAL; }
{FLOAT}         { yylval.fval = atof(yytext); return FLOAT_VAL; }
{STRING}        {
                    /* Remove quotes */
                    yylval.sval = malloc(strlen(yytext) - 1);
                    strncpy(yylval.sval, yytext + 1, strlen(yytext) - 2);
                    yylval.sval[strlen(yytext) - 2] = '\0';
                    return STRING_VAL;
                }
{IDENTIFIER}    {
                    yylval.sval = malloc(strlen(yytext) + 1);
                    strcpy(yylval.sval, yytext);
                    return IDENTIFIER;
                }

    /* Comments */
"--".*          { /* Single line comment, ignore */ }
"/*"([^*]|"*"[^/])*"*/" { /* Multi-line comment, ignore */ }

    /* Whitespace */
[ \t]+          { /* Ignore whitespace */ }
\n              { /* Ignore newlines */ }

    /* Error handling */
.               {
                    printf("ERREUR LEXICALE ligne %d : Caractère invalide '%s'\n", yylineno, yytext);
                    return ERROR;
                }

%%

void yyerror(const char *s) {
    printf("ERREUR SYNTAXIQUE ligne %d : %s\n", yylineno, s);
}