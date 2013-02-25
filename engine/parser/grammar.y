%{
#include <stdint.h>
#include <stdio.h>

#include "token.h"

extern int yylex(void);
%}

%union {
	tok_t	*tok;
}

/* Settings */
%start start
%expect 1

/* Keywords */
%token BREAK CONTINUE ELSE EXPORT FOR FOREACH FUNCTION GLOBAL IF IMPORT INCLUDE
%token LOCAL REPEAT RETURN UNTIL REP WHILE

/* Constants */
%token FALSE UNDEF TRUE

/* Operators */
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

/* Literals */
%token IDENT INTEGER DATA STRING

%%

/******************************************************************************
 * Aggregate Statements
 ******************************************************************************/

start		: roots
		{
		}
		| /* Blank */
		{
		}
		;

roots		: root roots
		{
		}
		;

root		: export
		{
		}
		| function
		{
		}
		| statement
		{
		}
		;

statement	: simple
		{
		}
		| compound
		{
		}
		;

/******************************************************************************
 * Root Statements
 ******************************************************************************/

export		: EXPORT function
		{
		}
		;

function	: FUNCTION ident LPAREN params RPAREN block
		{
		}
		| FUNCTION ident LPAREN RPAREN block
		{
		}
		;

simple		: assign
		{
		}
		| break
		{
		}
		| call
		{
		}
		| continue
		{
		}
		| decr
		{
		}
		| empty
		{
		}
		| global
		{
		}
		| import
		{
		}
		| include
		{
		}
		| incr
		{
		}
		| local
		{
		}
		| rep
		{
		}
		| return
		{
		}
		;

compound	: block
		{
		}
		| for
		{
		}
		| foreach
		{
		}
		| if
		{
		}
		| repeat
		{
		}
		| while
		{
		}
		;

/******************************************************************************
 * Simple Statements
 ******************************************************************************/

assign		: assign_exp SEMICOLON
		{
		}
		;

break		: BREAK SEMICOLON
		{
		}
		;

call		: call_exp SEMICOLON
		{
		}
		;

continue	: CONTINUE SEMICOLON
		{
		}
		;

decr		: decr_exp SEMICOLON
		{
		}
		;

empty		: SEMICOLON
		{
		}
		;

global		: GLOBAL idents SEMICOLON
		{
		}
		;

incr		: incr_exp SEMICOLON
		{
		}
		;

import		: IMPORT LPAREN text RPAREN SEMICOLON
		{
		}
		;

include		: INCLUDE LPAREN text RPAREN SEMICOLON
		{
		}
		;

local		: LOCAL idents SEMICOLON
		{
		}
		;

rep		: call_exp REP expr SEMICOLON
		{
		}
		;

return		: RETURN expr SEMICOLON
		{
		}
		| RETURN SEMICOLON
		{
		}
		;

/******************************************************************************
 * Compound Statements
 ******************************************************************************/

block		: LBRACE statements RBRACE
		{
		}
		| LBRACE RBRACE
		{
		}
		;

for		: FOR LPAREN field SEMICOLON expr SEMICOLON field RPAREN statement
		{
		}
		;

foreach		: FOREACH ident LPAREN expr RPAREN statement
		{
		}
		;

if		: IF LPAREN expr RPAREN statement
		{
		}
		| IF LPAREN expr RPAREN statement ELSE statement
		{
		}
		;

repeat		: REPEAT statement UNTIL expr SEMICOLON
		{
		}
		;

while		: WHILE LPAREN expr RPAREN statement
		{
		}
		;

/******************************************************************************
 * Expressions
 ******************************************************************************/

assign_exp	: lval ASS_EQ expr
		{
		}
		| lval ADD_EQ expr
		{
		}
		| lval SUB_EQ expr
		{
		}
		| lval MUL_EQ expr
		{
		}
		| lval DIV_EQ expr
		{
		}
		| lval MOD_EQ expr
		{
		}
		| lval SRL_EQ expr
		{
		}
		| lval SRA_EQ expr
		{
		}
		| lval SLL_EQ expr
		{
		}
		;

call_exp	: ident LPAREN args RPAREN
		{
		}
		| ident LPAREN RPAREN
		{
		}
		;

decr_exp	: DECR lval
		{
		}
		| lval DECR
		{
		}
		;

incr_exp	: INCR lval
		{
		}
		| lval INCR
		{
		}
		;

expr		: LPAREN expr RPAREN
		{
		}
		| expr AND expr
		{
		}
		| NOT expr
		{
		}
		| expr OR expr
		{
		}
		| expr ADD expr
		{
		}
		| expr SUB expr
		{
		}
		| SUB expr =UMINUS
		{
		}
		| BIT_NOT expr
		{
		}
		| expr MUL expr
		{
		}
		| expr EXP expr
		{
		}
		| expr DIV expr
		{
		}
		| expr MOD expr
		{
		}
		| expr BIT_AND expr
		{
		}
		| expr BIT_XOR expr
		{
		}
		| expr BIT_OR expr
		{
		}
		| expr BIT_SRA expr
		{
		}
		| expr BIT_SRL expr
		{
		}
		| expr BIT_SLL expr
		{
		}
		| incr_exp
		{
		}
		| decr_exp
		{
		}
		| expr SUBSTR_EQ expr
		{
		}
		| expr SUBSTR_NE expr
		{
		}
		| expr REGEX_EQ expr
		{
		}
		| expr REGEX_NE expr
		{
		}
		| expr CMP_LT expr
		{
		}
		| expr CMP_GT expr
		{
		}
		| expr CMP_EQ expr
		{
		}
		| expr CMP_NE expr
		{
		}
		| expr CMP_GE expr
		{
		}
		| expr CMP_LE expr
		{
		}
		| assign_exp
		{
		}
		| text
		{
		}
		| call_exp
		{
		}
		| lval
		{
		}
		| ip
		{
		}
		| int
		{
		}
		| undef
		{
		}
		;

/******************************************************************************
 * Named Components
 ******************************************************************************/

arg		: ident COLON expr
		{
		}
		| expr
		{
		}
		;

lval		: ident indexes
		{
		}
		| ident
		{
		}
		;

/******************************************************************************
 * Anonymous Components
 ******************************************************************************/

args		: arg COMMA args
		{
		}
		| arg
		{
		}
		;

field		: assign_exp
		{
		}
		| call_exp
		{
		}
		| decr_exp
		{
		}
		| incr_exp
		{
		}
		| /* Blank */
		{
		}
		;

idents		: ident COMMA idents
		{
		}
		| ident
		{
		}
		;

indexes		: LBRACK expr RBRACK indexes
		{
		}
		| LBRACK expr RBRACK
		{
		}
		;

params		: ident COMMA params
		{
		}
		| ident
		{
		}
		;

statements	: statement statements
		{
		}
		| statement
		{
		}
		;

/******************************************************************************
 * Literals
 ******************************************************************************/

ident		: IDENT
		{
		}
		| REP
		{
		}
		;

int		: INT_DEC
		{
		}
		| INT_HEX
		{
		}
		| INT_OCT
		{
		}
		| FALSE
		{
		}
		| TRUE
		{
		}
		;

ip		: int PERIOD int PERIOD int PERIOD int
		{
		}
		;

text		: DATA
		{
		}
		| STRING
		{
		}
		;

undef		: UNDEF
		{
		}
		;

%%

void yyerror(const char *msg)
{
	printf("%s\n", msg);
}
