-- 赋值
-- Lua 可以对多个变量同时赋值，变量列表和值列表的各个元素用逗号分开，赋值语句右边的值会依次赋给左边的变量。
--当变量个数和值的个数不一致时，Lua 会一直以变量个数为基础采取以下策略：
--(1) 变量个数>值的个数，多余变量赋值 nil。
--(2) 变量个数<值的个数，多余的值会被忽略
a, b = 3, 4;
c = 5;
d = 6;

x, y = 1, 2;
x, y = y, x;
print(x, y)

-- lua 中的赋值表达式的值是没意义的。
-- if (a = 1) then
-- end

-- 多个变量同时定义
-- 不支持 local aa = 3, bb = 4;
local aa = 1;
bb = 44;
local aa, bb = 33, 44

-- 算术
print(2 + 2) --加法
print(5 - 3) --减法
print(2 * 10) --乘法
print(1 / 3) --除法（浮点）
print(3 ^ 3) --指数
print(10 % 3) --取模，求余
print(10 // 3) --向下取整除法

-- 关系
print(1 < 3)
print(1 == 3)
print(1 ~= 3) --不等于

-- Lua 语言中，运算的类型要相同，类型不同间比较，值为 false。
function compare(a, b)
    if type(a) == "number" and type(b) == "number" then
        if a == b then
            return true;
        else
            return false;
        end
    else
        return false;
    end
end
print(compare(1, "1"))

-- 在使用 "==" 做等于判断时，要注意对于 table，userdata ，function 和 threads 是对象，在 lua 中对象是引用的方式存在的，赋值、传参、返回均不会引起拷贝行为。
local aa = { x = 1, y = 0 }
local bb = { x = 1, y = 0 }

if aa == bb then
    print("aa == bb")
end
-- 也就是说，只有当两个变量引用同一个对象时，才认为它们相等。而含有相同内容的两个对象，我们认为是不等的。
local cc = aa;
if aa == cc then
    print("aa == cc")
end

--由于 Lua 字符串总是会被"内化"，即相同内容的字符串只会被保存一份，因此 Lua 字符串之间的相等性比较可以简化为其内部存储地址的比较。
str1 = "hello"
str2 = "hello"
if str1 == str2 then
    print("str1 == str2")
end

-- 逻辑
-- 逻辑运算的结果，即为参与逻辑运算者之一，故(返值类型不定)，除了 not。
--a and b   当 a 为真时返回 b， 当 a 为假时，返回 a    条件表达式 a ? b : a
--a or b    当 a 为真时返回 a， 当 a 为假时，返回 b    条件表达式 a ? a : b
--not a     当 a 为真时返回假，当 a 为假时，返回真      条件表达式 a ? false : true

local c = nil
local d = 0
local e = 100
print(c and d) -->打印 nil
print(c and e) -->打印 nil
print(d and e) -->打印 100
print(c or d) -->打印 0
print(c or e) -->打印 100
print(not c) -->打印 true
print(not d) -->打印 false

--所有逻辑操作符将 false 和 nil 视作假，其他任何值视作真，对于 and 和 or， "短路求值"，对于 not，永远只返回 true 或者 false。

-- ? : 三目运算符
-- 真三目 x = x or b <==> x ? x : b
local x = 3 or 5
print(x)

-- 优先级
-- 算术 > 关系 > 逻辑