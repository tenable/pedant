#include <assert.h>
#include <err.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include "token.h"

extern const struct token_type types[];

tok_t *token_new(tok_id_t type, fpos_t start, size_t length)
{
	assert(type > 0);
	assert(length != 0);

	// XXX-MAK: Change to use pool allocation later.
	// Allocate space for the token.
	tok_t *tok = malloc(sizeof(*tok));
	if (tok == NULL)
		err(EXIT_FAILURE, "malloc() of token failed");

	// Initialize the temporary token on the stack.
	tok_t tmp = {type, start, length};

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

void token_dump(const tok_t *tok, char *buf, size_t length)
{
	assert(tok != NULL);
	assert(buf != NULL);
	assert(length > 0);

	snprintf(buf, length, "(%s %lu %lu)", token_type_name(tok), tok->start, tok->length);
}
