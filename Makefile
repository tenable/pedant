all: core/pedant.c
	clang -Wall -o pedant core/pedant.c
