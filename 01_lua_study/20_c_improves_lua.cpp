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

int ctest(lua_State *L) {
    printf("i from ctest\n");
    return 0;
}

int ctest2(lua_State *L) {
    printf("i from ctest2\n");

    //参数是从左往右压入栈的
    const char *str = lua_tostring(L, -1); //-1是栈顶，也就是最后压入的
    int price = lua_tointeger(L, -2);

    printf("price = %d str = %s\n", price, str);

    return 0;
}

int ctest3(lua_State *L) {
    printf("i from ctest3\n");

    stackDump(L);

    const char *str = lua_tostring(L, -1);
    int price = lua_tointeger(L, -2);

    stackDump(L);

    lua_pushinteger(L, price * 2);

    char buf[1024] = {0};
    sprintf(buf, "%s %s", "hello", str);
    lua_pushstring(L, buf);

    stackDump(L);

    return 2;
}

int ctest4_sub(lua_State *L) {
    printf("i from ctest4_sub\n");
    return 0;
}

int ctest4(lua_State *L) {
    lua_newtable(L); //创建一个表格, 放在栈顶
    lua_pushstring(L, "name"); //压入 key
    lua_pushstring(L, "hello,lua"); //压入 value
    lua_settable(L, -3); //弹出 key, value, 并设置到 table 里面去

    lua_pushstring(L, "ctest4_sub");
    lua_pushcfunction(L, ctest4_sub);
    lua_settable(L, -3); //不需要给 tab 名字

    return 1;
}

int printHello(lua_State *L) {
    lua_pushstring(L, "hello");
    return 1;
}

int getfirst(lua_State *L) {
    int n = lua_gettop(L);
    if (n != 0) {
        //获得第一个参数
        int i = lua_tonumber(L, 1);
        //将传递过来的参数加一以后最为返回值传递回去
        lua_pushnumber(L, i + 1);
        return 1;
    }
    return 0;
}

int myadd(lua_State *L) {
    int n = lua_gettop(L);
    int sum = 0;
    for (int i = 1; i <= n; i++) {
        sum += lua_tonumber(L, i);
    }
    if (n != 0) {
        lua_pushnumber(L, sum);
        return 1;
    }
    return 0;
}

int load_my(lua_State *L) {
    const luaL_Reg libs[] =
    {
        {"printHello", printHello},
        {"getfirst", getfirst},
        {"myadd", myadd},
        {NULL, NULL}
    };
    //首先创建一个 table, 然后把成员函数名做 key, 成员函数作为 value 放入该 table 中
    luaL_newlib(L, libs);
    return 1;
}

int main() {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    //lua 访问 c 中入栈变量
    int price = 99.99;
    lua_pushnumber(L, price); //将一个数字值推入 Lua 堆栈的函数

    int n = lua_gettop(L);
    printf("stack size = %d\n", n);

    lua_setglobal(L, "price"); //将一个 Lua 值设置为全局变量。

    n = lua_gettop(L);
    printf("stack size = %d\n", n);

    const char *name = "test";
    lua_pushstring(L, name);
    lua_setglobal(L, "name");

    //lua 访问 c 中入栈的表
    lua_newtable(L);
    lua_pushstring(L, "price");
    lua_pushinteger(L, 100);
    stackDump(L); //table 'price' 100
    lua_settable(L, -3); // table["price"] = 100

    lua_pushstring(L, "aabbcc");
    lua_setfield(L, -2, "name"); // table["name"] = "aabbcc"

    lua_setglobal(L, "c_obj");

    stackDump(L);

    //调用 C++函数-无参无返回
    lua_pushcfunction(L, &ctest);
    lua_setglobal(L, "ctest");

    //调用 C++函数-有参无返回
    lua_pushcfunction(L, &ctest2);
    lua_setglobal(L, "ctest2");

    //调用 C++函数-有参有返回
    lua_pushcfunction(L, &ctest3);
    lua_setglobal(L, "ctest3");

    //调用 C++函数返回 table
    lua_pushcfunction(L, &ctest4);
    lua_setglobal(L, "ctest4");

    //循环批量绑定全局函数
    //把需要用到的函数都放到注册表中, 统一进行注册
    const luaL_Reg libs[] =
    {
        {"printHello", printHello},
        {"getfirst", getfirst},
        {"myadd", myadd},
        {NULL, NULL}
    };

    int i = 0;
    while (libs[i].func) {
        //第二个参数代表 Lua 中要调用的函数名称,
        //第三个参数就是 c 层的函数名称
        lua_register(L, libs[i].name, libs[i].func);
        lua_settop(L, 0); //将栈顶清空
        i++;
    }

    //批量表化绑定全局函数

    //统一注册 lua 中调用的函数
    luaL_requiref(L, "my", load_my, 1);

    luaL_dofile(L, "20_c_improves_lua.lua");
    lua_close(L);

    return 0;
}
