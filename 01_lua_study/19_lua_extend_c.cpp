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

int main() {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    luaL_dofile(L, "19_lua_extend_c.lua");

    //获取全局变量
    lua_getglobal(L, "price");
    int price = lua_tointeger(L, -1);

    lua_getglobal(L, "name");
    const char *name = lua_tostring(L, -1);

    cout << name << endl;
    cout << price << endl;

    lua_pop(L, 2);

    //获取表字段
    lua_getglobal(L, "student");
    stackDump(L);
    lua_pushstring(L, "name"); //将"name"压入栈中
    stackDump(L);
    lua_gettable(L, -2); //将根据栈顶的键从索引 -2 处的表中获取对应的值，并将该值压入栈顶。
    stackDump(L);
    const char *student_name = lua_tostring(L, -1);

    lua_settop(L, 1);
    stackDump(L);
    lua_pushstring(L, "age");
    lua_gettable(L, -2);
    int age = lua_tointeger(L, -1);

    lua_settop(L, 1);
    lua_pushstring(L, "sex");
    lua_gettable(L, -2);
    const char *sex = lua_tostring(L, -1);

    /*
    lua_getfield(L, -1, "name");
    const char *student_name = lua_tostring(L, -1);

    lua_settop(L, 1);
    lua_getfield(L, -1, "age");
    int age = lua_tointeger(L, -1);

    lua_settop(L, 1);
    lua_getfield(L, -1, "sex");
    const char *sex = lua_tostring(L, -1);
    */

    cout << student_name << " " << age << " " << sex << endl;

    stackDump(L);
    lua_pop(L, 2);
    stackDump(L);

    //调用 lua 函数-无参无返回
    lua_getglobal(L, "test1");
    lua_pcall(L, 0, 0, 0);

    //调用 lua 函数-有参无返回
    lua_getglobal(L, "test2");
    lua_pushinteger(L, 666);
    lua_pushnumber(L, 3.1415);
    lua_pushstring(L, "aabbccdd");
    lua_pcall(L, 3, 0, 0);

    //调用 lua 函数-有参有返回
    lua_getglobal(L, "test3");
    lua_pushinteger(L, 999);
    lua_pushnumber(L, 6.666);
    lua_pushstring(L, "hello,lua");
    lua_pcall(L, 3, 3, 0);
    stackDump(L);

    int a = lua_tointeger(L, -1);
    stackDump(L);
    int b = lua_tointeger(L, -2);
    stackDump(L);
    int c = lua_tointeger(L, -3);
    stackDump(L);
    cout << a << " " << b << " " << c << endl;

    lua_pop(L, 3);

    //调用 lua 全局表字段函数
    lua_getglobal(L, "tab");
    lua_getfield(L, -1, "func");
    stackDump(L);
    lua_remove(L, -2); //移除tab
    stackDump(L);

    lua_pushinteger(L, 1);
    lua_pushinteger(L, 2);
    lua_pushinteger(L, 3);
    lua_pcall(L, 3, 3, 0);

    stackDump(L);

    for (int i = 1; i <= 3; i++) {
        int t = lua_tointeger(L, i);
        printf("%d\n", t);
    }

    lua_pop(L, 3);
    lua_close(L);

    return 0;
}
