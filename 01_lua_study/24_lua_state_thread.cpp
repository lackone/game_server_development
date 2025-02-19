#include <iostream>

extern "C" {
#include "include/lua.h"
#include "include/lualib.h"
#include "include/lauxlib.h"
}

using namespace std;

static void stackDump(lua_State *L) {
    static int count = 0;
    printf("begin dump lua stack %d\n", count);
    int i = 0;
    int top = lua_gettop(L);
    for (i = 1; i <= top; ++i)
    // for (i = top; i >= 1; --i)
    {
        int t = lua_type(L, i);
        switch (t) {
            case LUA_TSTRING:
                printf("'%s' ", lua_tostring(L, i));
                break;
            case LUA_TBOOLEAN:
                printf(lua_toboolean(L, i) ? "true " : "false ");
                break;
            case LUA_TNUMBER:
                printf("%g ", lua_tonumber(L, i));
                break;
            default:
                printf("%s ", lua_typename(L, t));
                break;
        }
    }
    printf("\nend dump lua stack %d \n", count++);
}

void test1() {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    stackDump(L);

    lua_State *L2 = lua_newthread(L);
    luaL_openlibs(L2);

    stackDump(L);
    stackDump(L2);

    printf("L:%d\n", lua_gettop(L)); // 1
    printf("L2:%d\n", lua_gettop(L2)); // 0

    lua_pushstring(L2, "a");
    lua_pushstring(L2, "b");
    lua_pushstring(L2, "c");
    lua_pushstring(L2, "d");

    stackDump(L); //thread
    stackDump(L2); //'a' 'b' 'c' 'd'

    lua_xmove(L2, L, 2);

    stackDump(L); //thread 'c' 'd'
    stackDump(L2); //'a' 'b'

    lua_close(L);
}

void test2() {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    lua_State *L2 = lua_newthread(L);
    //luaL_openlibs(L2);

    luaL_dofile(L2, "./24_lua_state_thread.lua");

    lua_getglobal(L2, "aaa"); //函数名
    lua_pushinteger(L2, 20); //传入参数

    stackDump(L2);

    int r = lua_resume(L2, L, 1, NULL); //恢复一个挂起的协程（coroutine）
    if (r == LUA_YIELD) {
        printf("LUA_YIELD\n");
    }

    printf("L2: %d\n", lua_gettop(L2));
    printf("L2: %lld\n", lua_tointeger(L2, 1));
    printf("L2: %lld\n", lua_tointeger(L2, 2));

    r = lua_resume(L2, L, 0, NULL);
    if (r == LUA_OK) {
        printf("LUA_OK\n");
    }

    printf("L2: %d\n", lua_gettop(L2));
    printf("L2: %lld\n", lua_tointeger(L2, 1));

    lua_close(L);
}

int main() {
    //test1();
    test2();

    return 0;
}
