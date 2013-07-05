################################################################################
# Settings
################################################################################

# These are things you may want to adjust.
prefix=/usr/local/pedant

# These are things you can hopefully leave alone.
CC=clang
CFLAGS=-Wall -std=c99 -g -Wstrict-prototypes
INSTALL=install -p
LDFLAGS=
MAKE=make -e

################################################################################
# Top-Level Targets
################################################################################

all: engine

install: engine-install check-install test-install

clean: engine-clean

################################################################################
# Engine
################################################################################

.PHONY: engine
engine: parser tokenizer pedant.o
	$(CC) $(LDFLAGS) -o pedant *.o

.PHONY: engine-install
engine-install:
	$(INSTALL) -m 0755 pedant $(prefix)/bin

.PHONY: engine-clean
engine-clean:
	rm -f *.o
	rm -f tokenizer.c
	rm -f parser.[ch]

################################################################################
# Engine :: Command Line Interface
################################################################################



################################################################################
# Engine :: Parser
################################################################################

.PHONY: parser
parser: parser.o

parser.o: parser.y
	bison -d -o parser.c $<
	$(CC) $(CFLAGS) -c -o $@ parser.c

################################################################################
# Engine :: Tokenizer
################################################################################

.PHONY: tokenizer
tokenizer: token.o tokenizer.o

tokenizer.o: tokenizer.l
	# Note: -o cannot have a space before the path.
	flex -otokenizer.c $<
	$(CC) $(CFLAGS) -c -o $@ tokenizer.c

################################################################################
# Scripts
################################################################################

check-install:
	$(INSTALL) -m 0755 -d $(prefix)/share/checks
	$(INSTALL) -m 0644 checks/* $(prefix)/share/checks

test-install:
	$(INSTALL) -m 0755 -d $(prefix)/share/tests
	$(INSTALL) -m 0644 tests/* $(prefix)/share/tests

################################################################################
# Patterns
################################################################################

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^
