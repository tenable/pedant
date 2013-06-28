#ifndef TOKENIZER_H_
#define TOKENIZER_H_

#include <stdbool.h>

#include "token.h"

void tokenizer_comments(bool choice);
tok_t *tokenizer_get_one(void);
tok_t *tokenizer_get_all(void);
void tokenizer_load(char *src, size_t len);
void tokenizer_unload(void);

#endif
