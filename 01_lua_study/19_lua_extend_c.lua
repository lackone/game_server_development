--Lua 扩展 C 程序(C/C++->lua)
--Lua 是一种嵌入式语言(embeded language)，这意味着 lua 并不是一个独立运行的应用，而是一个库，它可以链接到其它的应用程序中，将 lua 的功能融入到这些应用。

--访问 lua 全局变量
--int lua_getglobal (lua_State *L, const char *name);
--将 lua 全局作用域中变量名为 name 的成员压入虚拟栈中。
name = "test"
price = 99999

--访问 lua 全局表字段
--1 获取 table 表 lua_getglobal(L, const char *name);
--2 将元素的 key 压入 lua_pushxxx(L,key)到栈中，用 lua_gettable(Lua_state，index), 或对于字符串索引，可以用 lua_getfield(Lua_state，index，key)来直接获取

--void lua_gettable (lua_State *L, int index);

--int lua_getfield (lua_State *L, int index, const char *k);

student = {
    name = "xiaowang",
    age = 33,
    sex = "男",
}

--访问 lua 全局函数
function test(a, b)
    print(a, b)
    return a + b, a - b
end

--luaL_dofile
--int luaL_dofile (lua_State *L, const char *filename);
--加载并运行文件，luaL_dofile 的本质是个宏定义

--luaL_loadfile
--luaL_loadfile 这个函数，调用 load 函数，加载文件并编译文件为 lua 的 chunk，然后将其推到栈顶。
--int luaL_loadfile (lua_State *L, const char *filename);

--lua_pcall
--int lua_pcall (lua_State *L, int nargs, int nresults, int msgh);

--void lua_call (lua_State *L, int nargs, int nresults);

--要想调用一个 lua 函数，流程如下，
--第一，函数必须被压栈，
--第二，依次序压入参数， 调用 lua_call，nargs 是入栈参数的个数。
--第三，函数调用后，函数及其参数要出栈，
--第四， 返回值入栈，入栈顺序，先入栈者底，后入栈者顶，nresults 填入返回值的个数。

--无参无返回
function test1()
    print("print test1")
end

function test2(a, b, c)
    print("test2", a, b, c)
end

function test3(a, b, c)
    print("test3", a, b, c)
    return 11, 22, 33
end

tab = {
    func = function(a, b, c)
        print(a, b, c)
        return a * 2, b * 4, c * 8
    end
}