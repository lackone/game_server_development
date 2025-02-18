--Lua 与 C/C++交互栈

--当我们想在 lua 和 C 之间交换数据时，会面临两个问题，第一个问题是动态类型和静态类型体系之间的不匹配，第二个问题是自动内存管理和手动内存管理之间不匹配。

--lua 和 C 之间的通信的主要组件，是无处不在的虚似栈，几乎所有的 Api 都是在操作这个栈中的值，lua 与 C 之间的所有数据交换都是通过这个栈完成的。此外还可以利用栈保存中间结果。

--交互原理
--Lua 使用一个虚拟栈来和 C 互传值。栈上的的每个元素都是一个 Lua 值 (nil，数字，字符串，等等)。

--交互栈
--所有针对栈的 API 查询操作都不严格遵循栈的操作规则(FILO)。而是可以用一个 索引 来指向栈上的任何元素：正的索引指的是栈上的绝对位置(从 1 开始)；负的索引则指从栈顶开始的偏移量。
--展开来说，如果堆栈有 n 个元素，那么索引 1 表示第一个元素(也就是最先被压栈的元素)而索引 n 则指最后一个元素；索引 -1 也是指最后一个元素(即栈顶的元素), 索引 -n 是指第一个元素。

--出入栈 API
--push functions (C -> stack)
--push 系列函数是要入栈的。
--void lua_pushnil(lua_State * L);
--void lua_pushboolean (lua_State * L, int bool);
--void lua_pushnumber(lua_State * L, lua_Number n);
--void lua_pushinteger (lua_State * L, lua_Integer n);
--void lua_pushlstring (lua_State * L, const char * s, size_t len);
--void lua_pushstring(lua_State * L, const char * s);

--set functions (stack -> Lua)
--set 系列函数是要出栈的。
--void (lua_setglobal)(lua_State * L, const char * name);
--void (lua_settable)(lua_State * L, int idx);
--void (lua_setfield)(lua_State * L, int idx, const char * k);
--void (lua_seti)(lua_State * L, int idx, lua_Integer n);
--void (lua_rawset)(lua_State * L, int idx);
--void (lua_rawseti)(lua_State * L, int idx, lua_Integer n);
--void (lua_rawsetp)(lua_State * L, int idx, const void * p);
--int (lua_setmetatable)(lua_State * L, int objindex);
--void (lua_setuservalue)(lua_State * L, int idx);

--get functions (Lua -> stack)
--get 系列函数是要入栈的。
--int (lua_getglobal)(lua_State *L, const char *name);
--int (lua_gettable)(lua_State *L, int idx);
--int (lua_getfield)(lua_State *L, int idx, const char *k);
--int (lua_geti)(lua_State *L, int idx, lua_Integer n);
--int (lua_rawget)(lua_State *L, int idx);
--int (lua_rawgeti)(lua_State *L, int idx, lua_Integer n);
--int (lua_rawgetp)(lua_State *L, int idx, const void *p);
--void(lua_createtable)(lua_State *L, int narr, int nrec);
--void *(lua_newuserdata)(lua_State *L, size_t sz);
--int(lua_getmetatable) (lua_State *L, int objindex);
--int(lua_getuservalue) (lua_State *L, int idx);

--access function (stack -> C)
--int(lua_isnumber) (lua_State *L, int idx);
--int(lua_isstring) (lua_State *L, int idx);
--int(lua_iscfunction) (lua_State *L, int idx);
--int(lua_isinteger) (lua_State *L, int idx);
--int(lua_isuserdata) (lua_State *L, int idx);
--int(lua_type) (lua_State *L, int idx);
--const char*(lua_typename) (lua_State *L, int tp);
--lua_Number(lua_tonumberx) (lua_State *L, int idx, int *isnum);
--lua_Integer(lua_tointegerx) (lua_State *L, int idx, int *isnum);
--int(lua_toboolean) (lua_State *L, int idx);
--const char*(lua_tolstring) (lua_State *L, int idx, size_t *len);
--size_t(lua_rawlen) (lua_State *L, int idx);
--lua_CFunction(lua_tocfunction) (lua_State *L, int idx);
--void* (lua_touserdata) (lua_State *L, int idx);
--lua_State*(lua_tothread) (lua_State *L, int idx);
--const void*(lua_topointer) (lua_State *L, int idx);

--luaL_check_*系列
--lua_Number luaL_checknumber (lua_State *L, int arg);  检查函数的第 arg 个参数是否是一个 数字，并返回这个数字。
--const char *luaL_checkstring (lua_State *L, int arg);  检查函数的第 arg 个参数是否是一个 字符串并返回这个字符串。

--弹出 lua_pop(L,n)
--从栈上，弹出 n 个元素。

--栈管理 API
--lua_pop(L,n)  弹出栈顶 n 个元素
--lua_remove(L,idx)  移除栈中索引"index"处的元素, 该元素之上的所有元素下移。
--lua_insert(L,idx)  将栈顶元素移动到索引"index"处, 索引"index"(含)之上的所有元素上移。

--为发防止进栈溢出, 有如下函数可用
--int lua_checkstack (lua_State *L, int sz);
--void luaL_checkstack (lua_State *L, int sz, const char *msg);

--基本函数
--int lua_gettop(lua_State *L)   返回栈顶元素的索引。
--void lua_settop(lua_State *L, int index)   设置栈顶为索引"index"指向处。
--void lua_pushvalue (lua_State *L, int index);   将索引"index"处元素, 压到栈顶。
--void lua_replace(lua_State *L, int index)   将栈顶元素移动到索引"index"处。
--void lua_rotate (lua_State *L, int index, int n);
--把从 idx 开始到栈顶的元素轮转 n 个位置。
--对于 n 为正数时，轮转方向是向栈顶的；
--当 n 为负数时，向栈底方向轮转 -n 个位置。
--n 的绝对值不可以比参于轮转的切片长度大。