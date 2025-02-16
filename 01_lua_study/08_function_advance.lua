--函数是一等公民

--Lua 中所有函都是匿名的(anonymous)，比如，print 实际指的时保存该函数的变量

--optional_function_scope
--function_name = function ( arg1, arg2, arg3..., argn)
--    function_body
--    return result_params_comma_separated
--end

--lua 语言中的函数与其它常见类型的值(数值和字符串)具有相同的权限
--1 可以将函数存储在变量中(全局变量和局部变量中)或表中。
--2 也可以将某个函数作为参数传递给其它函数，
--3 还可以将某个函数作为其它函数的返回值。

--普通变量
mprint = function(param)
    print("this is my print func ##", param, "##")
end
function add(n1, n2, print)
    ret = n1 + n2
    print(ret)
end
add(3, 5, mprint)

--表字段变量
t = {
    add = function(n1, n2)
        --表内
        return n1 + n2
    end
}
t.sub = function(n1, n2)
    --表外
    return n1 - n2
end
print(t.add(3, 5))
print(t.sub(3, 5))

--函数作入参(回调)
arr = { 3, 5, 7, 1, 2, 4, 9, 8 }
table.sort(arr, function(a, b)
    return a > b
end)
print(table.concat(arr, " "))

--sort (hash table) array
network = {
    {
        name = "s4",
        ip = "127.0.0.1"
    },
    {
        name = "s1",
        ip = "127.0.0.1"
    },
    {
        name = "s3",
        ip = "127.0.0.1"
    },
}
table.sort(network, function(a, b)
    return a.name < b.name
end)
for k, v in pairs(network) do
    for name, ip in pairs(v) do
        print(name, ip)
    end
end

--参数 (...)
--Lua 函数可以接受可变数目的参数，和 C 语言类似在函数参数列表中使用三点(...)表示函数有可变的参数。
function test(...)
    local a, b, c = ...  --赋值
    a = a or 0
    b = b or 0
    c = c or 0
    print(a, b, c)
    print(#{ ... })
end

test(1, 2, 3)
test(1, 2, 3, 4, 5)

--变参->表化{ ... }
function avg(...)
    local arg = { ... }
    local sum = 0
    local cnt = 0
    for _, v in pairs(arg) do
        sum = sum + v
        cnt = cnt + 1
    end
    return sum / cnt
end
print(avg(1, 2, 3, 4, 5, 6))

--变参->table.pack(...)
--表化的过程中，若表中有空洞 nil 的存在。则该表长度不可得，迭代遍历也会有中途停止。
--table.pack(...)会返回一个{...}的表，但最后一个 n 域，记录的参数的个数。
function add(...)
    local arg = table.pack(...)
    local sum = 0
    for i = 1, arg.n do
        if arg[i] ~= nil then
            sum = sum + arg[i]
        end
    end
    return sum
end
print(add(1, 2, 3, 4))

--变参之 select(...)
--另一种遍历函数的可变长参数的方法是使用函数 select。函数 select 总是具有一个固定参数 n，以及数量可变的参数。
--如果参数为 n，那么函数总是返回第 n 个参数后的所有参数;若固定参数为#,则返回参数的总数。
print(select(1, "a", "b", "c")) --> a b c
print(select(2, "a", "b", "c")) --> b c
print(select(3, "a", "b", "c")) --> c
print(select("#", "a", "b", "c")) --> 3
print(select("#", "a", nil, "b", nil, "c", nil)) --无惧 nil

function add2(...)
    local sum = 0
    for i = 1, select("#", ...) do
        sum = sum + select(i, ...) --将 select 返值，参与运算。
    end
    return sum
end
print(add2(1, 2, 3, 4))

function avg2(...)
    local sum = 0
    local len = select("#", ...)
    local nil_len = 0

    for i = 1, len do
        if select(i, ...) then
            sum = sum + select(i, ...)
        else
            nil_len = nil_len + 1
        end
    end

    return sum / (len - nil_len)
end
print(avg2(1, 2, 3, nil, 4, 5, 6))

--select 与 table.pack 点评
--少量参数时，select 的作法要比 table.pack(...)的作法效率要高，因为这样，避免了每次调用表创建的开销。对于大量参数，select 的开销，将超过表的创建。

--fmt 就是属于不变参部分，称为固定参数，固定参数可以有任意的数量，但是固定参数必须放在变长参数之前。
function write(fmt, ...)
    return io.write(string.format(fmt, ...))
end
write("%d %f %s\n", 12, 12.5, "Abc")

--table.unpack({})
--table.unpack 是 table.pack 的逆向函数，pack 完成将参数列表变为 lua的表结构，
--而 unpack 将一个表结构转一个参数列表，其结果可用于一个函数的参数。
print(table.unpack({ 1, 2, 3 }))
a, b = table.unpack({ 10, 20, 30 })

--unpack 的一个重要应用就是，可将参打包后传入函数。
fn = string.find
arg = { "hello", "ll" }
print(fn(table.unpack(arg)))

--命令行参数(...)
--假设有文件，test.lua ，内容如下。现运行 lua53 test.lua aa bb cc
local a, b, c = ...
print(a, b, c)  -- aa bb cc

--递归
--函数自身调用自己或是间接调用自己的行为，称为递归。
local function fact(n)
    if n == 0 then
        return 1
    else
        return n * fact(n - 1)
    end
end
print(fact(5))

local fact2
fact2 = function(n)
    if n == 0 then
        return 1
    else
        return n * fact2(n - 1) --这里报错，局部的 fact2 尚未定义完毕，因此这个表达式会尝试调用 global fact2 而非局部 fact2。
    end
end
print(fact2(5))

--什么是尾调用
--尾调用(tail call)，是被当作函数调用使用的跳转，当一个函数的最后一个动作是调用另外一个函数而没有再进行其它的工作时，就形成了尾调用。
--function f(x)
--    x = x + 1;
--    return g(x)
--end

--递归，最大的问题是，容易造成栈空间溢出，而如下的递归则不会造成溢出，因为构成了尾递归。
function foo(n)
    if n > 0 then
        return foo(n - 1)
    end
end
foo(10000)

--函数作返回(Closer 闭包)
--闭包，简而言之就是函数内部定义的函数。严格意义上来说，还包括了他所能截获的外部变量。外部变量，即，外函数内的局部变量。
function test11()
    local function test22()
        print("test22")
    end
    return test22
end

function test33()
    return function()
        print("内部")
    end
end
fn = test11()
fn()
fn = test33()
fn()

--上值 upvalue
--C++中的 lambda 就是一种闭包，通过[]来截获外部的非全局的局部变量。但是用法跟C++中区别比较大。
--在 C++中强调的是简短函数的就地书写，而在 lua 中强调的是截获非全局的局部变量返回。
--此时返回的闭包，是包含有状态的。状态就是上值，即 upvalue。
--upvalue 是一种变量，称为非局部变量(non-local variable),是指不是在局部作用范围内定义的一个变量，
--但同时又不是一个全局变量，外部函数的局部变量，功能上有点类似于 c语言中的 static 变量。
function foo(n)
    print("foo ", n)
end
foo(2018)
foo(2018)
foo(2018)

function foo2(n)
    local function foo()
        print("内部", n)
        n = n + 1
    end
    return foo
end
fn = foo2(2018)
fn()
fn()
--同时返回的多个闭包，共享一个 upvalue，其中一个修改会影响到其它，而不同次返回的闭包之间是相互独立的。
fn2 = foo2(2018)
fn2()
fn2()

function foo3(n)
    local function aa()
        print(n)
    end
    local function bb()
        n = n + 1
    end
    return aa, bb
end
aa, bb = foo3(100)
aa()
bb()
aa()
cc, dd = foo3(100)
cc()
dd()
cc()

--迭代
--闭包最常用的一个应用就是实现迭代器。所谓迭代器就是一种可以遍历一种集合中所谓元素的机制。
--每个迭代器都需要在每次成功调用之间保持一些状态，这样才能知道它所在的位置及如何迭代到下一个位置。
arr = { 1, 2, 3, 4, 5, 6, 7, 8 }

function getIter(tab)
    local i = 0 --upvalue
    return function()
        i = i + 1
        return tab[i]
    end
end

iter = getIter(arr) --①获取带有状态的闭包

while true do
    local v = iter() --② ③调用闭包函数
    if v == nil then
        break
    end
    print(v)
end

--iparis 自实现
tab = { "lua", "java", "c++" }

function foreach(tab)
    local index = 0
    local len = #tab
    return function()
        -- 闭包函数
        index = index + 1
        if index <= len then
            return index, tab[index]  --返回迭代器的当前元素
        end
    end
end

for k, v in foreach(tab) do
    print(k, v)
end

--常用系统函数
--assert (v [, message])
--如果其参数 v 的值为假（nil 或 false）， 它就调用 error

--error (message [, level])

--math.randomseed (x)

--math.random ([m [, n]])

--os.time([format [, time]])