-- Lua 中有三种方式表示字符串:
--使用一对匹配的单引号.例：'hello'.
--使用一对匹配的双引号.例："abclua".
--字符串还可以用一种长括号(即[[ ]]) 括起来的方式定义.

--此处的语法类型于 C++11 中的 raw string 的用法 R"()"。
str = [[abc\nabc]]
print(str)

--Lua 的字符串是不可改变的值，不能像在 c 语言中那样直接修改字符串的某个字符，而是根据修改要求来创建一个新的字符串。
--Lua 也不能通过下标来访问字符串的某个字符。
str = "test"
print(str[1])

--number->string(..)
print(11 .. 22)
print(11 .. "abc")
print(11 .. "")

--string->number(+)
print("22" + 33)
-- print("22"+"33abc")

--tonumber&tostring
print(tonumber("23") + 11)
print(tostring(11) .. "22")

--应用->字符串拼接
local prefix = "image"
local postfix = ".jpg"
local filename
for i = 0, 10 do
    filename = prefix .. i .. postfix
    print(filename)
end

--当在Lua 中对字符串做索引时，第一个字符从 1 开始计算（而不是 C 里的 0 ）。
--索引可以是负数，它指从字符串末尾反向解析。 即，最后一个字符在 -1 位置处，等等。

--STRING API 列表

--连接 ..
--长度 string.len(str)
--大写 string.upper(str)
--小写 string.lower(str)
--反转 string.reverse(str)
--重复 string.rep(str, n)
--格式 string.format(formatstring, ...)
--string.char(...)
--string.byte(s [, i [, j ]])
--查找 string.find(s, pattern [, init [, plain]])
--分割 string.sub(s，i [, j])
str = "lua"
print(str.upper(str))
print(str.lower(str))
print(str.len(str))

--格式化
print(string.format("%d==%s", 11, "hello"))
print(string.format("%.4f", 1 / 3))
print(string.format("%c", 83)) --输出 S
print(string.format("%+d", 17.0)) --输出+17
print(string.format("%05d", 17)) --输出 00017
print(string.format("%o", 17)) --输出 21

--ASCII-》字符(串)
print(string.char(48, 49, 50, 51, 52)) --01234

--字符(串)-》ASCII-》
print(string.byte("1234"))
print(string.byte("1234", 4))

--重复
print(string.rep("test", 3))

--sub/replce/find/reverse
str = "[test]"
print(string.sub(str, 2)) --test]
print(string.sub(str, 2, 5)) --test
print(string.sub(str, 2, -2)) --test 去除头尾

-- replacing strings 替换
print(string.gsub(str, "test", "hello"))

-- find strings 查找 返回下标
print(string.find(str, "test"))

--string 是支持面向对象的，面向对象中，对象是可以数据和方法合二为一的。
local str = "china";
print(str:upper()) --CHINA
local str2 = "CHINA";
print(str2:lower()) --china
str = "china"
print(str:reverse())

--string.gmatch (s, pattern)
str = "hello world lua from Lua"
for w in string.gmatch(str, "%a+") do
    print(w)
end