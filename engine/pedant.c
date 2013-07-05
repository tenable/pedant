#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "parser.h"

void parsify(const char *path)
{
	int fd = open(path, O_RDONLY);
	if (fd == -1)
		err(EXIT_FAILURE, "Failed to open '%s'", path);

	struct stat sb;
	fstat(fd, &sb);

	void *mm = mmap(NULL, sb.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
	if (mm == NULL)
		err(EXIT_FAILURE, "Failed to mmap '%s'", path);

	bool res = parse(mm, sb.st_size);

	if (munmap(mm, sb.st_size) == -1)
		err(EXIT_FAILURE, "Failed to munmap '%s'", path);

	close(fd);

	if (!res)
		printf("Failed to parse: %s\n", path);
}

int main(int argc, const char **argv, const char **envp)
{
	for (int i = 1; i < argc; i++)
		parsify(argv[i]);
	fflush(stdout);

	return EXIT_SUCCESS;
}
