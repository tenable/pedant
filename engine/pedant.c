#include <err.h>
#include <stdlib.h>

#include "tokenizer.h"

void tokenize(const char *path)
{
	tokenizer_comments(true);

	FILE *f = fopen(path, "r");
	if (f == NULL)
		err(EXIT_FAILURE, "Failed to open '%s'", path);

	tokenizer_load(fopen(path, "r"));

	tok_t *tok;
	char buf[32];
	while ((tok = tokenizer_get_one()) != NULL)
	{
		token_dump(tok, buf, sizeof(buf));
		printf("[%p] %s\n", tok, buf);
	}

	tokenizer_unload();
}

void parse(const char *path)
{
	tokenizer_comments(false);

	FILE *f = fopen(path, "r");
	if (f == NULL)
		err(EXIT_FAILURE, "Failed to open '%s'", path);

	tokenizer_load(fopen(path, "r"));

	parser_run();

	tokenizer_unload();
}

int main(int argc, const char **argv, const char **envp)
{
	for (int i = 1; i < argc; i++)
	{
		tokenize(argv[i]);
		parse(argv[i]);
	}

	return EXIT_SUCCESS;
}
