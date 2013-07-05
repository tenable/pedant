%{
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <err.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>

struct token;

#include "tokenizer.h"

extern int yylex(void);

void yyerror(const char *);
%}

%union {
	#include <stdbool.h>
	struct token *tok;
}

%code provides {
	bool parse(const char *src, size_t len);
}

/* XXX-MAK: Fix the precedence of the new 5.2 operators. */

/* Settings */
%start start
%expect 1

/* Keywords */
%token <tok> TOK_BREAK TOK_CONTINUE TOK_ELSE TOK_EXPORT TOK_FOR TOK_FOREACH TOK_FUNCTION TOK_GLOBAL TOK_IF TOK_IMPORT TOK_INCLUDE
%token <tok> TOK_LOCAL TOK_REPEAT TOK_RETURN TOK_UNTIL TOK_REP TOK_WHILE

/* Constants */
%token <tok> TOK_FALSE TOK_UNDEF TOK_TRUE

/* Operators */
%token <tok> TOK_TOK_SUBSTR_EQ TOK_TOK_SUBSTR_NE
%token <tok> TOK_REGEX_EQ TOK_REGEX_NE
%token <tok> TOK_CMP_EQ TOK_CMP_NE TOK_CMP_LE TOK_CMP_GE
%token <tok> TOK_ASS_EQ TOK_ADD_EQ TOK_SUB_EQ TOK_MUL_EQ TOK_DIV_EQ TOK_MOD_EQ TOK_SRL_EQ TOK_SRA_EQ TOK_SLL_EQ
%token <tok> TOK_OR TOK_AND TOK_NOT
%token <tok> TOK_BIT_OR TOK_BIT_XOR TOK_AMPERSAND TOK_BIT_SRA TOK_BIT_SRL TOK_BIT_SLL
%token <tok> TOK_CMP_LT TOK_CMP_GT
%token <tok> TOK_INCR TOK_DECR
%token <tok> TOK_EXP
%token <tok> TOK_ADD TOK_SUB TOK_MUL TOK_DIV TOK_MOD
%token <tok> TOK_BIT_NOT
%token <tok> TOK_PERIOD TOK_COMMA TOK_COLON TOK_SEMICOLON TOK_LPAREN TOK_RPAREN TOK_LBRACK TOK_RBRACK TOK_LBRACE TOK_RBRACE
%token <tok> TOK_AT_SIGN

/* Literals */
%token <tok> TOK_IDENT TOK_INTEGER TOK_DATA TOK_STRING

/* Miscellanea */
%token <tok> TOK_COMMENT TOK_UNRECOGNIZED

/* Precedence */
%right TOK_ASS_EQ TOK_ADD_EQ TOK_SUB_EQ TOK_MUL_EQ TOK_DIV_EQ TOK_MOD_EQ TOK_SLL_EQ TOK_SRA_EQ TOK_SRL_EQ
%left TOK_OR
%left TOK_AND
%nonassoc TOK_CMP_LT TOK_CMP_GT TOK_CMP_EQ TOK_CMP_NE TOK_CMP_GE TOK_CMP_LE TOK_SUBSTR_EQ TOK_SUBSTR_NE TOK_REGEX_EQ TOK_REGEX_NE
%left TOK_BIT_OR
%left TOK_BIT_XOR
%left TOK_AMPERSAND
%nonassoc TOK_BIT_SRA TOK_BIT_SRL TOK_BIT_SLL
%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV TOK_MOD
%nonassoc TOK_NOT
%nonassoc TOK_UMINUS TOK_BIT_NOT
%right TOK_EXP
%nonassoc TOK_INCR TOK_DECR
%nonassoc TOK_ARROW

/* Non-terminals */
%type <tok> arg args assign assign_exp block break call call_exp compound continue
%type <tok> decr decr_exp empty export expr field for foreach function global ident
%type <tok> idents if import include incr incr_exp indexes int ip local lval params
%type <tok> rep repeat return root roots simple start statement statements text undef
%type <tok> unrecognized while

%%

/******************************************************************************
 * Aggregate Statements
 ******************************************************************************/

start		: roots
		{  }
		| /* Blank */
		{  }
		;

roots		: root roots
		{  }
		| root
		{  }
		;

root		: export
		{  }
		| function
		{  }
		| statement
		{  }
		| unrecognized
		{  }
		;

statement	: simple
		{  }
		| compound
		{  }
		;

/******************************************************************************
 * Root Statements
 ******************************************************************************/

export		: TOK_EXPORT function
		{  }
		;

function	: TOK_FUNCTION ident TOK_LPAREN params TOK_RPAREN block
		{  }
		| TOK_FUNCTION ident TOK_LPAREN TOK_RPAREN block
		{  }
		;

simple		: assign
		{  }
		| break
		{  }
		| call
		{  }
		| continue
		{  }
		| decr
		{  }
		| empty
		{  }
		| global
		{  }
		| import
		{  }
		| include
		{  }
		| incr
		{  }
		| local
		{  }
		| rep
		{  }
		| return
		{  }
		;

compound	: block
		{  }
		| for
		{  }
		| foreach
		{  }
		| if
		{  }
		| repeat
		{  }
		| while
		{  }
		;

unrecognized	: TOK_UNRECOGNIZED
		{ warnx("UNRECOGNIZED TOKEN"); }
		;

/******************************************************************************
 * Simple Statements
 ******************************************************************************/

assign		: assign_exp TOK_SEMICOLON
		{  }
		;

break		: TOK_BREAK TOK_SEMICOLON
		{  }
		;

call		: call_exp TOK_SEMICOLON
		{  }
		;

continue	: TOK_CONTINUE TOK_SEMICOLON
		{  }
		;

decr		: decr_exp TOK_SEMICOLON
		{  }
		;

empty		: TOK_SEMICOLON
		{  }
		;

global		: TOK_GLOBAL idents TOK_SEMICOLON
		{  }
		;

incr		: incr_exp TOK_SEMICOLON
		{  }
		;

import		: TOK_IMPORT TOK_LPAREN text TOK_RPAREN TOK_SEMICOLON
		{  }
		;

include		: TOK_INCLUDE TOK_LPAREN text TOK_RPAREN TOK_SEMICOLON
		{  }
		;

local		: TOK_LOCAL idents TOK_SEMICOLON
		{  }
		;

rep		: call_exp TOK_REP expr TOK_SEMICOLON
		{  }
		;

return		: TOK_RETURN expr TOK_SEMICOLON
		{  }
		| TOK_RETURN TOK_SEMICOLON
		{  }
		;

/******************************************************************************
 * Compound Statements
 ******************************************************************************/

block		: TOK_LBRACE statements TOK_RBRACE
		{  }
		| TOK_LBRACE TOK_RBRACE
		{  }
		;

for		: TOK_FOR TOK_LPAREN field TOK_SEMICOLON expr TOK_SEMICOLON field TOK_RPAREN statement
		{  }
		;

foreach		: TOK_FOREACH ident TOK_LPAREN expr TOK_RPAREN statement
		{  }
		;

if		: TOK_IF TOK_LPAREN expr TOK_RPAREN statement
		{  }
		| TOK_IF TOK_LPAREN expr TOK_RPAREN statement TOK_ELSE statement
		{  }
		;

repeat		: TOK_REPEAT statement TOK_UNTIL expr TOK_SEMICOLON
		{  }
		;

while		: TOK_WHILE TOK_LPAREN expr TOK_RPAREN statement
		{  }
		;

/******************************************************************************
 * Expressions
 ******************************************************************************/

assign_exp	: lval TOK_ASS_EQ expr
		{  }
		| lval TOK_ADD_EQ expr
		{  }
		| lval TOK_SUB_EQ expr
		{  }
		| lval TOK_MUL_EQ expr
		{  }
		| lval TOK_DIV_EQ expr
		{  }
		| lval TOK_MOD_EQ expr
		{  }
		| lval TOK_SRL_EQ expr
		{  }
		| lval TOK_SRA_EQ expr
		{  }
		| lval TOK_SLL_EQ expr
		{  }
		;

call_exp	: ident TOK_LPAREN args TOK_RPAREN
		{  }
		| ident TOK_LPAREN TOK_RPAREN
		{  }
		;

decr_exp	: TOK_DECR lval
		{  }
		| lval TOK_DECR
		{  }
		;

incr_exp	: TOK_INCR lval
		{  }
		| lval TOK_INCR
		{  }
		;

expr		: TOK_LPAREN expr TOK_RPAREN
		{  }
		| expr TOK_AND expr
		{  }
		| TOK_NOT expr
		{  }
		| expr TOK_OR expr
		{  }
		| expr TOK_ADD expr
		{  }
		| expr TOK_SUB expr
		{  }
		| TOK_SUB expr %prec TOK_UMINUS
		{  }
		| TOK_BIT_NOT expr
		{  }
		| expr TOK_MUL expr
		{  }
		| expr TOK_EXP expr
		{  }
		| expr TOK_DIV expr
		{  }
		| expr TOK_MOD expr
		{  }
		| expr TOK_AMPERSAND expr
		{  }
		| expr TOK_BIT_XOR expr
		{  }
		| expr TOK_BIT_OR expr
		{  }
		| expr TOK_BIT_SRA expr
		{  }
		| expr TOK_BIT_SRL expr
		{  }
		| expr TOK_BIT_SLL expr
		{  }
		| incr_exp
		{  }
		| decr_exp
		{  }
		| expr TOK_SUBSTR_EQ expr
		{  }
		| expr TOK_SUBSTR_NE expr
		{  }
		| expr TOK_REGEX_EQ expr
		{  }
		| expr TOK_REGEX_NE expr
		{  }
		| expr TOK_CMP_LT expr
		{  }
		| expr TOK_CMP_GT expr
		{  }
		| expr TOK_CMP_EQ expr
		{  }
		| expr TOK_CMP_NE expr
		{  }
		| expr TOK_CMP_GE expr
		{  }
		| expr TOK_CMP_LE expr
		{  }
		| assign_exp
		{  }
		| text
		{  }
		| call_exp
		{  }
		| lval
		{  }
		| ip
		{  }
		| int
		{  }
		| undef
		{  }
		;

/******************************************************************************
 * Named Components
 ******************************************************************************/

arg		: ident TOK_COLON expr
		{  }
		| expr
		{  }
		;

lval		: ident indexes
		{  }
		| ident
		{  }
		;

/******************************************************************************
 * Anonymous Components
 ******************************************************************************/

args		: arg TOK_COMMA args
		{  }
		| arg
		{  }
		;

field		: assign_exp
		{  }
		| call_exp
		{  }
		| decr_exp
		{  }
		| incr_exp
		{  }
		| /* Blank */
		{  }
		;

idents		: ident TOK_COMMA idents
		{  }
		| ident
		{  }
		;

indexes		: TOK_LBRACK expr TOK_RBRACK indexes
		{  }
		| TOK_LBRACK expr TOK_RBRACK
		{  }
		;

params		: ident TOK_COMMA params
		{  }
		| ident
		{  }
		;

statements	: statement statements
		{  }
		| statement
		{  }
		;

/******************************************************************************
 * Literals
 ******************************************************************************/

ident		: TOK_IDENT
		{  }
		| TOK_REP
		{  }
		;

int		: TOK_INTEGER
		{  }
		| TOK_FALSE
		{  }
		| TOK_TRUE
		{  }
		;

ip		: int TOK_PERIOD int TOK_PERIOD int TOK_PERIOD int
		{  }
		;

text		: TOK_DATA
		{  }
		| TOK_STRING
		{  }
		;

undef		: TOK_UNDEF
		{  }
		;

%%

void yyerror(const char *msg)
{
}

bool parse(const char *src, size_t len)
{
	tokenizer_comments(false);

	tokenizer_load(src, len);

	int rc = yyparse();

	tokenizer_unload();

	return (rc == 0);
}
