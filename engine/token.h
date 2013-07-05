#ifndef TOKEN_H_
#define TOKEN_H_

#include <stdio.h>

#include "parser.h"

typedef enum yytokentype tok_id_t;

struct token_type
{
	const tok_id_t	 num;
	const char	*str;
};

typedef struct token
{
	const tok_id_t	 type;
	const fpos_t	 start;
	const size_t	 length;
} tok_t;

tok_t *token_new(tok_id_t type, fpos_t start, size_t len);
void token_free(tok_t *tok);
fpos_t token_line(const tok_t *tok);
fpos_t token_column(const tok_t *tok);
const char *token_type_name(const tok_t *tok);
void token_dump(const tok_t *tok, char *buf, size_t len);

#endif
