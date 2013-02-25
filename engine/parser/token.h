#ifndef TOKEN_H_
#define TOKEN_H_

#include <stdint.h>

typedef uint32_t pos_t;

typedef struct
{
	const char	*source;
	const pos_t	 start;
	const pos_t	 end;
} tok_t;

tok_t	*token_new(const char *src, pos_t start, pos_t end);
void	 token_free(tok_t *tok);
pos_t	 token_line(tok_t *tok);
pos_t	 token_column(tok_t *tok);

#endif
