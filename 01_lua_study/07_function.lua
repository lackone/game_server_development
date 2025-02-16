--函数是一组一起执行任务的语句。可以把代码放到独立的函数中。怎么划分代码功能之间的不同，但在逻辑上划分通常是让每个函数执行特定的任务。
--Lua 语言提供了程序可以调用大量的内置方法。例如，方法 print()打印作为输入传参数在控制台中。

--格式(语法糖)
--optional_function_scope  --可选，无或local
--function function_name( arg1, arg2, arg3..., argn)
--    function_body
--    return result_params_comma_separated
--end

function max(a, b)
    local ret
    if a > b then
        ret = a
    else
        ret = b
    end
    return ret
end
print(max(5, 3))

--调用
print(max(11, 55))

--参数与返回
function test(a, b, c, d)
    print("in test")
    print(a)
    print(b)
    print(c)
    print(d)
    return a, b, c, d
end
aa, bb, cc, dd = test(1, 2, 3, 4)

--实参与形参
--从实参到形参，本质也是赋值的行为，多传值的参数会被丢掉，未被赋值的参数会为置为 nil。
local test2 = function(a, b, c, d, e, f)
    print(a, b, c, d, e, f)
end
test2(1, 2, 3, 4, 5, 6, 7, 8)

--默认参数
--nil 不能参与算术和关系运算，通常作入参处理，也就是 lua 中常见的默认参数。采用 or 运算符来实现。
local test3 = function(a, b, c)
    a = a or 0
    b = b or 0
    c = c or 0
    print(a, b, c)
end
test3(1, 2, 3)

--nil 入参
--nil 值不能参与算术和关系运算，lua 中，仅有 false 和 nil 表示假，故能参与的仅为逻辑运算。
a = 10
--print(a + nil) --报错

local max = function(a, b)
    if a > b then
        return a
    else
        return b
    end
end
--print(max(3)) --报错，b为nil

--省（）调用
--函数调用时，都需要使用一对圆括号把参数列表括起来。即使被调用的函数不需要参数，也需要一对空括号，对于这一规则，
--唯一的例外就是，当函数只有一个参数且该参数是字符串或表的构造器时，括号是可选的。
print "hello,world"
print [[hello,world]]
print { a = 1, b = 2 }

function init(arg)
    local t = {}
    t.ip = arg.ip
    t.name = arg.name
    t.passwd = arg.passwd
    return t
end

--这里并没有写()
msg = init { ip = "127.0.0.1", name = "test", passwd = "123456" }

for k, v in pairs(msg) do
    print(k, v)
end

--多参返回
s, e = string.find("hello world lua", "lua")
print(s, e)

--缺少 return 分支
--lua 中对于缺少分支的行为，完成的赋值，一律是 nil，并不会有任何问题。
local fn = function(n)
    if n > 100 then
        return 111, 999
    end
end
local a, b = fn(99)
print(a, b) --nil nil

--返回运算规则
--1 当被当作一条单独语句时，其所有返回值都会被丢弃。
--2 当函数作为表达式，将只保留第一个返回值。
--3 只有当函数调用是一系列表达式中最后一个(或唯一一个表达式)时，其所有的近值才能被获取到。

function f123()
    return 1, 2, 3
end

function f456()
    return 4, 5, 6
end

print((f123())) --1
print((f456())) --4

print(f123(), f456()) -- prints 1, 4, 5, 6
print(f456(), f123()) -- prints 4, 1, 2, 3

--位置
--return 用于结束函数，返回参数，但必须是语句块中的最后一句，即 return 只能出现在，语句块的结尾，或是 end，else 和 until 的前面
function test3()
    print(1)
    --return math.pi --'end' expected (to close 'function' at line 123) near 'print'
    print(2)
end
test3()