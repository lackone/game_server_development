-- 数据类型
-- 在 lua 中，函数 type 能够返回一个值或一个变量所属的类型
print(type(nil))    -->output:nil
print(type(true))   -->output:boolean
print(type(360.0))  -->output:number
print(type("hello world"))  -->output:string
print(type(print))  -->output:function
print(type({})) -->output:table
print(type(type(print)))    -->output:string

-- 空nil
-- nil 是一种类型，nil 类型也只有一种值就是 nil。
-- nil 类型有点类似于 C/C++中的 NULL，其主要作用也是起一个标记位的作用
-- Lua 将 nil 用于表示"无效值"。一个变量在第一次赋值前的默认值是 nil，将 nil 赋予给一个全局变量就等同于删除它。
local num
print(num)
num = 100
print(num)

-- 布尔 boolean
-- 布尔类型，boolean 类型，可选值只有 true / false。
-- Lua 中 nil 和 false 为"假"，其它所有值均为"真"。比如 0 和空字符串("") 就是"真" 。
local a = true
local b = 0
local c = ""
local d = false --为假
local e = nil   --为假

if a then
    print("aaa")
end
if b then
    print("bbb")
end
if c then
    print("ccc")
end
if d then
    print("ddd")
end
if e then
    print("eee")
end

-- 数值类型 number
-- 数值类型，表示整数和实数，取值可为任意整数和实数。
local order = 3.11
local score = 88.23
print(math.floor(order)) --向下取整
print(math.ceil(score)) --向上取整

-- 字符串 string
-- 1、使用一对匹配的单引号。例：'hello'。使用一对匹配的双引号。例："abclua"。
-- 2、Lua 中没有字符类型，所谓的字符类型也是含有一个字符的字符串而己。
-- 3、字符串还可以用一种长括号(即[[ ]]) 括起来的方式定义。其好处就在于： 1 -> 转义并不展开(此举，跟 C++11 中 R"(hello lua)"相似) ,2 -> 便于多行书写。
local str1 = "hello,world"
local str2 = 'hello,lua'
local str3 = [["add\name", 'hello']]
local str4 = [=[string hav a [[]]..]=]
print(str1)
print(str2)
print(str3)
print(str4)
local str5 = "<html> \
    <head></head> \
    <body></body> \
</html>"
print(str5)
local str6 = [[
    <html>
        <head></head>
        <body></body>
    </html>
]]
print(str6)

-- 函数 function
-- 函数，在 Lua 中也是一种数据类型，被称作第一类值(first-class)，也有翻译为一等公民
-- 函数可以存储在变量中，可以通过作参数传递给其他函数，还可以作为其他函数的返回值。其上行为同普通变量无异，普通变量即一等公民。
local function test()
    print("in test function")
    local x = 10
    local y = 10
    return x + y
end
test()
local dd = test()
print(dd)

local function call_fn(f)
    --将函数作为参数
    return f()
end
print(call_fn(test))

-- 函数名
-- 有名函数的定义本质上是：匿名函数对变量的赋值。
function test1()
    --有名函数

end
test2 = function()
    --匿名函数对变量的赋值

end

-- 函数入参无类型/返值无限制
function msg(a, b)
    print("a:" .. type(a) .. " b:" .. type(b))
    print(a, b)
    return 1, 2, 3, 4, 5
end
msg("aa", 3.14)

-- 表 table
-- Table 类型中一种基于 k-v 类型，实现了一种抽象的 "map<k，v>"。"map<k，v>"是一种具有特殊索引方式的数组。

-- 数组
local arr = { 1, 2, 3, 4, 5 }
for i = 1, 5 do
    --无key的类型，key为number，下标从1开始
    print(arr[i])
end

-- 键值
-- 对于无 key 的类型，此时的 key 类型为 number，下标从 1 开始，下标依次累加。
-- 有 key 有则实现为 hash， key 为 string 时有两种表现形式，表内{web = } {["web"] = } 表外，t . web 和 t[ "web" ]。或 key 为 number 时，表内表外是一个类型。
local map = { ["aa"] = "111", bb = "222", cc = "333" }
print(map.aa)
print(map.bb)
print(map.cc)

for k, v in pairs(map) do
    print(k, v)
end

map.aa = "gg"
map.cc = "vv"

for k, v in pairs(map) do
    print(k, v)
end

-- 混合类型
local info = {
    web = "http://www.baidu.com",

    telphone = "15688888888",

    staff = { "jack", "scott", "gary" },

    10001, --下标从1开始，为1
    10002, --为2
    [10] = 9999,
    ["city"] = "bj"
}
for k, v in pairs(info) do
    print(k, v)
end

-- Lua 中总共有 8 种数据类型，分别是 nil，boolen，number，string， function，table，thread，userdata。
-- 前 4 种属于基本数据类型，相对引用类型，赋值，传参会发生拷贝行为。
function chg1(v)
    v = 1111
end
local val1 = 1
print("val1:", val1)
chg1(val1)
print("val1:", val1)

-- 后 4 种属于对象(引用)类型，相对基本类型，赋值，传参不会发生拷贝行为。
function chg2(v)
    v.a = 2222;
end
local val2 = { a = 1 }
print("val2:", val2.a)
chg2(val2)
print("val2:", val2.a)

-- 变量
-- 变量不过是存储到区域可以操作的名称，即指定内存的别名。它可以容纳不同类型的值，包括函数和表等。
-- 变量名可以由字母，数字和下划线。它必须以字母或下划线开头。大写和小写字母是敏感的，因为 Lua 是区分大小写的。
aa = nil
bb = 999
cc = true
dd = function()
    print("function")
end
ee = { a = "hello", b = "world" }

-- 变量的作用域 scope
-- 变量的作用范围开始于声明它们之后的第一个语句段，结束于包含这个声明的最内层语句块的最后一个非空语句。
xx = 10
do
    local xx = xx --新的xx
    print(xx)
    xx = xx + 1 -- 11
    do
        local xx = xx + 1 --新的xx
        print(xx) --12
    end
    print(xx) --11
end
print(xx)  --10全局

-- C/C++中是以 { } 的方式来划分作用域的。
-- do end 在 lua 中是最小的作用域，此类似于 C/C++的大括号{}代码块。lua 中另外一个形式的作有域，就是函数。此举也类似于 C/C++函数。
-- lua 中 scope 是比较弱的，真正决定一个变量作用域的，除了域以外，还要看变量修饰符。
function stest()
    -- vv = 100  -- 全局
    local vv = 100  -- 局部
    print(vv)
    vv = vv + 1
end
stest()
print(vv)

-- ① 全局变量：所有的变量默是全局，除非显式地声明为 local 局部。全局变量，可以不经定义直使用，默认为 nil
-- ② 局部变量：当类型被指定为 local 局部的一个变量，它的范围是有限的在自己的范围内使用。需要加 local 修饰 ，默认值为 nil。

-- lua 中最小的 chunk(lua 中最小的编译单元)结构，是 do end 相当于 c/c++中最小作用域结构({})一样。
do
    print("do end ...")
end

function my_print()
    print("do end ...")
end

function my_print2()
    vvv = 999
end

-- 调不调用my_print2()对print影响很大
-- my_print2()
print(vvv)