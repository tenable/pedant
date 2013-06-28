#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <err.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>

#include "tokenizer.h"

void tokenize(const char *path)
{
	tokenizer_comments(true);

	int fd = open(path, O_RDONLY);
	if (fd == -1)
		err(EXIT_FAILURE, "Failed to open '%s'", path);

	struct stat sb;
	fstat(fd, &sb);

	void *mm = mmap(NULL, sb.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
	if (mm == NULL)
		err(EXIT_FAILURE, "Failed to mmap '%s'", path);

	tokenizer_load(mm, sb.st_size);

	tok_t *tok;
	char buf[32];
	while ((tok = tokenizer_get_one()) != NULL)
	{
		token_dump(tok, buf, sizeof(buf));
		puts(buf);
		free(tok);
	}

	if (munmap(mm, sb.st_size) == -1)
		err(EXIT_FAILURE, "Failed to munmap '%s'", path);

	tokenizer_unload();
	close(fd);
}


int main(int argc, const char **argv, const char **envp)
{
	for (int i = 1; i < argc; i++)
		tokenize(argv[i]);
	fflush(stdout);

	return EXIT_SUCCESS;
}
