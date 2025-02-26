#include <iostream>
#include "Sunnet.h"
using namespace std;

void test() {
}

//
//下载、编译源码
//https://www.lua.org/ftp/lua-5.4.7.tar.gz
//tar xf lua-5.4.7.tar.gz
//cd lua-5.4.7
//make linux
//会生成 liblua.a

//创建和销毁Lua虚拟机所用到的API及功能说明
//luaL_newstate()   创建lua_State对象
//luaL_openlibs()   开启标准库
//luaL_dofile()     加载并运行filename指定的文件
//lua_close()       销毁lua虚拟机

//C++调用Lua方法
//涉及4个API
//lua_getglobal(lua_State *L, const char* name)  把name指定的全局变量压栈
//lua_pushinteger(lua_State *L, lua_Integer n)   将整型数n压入栈中
//lua_pcall(lua_State *L, int nargs, int nresult, int msgh);  调用一个lua方法，nargs表示参数个数，nresult表示返回的值个数，msgh表示如果调用失败采取什么处理方法
//lua_tostring(lua_State *L, int index);  把给定索引处的lua值转换成一个c字符串

//直观理解Lua栈
//lua_State，它最核心的数据结构是一个调用栈，大部分交互API都在操作这个栈。
//始终在为lua_pcall准备数据，从nargs、 nresults等参数可以看出，lua_pcall并不能直接指定要调用的方法和参数，开发者只能按照它的规则，在栈中准备好数据，等待lua_pcall读取。
//lua_pcall一共会用到两个元素。执行lua_pcall后，程序会自动删除先前准备的元素，并将返回值压入栈中。
//Lua还提供了lua_pushboolean和lua_pushlstring等方法，供开发者将各类型的数据压入栈中，以提供合适的参数。
//除了lua_tostring之外，Lua还提供了lua_tointeger和lua_tolstring等方法供开发者获取栈中的元素。

//lua_gettop()  返回栈顶元素的索引，相当于返回栈上的元素个数
//lua_isstring()  判断栈中指定位置的元素是否为字符串，如果是字符串或数字，则返回1，否则返回0
//lua_tolstring()  多个一个参数len，会把字符串的长度存入len中
//lua_pushinteger()  把值为n的整数压栈

//lua_Reg  用于注册函数的数组类型
//luaL_newlib(lua_State *L, luaL_Reg l[])  在栈中创建一张新的表，把数组l中的函数注册到表中
//lua_setglobal(lua_State *L, const char* name) 将栈顶元素放入全局空间，并重新命名

int main() {
    new Sunnet();
    Sunnet::inst->Start();
    //启动main服务
    auto t = make_shared<string>("main"); //默认启动主服务
    Sunnet::inst->NewService(t);
    //等待
    Sunnet::inst->Wait();
    return 0;
}
