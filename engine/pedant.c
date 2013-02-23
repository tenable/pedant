#include <err.h>
#include <stdlib.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

int main(int argc, const char **argv, const char **envp)
{
	lua_State *L;
	int rc;

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

	return EXIT_SUCCESS;
}
