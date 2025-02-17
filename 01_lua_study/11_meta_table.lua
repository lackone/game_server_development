--Lua 提供了元表(Metatable)机制，允许我们改变 table 的行为，每个行为关联了对应的元方法。

--当 Lua 试图对两个表进行相加时，先检查两者之一是否有元表，之后检查元表中是否有一个叫"__add"的字段，若找到，则调用对应的值。"__add"等字段
local meta = {
    __add = function(a, b)
        return { x = a.x + b.x, y = a.y + b.y }
    end
}
x = { x = 1, y = 1 }
y = { x = 2, y = 2 }
setmetatable(x, meta)  --对指定 table 设置元表(metatable)
sum = x + y
print(sum.x, sum.y)

--元表
--setmetatable(table, metatable) --对指定 table 设置元表(metatable)
--getmetatable(table) --返回对象的元表(metatable)
myt = {}
mymt = {}
print("myt=", myt)
print("mymt=", mymt)
print(setmetatable(myt, mymt))
print(getmetatable(myt))

--元表的主要用途就是在元表中写元方法。
--元方法，即元表中特定的方法。这些方法，均为系统指定，名称固定，双下划线开头，有特定语境下的特殊意义。

--__add
mt = {}
mt.__add = function(a, b)
    local len = #a
    local ret = {}
    for i = 1, len do
        ret[i] = a[i] + b[i]
    end
    return ret
end
a = { 1, 2, 3 }
b = { 4, 5, 6 }
setmetatable(a, mt)
setmetatable(b, mt)
ret = a + b
for k, v in ipairs(ret) do
    print(k, v)
end

--__eq
--表 a 和表 b，我们知道表是引用类型，所有即便是表 a 和表 b 中的内容完全相同，亦不可用==比较。
a = { x = 1, y = 2, z = 3 }
b = { x = 1, y = 2, z = 3 }
mt.__eq = function(a, b)
    if a.x == b.x and a.y == b.y and a.z == b.z then
        return true
    else
        return false
    end
end
setmetatable(a, mt)
setmetatable(a, mt)
if a == b then
    print("a == b")
else
    print("a != b")
end

--__index 读元方法
--当表中字段不存在时，会引发解析器，去找有没有元表，若无元表反回 nil, 若有元表，去元表寻找__index 元方法，如果元方法__index 不存在，则返回 nil。
ta = {}
mt = { __index = { x = 1 } }
setmetatable(ta, mt)
print(ta.x)

ta = {}
mt = {
    __index = function()
        return 2
    end
}
setmetatable(ta, mt)
print(ta.x)

--__index 为表
--当你通过键来访问 table 的时候，如果没有这个键值，那么 Lua 就会寻找该 table 的metatable(假定有 metatable)中的__index 键。
--如果__index 的值为一个表，Lua 会在表格中查找相应的键。
other = { foo = 3 }
t = {}
setmetatable(t, { __index = other })
print(t.foo)
print(t.bar)

--__index 为表(应用-继承)
prototype = {
    x = 0,
    y = 0,
    width = 100,
    height = 100,
}
mt = { __index = prototype }

function new(obj)
    setmetatable(obj, mt)
    return obj
end

xx = new({ x = 11 })
print(xx.x, xx.y, xx.width, xx.height)

--__index 为函数
--如果__index 包含一个函数的话，Lua 就会调用那个函数，原表 table 和 key 键会作为参数传递给函数。
--__index 元方法查看表中元素是否存在，如果不存在，返回结果为 nil；如果存在则由__index 的值函数返回结果。
mt = {
    __index = function(tab, k)
        print(tab, k)
        return true
    end
}
test = {}
setmetatable(test, mt)
print(test)
print(test.key)

--__index 为函数(应用-特殊 key 处理)
test = { key = "aabbcc" }
mt = {}
mt.__index = function(t, k)
    if k == "key2" then
        return "meta value"
    else
        return nil
    end
end
setmetatable(test, mt)
print(test.key, test.key2)

setmetatable(test, {
    __index = function(t, k)
        if k == "key2" then
            return "meta value2"
        else
            return nil
        end
    end
})
print(test.key, test.key2)

--__index 为函数(应用-增加额外表)
prototype = {
    x = 1,
    y = 1,
    width = 200,
    height = 200,
}
mt = {
    __index = function(_, k)
        return prototype[k]
    end
}
function new(obj)
    setmetatable(obj, mt)
    return obj
end
test = new({ x = 66 })
print(test.x, test.y, test.width, test.height)

--Lua 查找一个表元素时的规则，其实就是如下 3 个步骤:
--1.在表中查找，如果找到，返回该元素，找不到则继续
--2.判断该表是否有元表，如果没有元表，返回 nil，有元表则继续.
--3.判断元表有没有__index 方法，如果__index 方法为 nil，则返回 nil；如果__index 方法是一个表，则重复 1、2、3；如果__index 方法是一个函数，则返回该函数的返回值。

--__newindex 写元方法

--__index 用于在本表中不存在字段的查询，而__newindex 用于本表中不存在字段的更新，
--当对本表中一个不存在字段赋值时，若本表的元表中无__newindex 字段，则在本表中更新。若有此字段，那么解析器就会调用它。

--__newindex 为表
test = { key = 999 }
mt = {}
setmetatable(test, {
    __newindex = mt
})
test.new_key = 111
print(test.new_key) --nil
print(mt.new_key) --111

--__newindex 为函数
--若 __newindex 元方法，如果是一个函数，则将 table、 key、以及 value 作为参数传入函数中。
test = { key = 111 }
setmetatable(test, {
    __newindex = function(t, k, v)
        print(t, k, v)
    end
})
test.new_key = 999

--__newindex 应用-设置新键到其它表
--此处要注意，要将本 k,v 存储在本表中，则会发生，无限递归行为
test = { key = 111 }
tmp = {}
setmetatable(test, {
    __newindex = function(t, k, v)
        tmp[k] = v
    end
})
test.new_key = 999
print(tmp.new_key) --999
print(test.new_key) --nil

test = { key = 111 }
tmp = {}
setmetatable(test, {
    __newindex = function(t, k, v)
        tmp[k] = v
    end,
    __index = tmp
})
test.new_key = 999
print(tmp.new_key) --999
print(test.new_key) --999

--raw method
--rawget (table, index)
--它绕过了任何可能存在的元方法（如 __index）,直接访问表中元素
test = { x = 1 }
setmetatable(test, {
    __index = {
        y = 999
    }
})
print(test.x) --1
print(test.y) --999
print(rawget(test, "x")) --1,不触发 __index，直接返回 1
print(rawget(test, "y")) --nil,不触发 __index，直接返回 nil

--rawset (table，index，value)
--绕过了任何可能存在的元方法，直接设置表中元素值
tmp = {}
test = { x = 0 }
setmetatable(test, {
    __newindex = tmp
})
test.new_key = 999 --触发 __index，直接设置tmp
print(tmp.new_key) --999
print(test.new_key) --nil
rawset(test, "new_key2", 888) --不触发 __index，直接设置test
print(tmp.new_key2) --nil
print(test.new_key2) --888


--__call 元方法
--Lua 中的__call 元方法，像 c++中仿函数一样，将对象当函数使用。
--当 Lua 尝试调用一个非函数的值表的时候会触发这个事件 （即 func 不是一个函数）。
--查找 func 的元方法，如果找得到，就调用这个元方法，func 作为第一个参数传入，原来调用的参数（args）后依次排在后面。
pow = {}
setmetatable(pow, {
    __call = function(t, x)
        return x * x
    end
})
print(pow(3))

t = {}
setmetatable(t, {
    __call = function(t, a, b, factor)
        t.a = a
        t.b = b
        t.factor = factor
        return (a + b) * factor
    end
})
print(t(1, 2, 0.1))
print(t.a, t.b, t.factor)

--__tostring 元方法
--Lua 中若输出基类型，print 即可，或要输出表，则只会打印表的地址
--__tostring 元方法用于修改表的输出行为，__tostring 接受一个参数，即为本表，以下实例我们自定义了表的输出内容：
t = { 1, 2, 3 }
setmetatable(t, {
    __tostring = function(t)
        sum = 0
        for k, v in pairs(t) do
            sum = sum + v
        end
        return "所有元素和：" .. sum
    end
})
print(t) --调用__tostring

--__add 对应的运算符 '+'
--__sub 对应的运算符 '-'
--__mul 对应的运算符 '*'
--__div 对应的运算符 '/'
--__mod 对应的运算符 '%'
--__unm 对应的运算符 '-'
--__concat 对应的运算符 '..'
--__eq 对应的运算符 '=='
--__lt 对应的运算符 '<'
--__le 对应的运算符 '<='