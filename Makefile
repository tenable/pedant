################################################################################
# Settings
################################################################################

# These are things you may want to adjust.
prefix=/usr/local/pedant

# These are things you can hopefully leave alone.
CC=clang
CFLAGS=-Wall -std=c99
INSTALL=install -p
LDFLAGS=
MAKE=make -e

################################################################################
# Top-Level Targets
################################################################################

CFLAGS+=-D CHECK_DIR='"$(prefix)/share/checks"'

all: engine

install: engine-install check-install test-install

clean: engine-clean

################################################################################
# Engine
################################################################################

.PHONY: engine
engine: engine/pedant.o tokenizer
	@echo [LD] pedant
	@$(CC) $(LDFLAGS) -o pedant engine/*.o engine/tokenizer/*.o

.PHONY: engine-install
engine-install:
	$(INSTALL) -m 0755 pedant $(prefix)/bin

.PHONY: engine-clean
engine-clean:
	@echo [RM] engine/*.o
	@rm -f engine/*.o

	@echo [RM] engine/*/*.o
	@rm -f engine/*/*.o

	@echo [RM] engine/tokenizer/tokenizer.c
	@rm -f engine/tokenizer/tokenizer.c

	@echo [RM] engine/parser/y.tab.*
	@rm -f engine/parser/y.tab.*

################################################################################
# Engine :: Command Line Interface
################################################################################



################################################################################
# Engine :: Parser
################################################################################

engine/parser/y.tab.o: engine/parser/grammar.y
	@echo [YY] $^
	@bison -d -o engine/parser/y.tab.c $^
	@echo [CC] $@
	@$(CC) $(CFLAGS) -c -o $@ engine/parser/y.tab.c

################################################################################
# Engine :: Tokenizer
################################################################################

tokenizer: engine/tokenizer/token.o engine/tokenizer/tokenizer.o engine/tokenizer/token_types.o

engine/tokenizer/tokenizer.o: engine/tokenizer/tokenizer.l
	@# Note: -o cannot have a space before the path.
	@echo [LL] $<
	@flex -oengine/tokenizer/tokenizer.c $<
	@echo [CC] $@
	@$(CC) $(CFLAGS) -c -o $@ engine/tokenizer/tokenizer.c

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
	@echo [CC] $@
	@$(CC) $(CFLAGS) -c -o $@ $^
