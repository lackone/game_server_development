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

//-I./include -L./lib -llua
int main() {
    lua_State *L = luaL_newstate(); // 创建一个新的 Lua 状态机
    luaL_openlibs(L); // 加载 Lua 标准库
    stackDump(L); //空栈
    lua_pushinteger(L, 1);
    lua_pushinteger(L, 2);
    lua_pushinteger(L, 3);
    lua_pushinteger(L, 4);
    stackDump(L);

    //  4  => 栈顶
    //  3
    //  2
    //  1  => 栈底

    int n = lua_gettop(L); //获取当前 Lua 栈的栈顶索引
    printf("stack size = %d\n", n);

    // lua_settop(L, 2); //设置 Lua 栈的栈顶位置
    //
    // stackDump(L); //打印 1 2
    //
    // lua_pop(L, 2); //从 Lua 栈中弹出指定数量的元素
    // lua_pop(L, -1);
    //
    // stackDump(L);  //空栈

    lua_pushvalue(L, 1); //将栈中指定位置的值复制并推入栈顶
    lua_pushvalue(L, 100);

    stackDump(L); //1 2 3 4 1 nil
    lua_remove(L, 200); //移除指定索引处的栈元素
    stackDump(L); //1 2 3 4 1
    lua_insert(L, 1); //将栈顶元素移动到索引"index"处
    stackDump(L); //1 1 2 3 4
    lua_replace(L, 2); //将栈顶元素移动到索引"index"处。
    stackDump(L); //1 4 2 3

    luaL_dofile(L, "18_test.lua");
    lua_close(L);

    return 0;
}
