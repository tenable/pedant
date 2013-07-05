#include <assert.h>
#include <err.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "token.h"

const struct token_type types[] = {
	{TOK_ADD,		"ADD"},
	{TOK_ADD_EQ,		"ADD_EQ"},
	{TOK_AMPERSAND,		"AMPERSAND"},
	{TOK_AND,		"AND"},
	{TOK_ARROW,		"ARROW"},
	{TOK_ASS_EQ,		"ASS_EQ"},
	{TOK_AT_SIGN,		"AT_SIGN"},
	{TOK_BIT_NOT,		"BIT_NOT"},
	{TOK_BIT_OR,		"BIT_OR"},
	{TOK_BIT_SLL,		"BIT_SLL"},
	{TOK_BIT_SRA,		"BIT_SRA"},
	{TOK_BIT_SRL,		"BIT_SRL"},
	{TOK_BIT_XOR,		"BIT_XOR"},
	{TOK_BREAK,		"BREAK"},
	{TOK_CMP_EQ,		"CMP_EQ"},
	{TOK_CMP_GE,		"CMP_GE"},
	{TOK_CMP_GT,		"CMP_GT"},
	{TOK_CMP_LE,		"CMP_LE"},
	{TOK_CMP_LT,		"CMP_LT"},
	{TOK_CMP_NE,		"CMP_NE"},
	{TOK_COLON,		"COLON"},
	{TOK_COMMA,		"COMMA"},
	{TOK_COMMENT,		"COMMENT"},
	{TOK_CONTINUE,		"CONTINUE"},
	{TOK_DATA,		"DATA"},
	{TOK_DECR,		"DECR"},
	{TOK_DIV,		"DIV"},
	{TOK_DIV_EQ,		"DIV_EQ"},
	{TOK_ELSE,		"ELSE"},
	{TOK_EXP,		"EXP"},
	{TOK_EXPORT,		"EXPORT"},
	{TOK_FALSE,		"FALSE"},
	{TOK_FOR,		"FOR"},
	{TOK_FOREACH,		"FOREACH"},
	{TOK_FUNCTION,		"FUNCTION"},
	{TOK_GLOBAL,		"GLOBAL"},
	{TOK_IDENT,		"IDENT"},
	{TOK_IF,		"IF"},
	{TOK_IMPORT,		"IMPORT"},
	{TOK_INCLUDE,		"INCLUDE"},
	{TOK_INCR,		"INCR"},
	{TOK_INTEGER,		"INTEGER"},
	{TOK_LBRACE,		"LBRACE"},
	{TOK_LBRACK,		"LBRACK"},
	{TOK_LOCAL,		"LOCAL"},
	{TOK_LPAREN,		"LPAREN"},
	{TOK_MOD,		"MOD"},
	{TOK_MOD_EQ,		"MOD_EQ"},
	{TOK_MUL,		"MUL"},
	{TOK_MUL_EQ,		"MUL_EQ"},
	{TOK_NOT,		"NOT"},
	{TOK_OR,		"OR"},
	{TOK_PERIOD,		"PERIOD"},
	{TOK_RBRACE,		"RBRACE"},
	{TOK_RBRACK,		"RBRACK"},
	{TOK_REGEX_EQ,		"REGEX_EQ"},
	{TOK_REGEX_NE,		"REGEX_NE"},
	{TOK_REP,		"REP"},
	{TOK_REPEAT,		"REPEAT"},
	{TOK_RETURN,		"RETURN"},
	{TOK_RPAREN,		"RPAREN"},
	{TOK_SEMICOLON,		"SEMICOLON"},
	{TOK_SLL_EQ,		"SLL_EQ"},
	{TOK_SRA_EQ,		"SRA_EQ"},
	{TOK_SRL_EQ,		"SRL_EQ"},
	{TOK_STRING,		"STRING"},
	{TOK_SUB,		"SUB"},
	{TOK_SUBSTR_EQ,		"SUBSTR_EQ"},
	{TOK_SUBSTR_NE,		"SUBSTR_NE"},
	{TOK_SUB_EQ,		"SUB_EQ"},
	{TOK_TRUE,		"TRUE"},
	{TOK_UMINUS,		"UMINUS"},
	{TOK_UNDEF,		"UNDEF"},
	{TOK_UNRECOGNIZED,	"UNRECOGNIZED"},
	{TOK_UNTIL,		"UNTIL"},
	{TOK_WHILE,		"WHILE"},

	{-1,			NULL}
};

tok_t *token_new(tok_id_t type, fpos_t start, size_t len)
{
	assert(type >= 0);
	assert(len != 0);

	// XXX-MAK: Change to use pool allocation later.
	// Allocate space for the token.
	tok_t *tok = malloc(sizeof(*tok));
	if (tok == NULL)
		err(EXIT_FAILURE, "malloc() of token failed");

	// Initialize the temporary token on the stack.
	tok_t tmp = {type, start, len};

	// Copy the temporary token to the heap.
	memcpy(tok, &tmp, sizeof(*tok));

	return tok;
}

void token_free(tok_t *tok)
{
	assert(tok != NULL);

	free(tok);
}

fpos_t token_line(const tok_t *tok)
{
	assert(tok != NULL);

	return 0;
}

fpos_t token_column(const tok_t *tok)
{
	assert(tok != NULL);

	return 0;
}

const char *token_type_name(const tok_t *tok)
{
	assert(tok != NULL);

	for (int i = 0; types[i].str != NULL; i++)
	{
		if (types[i].num == tok->type)
		{
			assert(types[i].str != NULL);
			return types[i].str;
		}
	}

	// You should always find the type.
	assert(false);

	return NULL;
}

void token_dump(const tok_t *tok, char *buf, size_t len)
{
	assert(tok != NULL);
	assert(buf != NULL);
	assert(len > 0);

	snprintf(buf, len, "(%s %lu %lu)", token_type_name(tok), tok->start, tok->length);
}
