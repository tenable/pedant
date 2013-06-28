%{
#include <assert.h>
#include <string.h>

#include "tokenizer.h"

static int make_token(tok_id_t);

static fpos_t position = 0;
static bool emit_comments = false;
static tok_t *yylval = NULL;

static YY_BUFFER_STATE yybuf = NULL;

extern int yyleng;
extern int yylex(void);
%}

%option noyywrap
%option nounput
%option noinput

ident			[_[:alpha:]][_[:alnum:]]*

decdigits		[[:digit:]]+
octdigits		[0-7]+
hexdigits		[[:xdigit:]]+

data			(\\.|[^'\\])*
string			[^\"]*

comment			#[^\r\n]*
whitespace		[[:space:]]+

%%

"break"			return make_token(TOK_BREAK);
"continue"		return make_token(TOK_CONTINUE);
"else"			return make_token(TOK_ELSE);
"export"		return make_token(TOK_EXPORT);
"for"			return make_token(TOK_FOR);
"foreach"		return make_token(TOK_FOREACH);
"function"		return make_token(TOK_FUNCTION);
"global_var"		return make_token(TOK_GLOBAL);
"if"			return make_token(TOK_IF);
"import"		return make_token(TOK_IMPORT);
"include"		return make_token(TOK_INCLUDE);
"local_var"		return make_token(TOK_LOCAL);
"repeat"		return make_token(TOK_REPEAT);
"return"		return make_token(TOK_RETURN);
"until"			return make_token(TOK_UNTIL);
"x"			return make_token(TOK_REP);
"while"			return make_token(TOK_WHILE);

"FALSE"			return make_token(TOK_FALSE);
"NULL"			return make_token(TOK_UNDEF);
"TRUE"			return make_token(TOK_TRUE);

"><"			return make_token(TOK_SUBSTR_EQ);
">!<"			return make_token(TOK_SUBSTR_NE);

"=~"			return make_token(TOK_REGEX_EQ);
"!~"			return make_token(TOK_REGEX_NE);

"=="			return make_token(TOK_CMP_EQ);
"!="			return make_token(TOK_CMP_NE);
"<="			return make_token(TOK_CMP_LE);
">="			return make_token(TOK_CMP_GE);

"="			return make_token(TOK_ASS_EQ);
"+="			return make_token(TOK_ADD_EQ);
"-="			return make_token(TOK_SUB_EQ);
"*="			return make_token(TOK_MUL_EQ);
"/="			return make_token(TOK_DIV_EQ);
"%="			return make_token(TOK_MOD_EQ);
">>="			return make_token(TOK_SRL_EQ);
">>>="			return make_token(TOK_SRA_EQ);
"<<="			return make_token(TOK_SLL_EQ);

"||"			return make_token(TOK_OR);
"&&"			return make_token(TOK_AND);
"!"			return make_token(TOK_NOT);

"|"			return make_token(TOK_BIT_OR);
"^"			return make_token(TOK_BIT_XOR);
">>>"			return make_token(TOK_BIT_SRA);
">>"			return make_token(TOK_BIT_SRL);
"<<"			return make_token(TOK_BIT_SLL);

"<"			return make_token(TOK_CMP_LT);
">"			return make_token(TOK_CMP_GT);

"++"			return make_token(TOK_INCR);
"--"			return make_token(TOK_DECR);

"**"			return make_token(TOK_EXP);

"+"			return make_token(TOK_ADD);
"-"			return make_token(TOK_SUB);
"*"			return make_token(TOK_MUL);
"/"			return make_token(TOK_DIV);
"%"			return make_token(TOK_MOD);

"~"			return make_token(TOK_BIT_NOT);

"."			return make_token(TOK_PERIOD);
","			return make_token(TOK_COMMA);
":"			return make_token(TOK_COLON);
";"			return make_token(TOK_SEMICOLON);
"("			return make_token(TOK_LPAREN);
")"			return make_token(TOK_RPAREN);
"["			return make_token(TOK_LBRACK);
"]"			return make_token(TOK_RBRACK);
"{"			return make_token(TOK_LBRACE);
"}"			return make_token(TOK_RBRACE);

"@"			return make_token(TOK_AT_SIGN);
"&"			return make_token(TOK_AMPERSAND);

{ident}			return make_token(TOK_IDENT);

0[xX]{hexdigits}	return make_token(TOK_INTEGER);
0{octdigits}		return make_token(TOK_INTEGER);
{decdigits}		return make_token(TOK_INTEGER);

'{data}'		return make_token(TOK_DATA);
\"{string}\"		return make_token(TOK_STRING);

{comment}		{
				if (emit_comments)
					return make_token(TOK_COMMENT);
				else
					position += yyleng;
			}

{whitespace}		position += yyleng;

.			return make_token(TOK_UNRECOGNIZED);

%%

/******************************************************************************
 * Private Functions
 ******************************************************************************/

static int make_token(tok_id_t type)
{
	// Ensure that someone has consumed the previous token.
	assert(yylval == NULL);

	// Produce a new token.
	yylval = token_new(type, position, yyleng);
	position += yyleng;

	return type;
}

static tok_t *read_token(void)
{
	// Ensure that nobody has consumed the previous token.
	assert(yylval != NULL);

	// Consume the token.
	tok_t *tok = yylval;
	yylval = NULL;

	return tok;
}

/******************************************************************************
 * Public Functions
 ******************************************************************************/

void tokenizer_comments(bool choice)
{
	emit_comments = choice;
}

tok_t *tokenizer_get_one(void)
{
	tok_id_t id = yylex();
	if (id == 0)
		return NULL;

	return read_token();
}

tok_t *tokenizer_get_all(void)
{
	// XXX-MAK: Fill in later.
	return NULL;
}

void tokenizer_load(char *src, size_t len)
{
	assert(yybuf == NULL);
	assert(src != NULL);
	assert(len >= 0);

	yybuf = yy_scan_bytes(src, len);

	yylval = NULL;
	position = 0;
}

void tokenizer_unload(void)
{
	assert(yybuf != NULL);

	yy_delete_buffer(yybuf);

	yybuf = NULL;
}
