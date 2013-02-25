################################################################################
# Settings
################################################################################

# These are things you may want to adjust.
prefix=/usr/local/pedant

# These are things you can hopefully leave alone.
CC=clang
CFLAGS=-Wall -std=c99 -I lib/lua/src
INSTALL=install -p
LDFLAGS=-lm
MAKE=make -e

################################################################################
# Top-Level Targets
################################################################################

CFLAGS+=-D CHECK_DIR='"$(prefix)/share/checks"'

all: lua engine

install: engine-install lua-install check-install test-install

clean: engine-clean lua-clean

################################################################################
# Engine
################################################################################

engine: engine/pedant.o engine/parser/token.o engine/parser/y.tab.o engine/parser/lex.yy.o lib/lua/src/liblua.a
	$(CC) $(LDFLAGS) -o pedant $^

engine-install:
	$(INSTALL) -m 0755 pedant $(prefix)/bin

engine-clean:
	rm -f engine/*.o
	rm -f engine/parser/lex.yy.*
	rm -f engine/parser/y.tab.*

engine/parser/y.tab.o: engine/parser/grammar.y
	yacc -d -o engine/parser/y.tab.c $^
	$(CC) $(CFLAGS) -c -o $@ engine/parser/y.tab.c

engine/parser/lex.yy.o: engine/parser/tokens.l engine/parser/y.tab.h
	# Note: -o cannot have a space before the path.
	flex -oengine/parser/lex.yy.c $<
	$(CC) $(CFLAGS) -c -o $@ engine/parser/lex.yy.c

################################################################################
# Lua
################################################################################

lua_dir=lib/lua

export INSTALL_TOP=$(prefix)
export PLAT=posix

lua:
	$(MAKE) -C $(lua_dir) all

lua-install:
	$(MAKE) -C $(lua_dir) install

lua-clean:
	$(MAKE) -C $(lua_dir) clean

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
