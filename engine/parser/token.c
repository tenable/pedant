#include <err.h>
#include <stdlib.h>
#include <string.h>

#include "token.h"

tok_t *token_new(const char *src, pos_t start, pos_t end)
{
	// XXX-MAK: Change to use pool allocation later.
	// Allocate space for the token.
	tok_t *tok = malloc(sizeof(*tok));
	if (tok == NULL)
		err(EXIT_FAILURE, "malloc() of token failed");

	// Initialize the temporary token on the stack.
	tok_t tmp = {src, start, end};

	// Copy the temporary token to the heap.
	memcpy(tok, &tmp, sizeof(*tok));

	return tok;
}

void token_free(tok_t *tok)
{
	free(tok);
}

pos_t token_line(tok_t *tok)
{
	return 0;
}

pos_t token_column(tok_t *tok)
{
	return 0;
}
