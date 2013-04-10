#include <err.h>
#include <stdlib.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include "parser/token.h"
#include "parser/y.tab.h"

extern FILE *yyin;
extern int yylex(void);
extern int yyparse(void);

void luacrap(void)
{
	lua_State *L;
	int rc;

	yyin = stdin;
	yyparse();

	L = luaL_newstate();
	if (L == NULL)
		err(EXIT_FAILURE, "luaL_newstate");

	luaL_openlibs(L);

	rc = luaL_loadfile(L, CHECK_DIR "/boot.lua");
	if (rc != LUA_OK)
		err(EXIT_FAILURE, "luaL_loadfile");

	rc = lua_pcall(L, 0, 0, 0);
	if (rc != LUA_OK)
		err(EXIT_FAILURE, "lua_pcall");

	lua_close(L);
}

void tokenize(const char *path)
{
	yyin = fopen(path, "r");
	if (yyin == NULL)
	{
		warn("Failed to open '%s'", path);
		return;
	}

	printf("[%d] %s\n", yylex(), yylval.tok->source);

	fclose(yyin);
}

int main(int argc, const char **argv, const char **envp)
{
	for (int i = 1; i < argc; i++)
		tokenize(argv[i]);

	return EXIT_SUCCESS;
}
