#include <iostream>

extern "C" {
#include "include/lua.h"
#include "include/lualib.h"
#include "include/lauxlib.h"
}

using namespace std;

extern "C" {
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

    //把需要用到的函数都放到注册表中, 统一进行注册
    const luaL_Reg abclib[] = {
        {"printHello", printHello},
        {"getfirst", getfirst},
        {"myadd", myadd},
        {NULL, NULL}
    };

    //Lua 会查找以 luaopen_ 开头的函数来初始化该模块

    //gcc -fPIC -shared -o abc.so 20_c_improves_lua_lib.cpp -llua -L./lib

    //gcc -fPIC -shared -o abc.dll 20_c_improves_lua_lib.cpp -llua -L./lib

    int luaopen_abc(lua_State *L) {
        //首先创建一个 table, 然后把成员函数名做 key, 成员函数作为 value 放入该 table 中
        luaL_newlib(L, abclib);
        return 1;
    }
}