%{
#include <stdint.h>
#include <stdio.h>

extern int yylex(void);
%}

%union {
	uint32_t	 num;
	char		*str;
}

%token BREAK CONTINUE ELSE EXPORT FOR FOREACH FUNCTION GLOBAL IF IMPORT INCLUDE
%token LOCAL REPEAT RETURN UNTIL REP WHILE

%token FALSE UNDEF TRUE

%token SUBSTR_EQ SUBSTR_NE

%token REGEX_EQ REGEX_NE

%token CMP_EQ CMP_NE CMP_LE CMP_GE

%token ASS_EQ ADD_EQ SUB_EQ MUL_EQ DIV_EQ MOD_EQ SRL_EQ SRA_EQ SLL_EQ

%token OR AND NOT

%token BIT_OR BIT_XOR BIT_AND BIT_SRA BIT_SRL BIT_SLL

%token CMP_LT CMP_GT

%token INCR DECR

%token EXP

%token ADD SUB MUL DIV MOD

%token BIT_NOT

%token PERIOD COMMA COLON SEMICOLON LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE

%token IDENT INTEGER DATA STRING

%type	<num> INTEGER
%type	<str> IDENT DATA STRING

%start root

%%

root	: /* empty */
	| root assign
	;

assign	: IDENT ASS_EQ INTEGER SEMICOLON
	{
	  printf("%s = %d;\n", $1, $3);
	}
	| IDENT ASS_EQ DATA SEMICOLON
	{
	  printf("%s = %s;\n", $1, $3);
	}
	| IDENT ASS_EQ STRING SEMICOLON
	{
	  printf("%s = %s;\n", $1, $3);
	}

%%

void yyerror(const char *msg)
{
	printf("%s\n", msg);
}
