--自定类型 Full Userdata
--Userdata
--前面的章节，讲解了，如何将 c 写的函数用 lua 来调用，本章旨在如何将 c 中自定义的类型用 lua 来使用。C 中自定义的类型相对于 lua 而言就是 UserData。
--lua 用 userdata 来表述 c 语言中的自定义结构。userdata 提供一段原生的内存区域，表在 lua 中没有任何预定义的操作，可以用于存储任何类型。
--Full UserData 的内存管理，由 lua 虚拟机来统一管理。Light UserData 的内存管理则需要自己来管理。

--函数 lua_newuserdata 函数分配一块指定大小的内存块， 把内存块地址作为一个完全用户数据压栈， 并返回这个地址。 宿主程序可以随意使用这块内存。
--void *lua_newuserdata (lua_State *L, size_t size);

--函数 lua_touserdata，如果给定索引处的值是一个 full userdata， 函数返回其内存块的地址。
--void *lua_touserdata (lua_State *L, int index);

--检查"cond"是否为"true"，如果为"false"则报错
--void luaL_argcheck (lua_State *L, int cond, int arg, const char *extramsg);

arr = myarr.new(100)
print(arr, type(arr))
print(myarr.size(arr))
for i = 1, 50 do
    myarr.set(arr, i, i + 100)
end
print(myarr.get(arr, 10))

--差异化 userdata

--函数 luaL_newmetatable，会创建一张新表(即元表)，并将该表与注册表中的指定名称 tname 关联起来。
--int luaL_newmetatable(lua_State *L, const char *tname);

--函数 luaL_getmetatable，会从注册表中获取与 tname 关联的元表，压栈， 如果没有 tname 对应的元表，则将 nil 压栈并返回假。
--int luaL_getmetatable(lua_State *L, const char *tname);

--lua_setmetatable 把栈顶一张表弹出栈，并将其设为给定索引处的值的元表。
--void lua_setmetatable(lua_State *L, int index);

--luaL_checkudata，会检查栈中指定位置上的对象是否是与指定名称的元表匹配的表用 户数据。
--如果，该对象不是用户数据，或者该用户数据没有正确的元表，checkudata 就会 引发错误。否则，反回这个用户数据的地址。
--void *luaL_checkudata (lua_State *L, int arg, const char *tname);

--io.stdin 也是一个 userdata，所以下面的调用要报错
--array.set(io.stdin, 1, 10)

--Object Oritented
local arr2 = myarr.new(99)
print(arr2:size())
for i = 1, 10 do
    arr2:set(i, i + 10)
end
print(arr2:get(10))