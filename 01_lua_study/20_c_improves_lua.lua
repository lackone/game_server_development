--C 提升 Lua 效率(lua->C/C++)
--当 lua 调用 C 函数时，这个函数必须遵循某种规则来获取参数和返回结果。此外，lua 调用 C 函数时，必须注册该函数，即必须以一种恰当的方式为 lua 提供该 C 函数的地址。

--lua 调用 C 函数时，也使用了一个与 C 语言调用 lua 函数时相同类型的栈，C 函数从栈中获取参数，并将结果压入栈中。

--独立栈
--无论何时 Lua 调用 C, 被调用的函数都得到一个新的栈，这个栈独立于 C 函数本身 的栈，也独立于之前的 Lua 栈。
--它里面包含了 Lua 传递给 C 函数的所有参数，而 C 函 数则把要返回的结果放入这个栈以返回给调用者。

--Lua 访问 c 入栈值
--void lua_setglobal (lua_State *L, const char *name);  将虚拟栈中，将栈顶元素弹出，作为全局 lua 变量 name 的值。
--void lua_newtable (lua_State *L);  产生一个空表, 并推入栈。
--void lua_settable (lua_State *L, int index);  作一个等价于 t[k] = v 的操作，这里 t 是一个给定有效索引 index 处的值，v 指栈顶的值，而 k 是栈顶之下的那个值。
--void lua_setfield (lua_State *L, int index, const char *k); 等价于 t[k] = v，t 是栈上索引为 index 的表，v 是栈顶的值。函数结束，栈顶值 v 会被弹出。

--lua 访问 c 中入栈变量
print(price)
print(name)

--lua 访问 c 中入栈的表
print(c_obj.name)
print(c_obj.price)

--lua 调用 C 函数
--将函数压入栈，该函数接受一个 C 类型的函数指针，并将其以 lua function 形式入栈。在 lua 中调用该函数即会发生 c 函数的调用。
--void lua_pushcfunction (lua_State *L, lua_CFunction f);
--typedef int (*lua_CFunction) (lua_State *L);
--void lua_register (lua_State *L, const char *name, lua_CFunction f);

--调用 C++函数-无参无返回
ctest()

--调用 C++函数-有参无返回
ctest2(123, "hello")

--调用 C++函数-有参有返回
price, str = ctest3(456, "lua")
print(price, str)

--调用 C++函数返回 table
obj = ctest4()
print(obj.name)
obj.ctest4_sub()

--C++函数批量注册/表化
--luaL_Reg
--typedef struct luaL_Reg
--{
--    const char *name;
--    lua_CFunction func;
--} luaL_Reg;
--用于存放，函数指针和注册的函数名。常用于生成数组，数组的最后一个元素，一定是以{NULL，NULL}结尾。

--创建表入栈，并且注册 l 中的所有函数到栈上的表。
--void luaL_newlib (lua_State *L, const luaL_Reg l[]);

--设置数组 l 中所有函数的到栈顶的表中，第三个参数通常为 0。
--void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup);

--void luaL_requiref (lua_State *L, const char *modname, lua_CFunction openf, int glb);

print(printHello())
print(getfirst(11))
print(myadd(1, 2, 3, 4, 5))

print(my.printHello())
print(my.getfirst(11))
print(my.myadd(1, 2, 3, 4, 5))

