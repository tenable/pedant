################################################################################
# Settings
################################################################################

# These are things you may want to adjust.
prefix=/usr/local/pedant

# These are things you can hopefully leave alone.
CC=clang
CFLAGS=-Wall -I lib/lua/src
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

engine: engine/pedant.o lib/lua/src/liblua.a
	$(CC) $(LDFLAGS) -o pedant $^

engine-install:
	$(INSTALL) -m 0755 pedant $(prefix)/bin

engine-clean:
	rm -f engine/*.o

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
