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

typedef struct _Array {
    int size;
    char data[1]; //柔性数组
} Array;

#define checkArray(L) (Array*)luaL_checkudata(L, 1, "abc.myarr")

int array_new(lua_State *L) {
    int n = luaL_checkinteger(L, 1); //用于从 Lua 堆栈中检查并获取一个整数值
    size_t len = sizeof(Array) + (n - 1) * sizeof(char);
    Array *arr = (Array *) lua_newuserdata(L, len); //用于在 Lua 堆栈上创建一个新的用户数据（user data）对象
    arr->size = n;

    luaL_getmetatable(L, "abc.myarr"); // 获取元表
    lua_setmetatable(L, -2); // 将元表设置到用户数据上

    return 1;
}

int array_set(lua_State *L) {
    //Array *arr = (Array *) lua_touserdata(L, 1);

    Array *arr = checkArray(L);
    // 检查传递的"key"是否为整数。
    int key = luaL_checkinteger(L, 2);
    // 检查传递的"value"是否为数值。
    char value = luaL_checknumber(L, 3);

    luaL_argcheck(L, arr != NULL, 1, "invalid argument");
    luaL_argcheck(L, key >= 1 && key < arr->size, 2, "invalid index");

    arr->data[key - 1] = value;

    return 0;
}

int array_get(lua_State *L) {
    //Array *arr = (Array *) lua_touserdata(L, 1);

    Array *arr = checkArray(L);
    int key = luaL_checkinteger(L, 2);

    luaL_argcheck(L, arr != NULL, 1, "invalid argument");
    luaL_argcheck(L, key >= 1 && key < arr->size, 2, "invalid index");

    lua_pushnumber(L, arr->data[key - 1]);

    return 1;
}

int array_size(lua_State *L) {
    //Array *arr = (Array *) lua_touserdata(L, 1);

    Array *arr = checkArray(L);
    luaL_argcheck(L, arr != NULL, 1, "invalid argument");
    lua_pushnumber(L, arr->size);
    return 1;
}

int luaopen_myarr(lua_State *L) {
    const luaL_Reg myarrLib[] = {
        {"new", array_new},
        {"set", array_set},
        {"get", array_get},
        {"size", array_size},
        {NULL, NULL}
    };
    const luaL_Reg myarrLib_m[] = {
        {"new", array_new},
        {"set", array_set},
        {"get", array_get},
        {"size", array_size},
        {NULL, NULL}
    };

    luaL_newmetatable(L, "abc.myarr"); // 创建并注册元表

    stackDump(L);

    lua_pushstring(L, "__index");

    stackDump(L);
    lua_pushvalue(L, -2);

    stackDump(L);
    // 复制一份"metatable"再次入栈。
    lua_settable(L, -3);

    stackDump(L);
    // "metatable.__index = metatable"
    luaL_setfuncs(L, myarrLib_m, 0);

    stackDump(L);

    luaL_newlib(L, myarrLib);
    return 1;
}

int main() {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    luaL_requiref(L, "myarr", luaopen_myarr, 1);

    //luaL_dofile(L, "./22_full_userdata.lua");

    luaL_loadfile(L, "./22_full_userdata.lua");
    lua_call(L, 0, LUA_MULTRET);

    lua_close(L);

    return 0;
}
