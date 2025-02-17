--Lua 提供了自实现版本的模式匹配
--字符串标准库提供了基于模式(pattern)的 4 个函数。我们己经初步了解了函数 find 和gsub，其余的两个函数是 match 和 gmatch(Global Match)。

--string.find (s, pattern [, init [, plain]])
--参数 init 指明从哪里开始搜索
--plain 正如其字面意思，表示纯字符串搜索。默认为 false

str = "hello,world"
i, j = string.find(str, "ll")
print(i, j)

print(string.sub(str, i, j))

--有特殊含义的字符，比如[，可能会导致搜索失败。
print(string.find("a[bcd]", "[", 1, true))

--记录换行位置与下标
words = [[
abc
xyz
test
hello
]]

local i = 0
local m = {}
while true do
    i = string.find(words, "\n", i + 1)
    if i == nil then
        break
    end
    m[#m + 1] = i
end
for k, v in ipairs(m) do
    print(k, v)
end

--string.match
--返回的是查找到的子串，而非 string.find 起始结束位置
print(string.match("hello lua world", "lua"))

print(string.match("today is 2025/1/1", "%d+/%d+/%d+"))

--string.gsub(stitute)
--string.gsub(s, pattern, repl [, n])
--目标字符串，模式，替换字符串，替换的次数

print(string.gsub("hello,lua is ok", "lua", "java"))

--string.gmatch
--返回一个迭代器函数，每一次调用这个函数，返回一个在字符串 s 找到的下一个符合pattern 描述的子串
for w in string.gmatch("hello test lua", "%a+") do
    print(w)
end

for num in string.gmatch("12china34,is56ok", "%d+") do
    print(num)
end

for k, v in string.gmatch("name=test age=12 addr=ching", "(%w+)=(%w+)") do
    print(k, v)
end

--模式 pattern
--Lua 中使用百分号%（percent sign）作为转义字符 (此类于 c 中的 printf) ， 所有被转义的字母都具有特殊的含义。
--%a  代表字母 a-z A-Z             %A
--%c  代表控制字符                  %C
--%d  代表数字(0-9)                %D
--%l  代表小写字母 a-z              %L
--%u  代表大写字母 A-Z              %U
--%s  代表空白字符                  %S
--%p  代表标点字符                  %P
--%g  代表除了空格外的所有可打印字符    %G
--%w  代表字母或者数字的字符          %W
--%x  表示所有 16 进制数字符号

--将所有字符替换为.
print(string.gsub("hello ,up-down", "%a", '.'))
--将所有非字符替换为.
print(string.gsub("hello ,up-down", "%A", '.'))

--魔法字符 magic character
--%   用于转义                           %a %? %%        %%
--.   表示任意一个字符                    a. 匹配 ax ab ay  %.
--[]  字符集(自定义自符分类)                                %[ %]
--()  捕获                                               %( %)
--^   以^开头，表示从目录字符串的开头开始匹配
--$   以$结尾，表示匹配到字符串的结尾

--[]自定义自符分类
--%d == [0-9]，%x == [0-9a-fA-F]，%a = [a-zA-Z] ，[0-7] ==[01234567]
--[%w_] 匹配，所有以下划线结尾的字母和数字
--[01]  匹配所有的二进制数字。
--[%[%]] 匹配方括号。
--[AEIOUaeiou] 表示任意元音字毒
print(string.gsub("ab1cd2efg3xyz4", "[1234]", "_"))

--magic character modifer
--lua 语言中提供了 4 中修饰符，称为可选修饰符 modifer。用于描述模式中重复和可选部分的修饰。
--+   重复前一项 1 次或多次，尽可能多   ax+ 匹配 ax axxx      %+
--*   重复前一项 0 次或多次，尽可能多   ax* 匹配 a ax axxx    %*
---   重复前一项 0 次或多次，尽可能少   ax- 匹配 a ax axxx    %-
--?   重复前一项 0 次或 1 次          ax? 匹配 a ax         %？

--修饰符+
--用于匹配字符分类中一个或多个字符，它总是能获得与模式相匹配的最长序列
for v in string.gmatch("one, and two; and three 1,22,33,55,abcd", "%a+") do
    print(v)
end

--修饰符*
--类似于+号，但是接受对应字符出现零次的情况。
text = [[
()
( )
(    )
]]
print(string.gsub(text, "%(%s*%)", "{}"))

--修饰符-
--则会尽可能少的匹配，再来一个案例
str = "int x; /*x*/ int y; /*y*/"
print((string.gsub(str, "/%*.*%*/", ""))) --.*会尽可能长的匹配

print((string.gsub(str, "/%*.-%*/", ""))) --.-则会尽可能少的匹配

--修饰符？
--用于匹配一个可选的字符，即有或无的选择
digit = [[
123xxxx+456xxx-111
]]
for v in string.gmatch(digit, "[+-]?%d+") do
    print(v)
end

--模式%b，匹配成对的字符串，%bxy 表示 x 为起始字符，y 为结束字符。
--常用的还有，%b() %b[] %b{} %b<>
print((string.gsub("a (enclosed (in) parentheses ) line", "%b()", "")))

--()捕获
--捕获(capture)，机制允许根据一个模式从目标字符串中抽出与该模式匹配的内容来用于后续用途
k, v = string.match("name = test", "(%a+)%s*=%s*(%a+)")
print(k, v)

y, m, d = string.match("today is 2025/1/1", "(%d+)/(%d+)/(%d+)")
print(y, m, d)

--匹配复用
--在模式中，形如%n(其中 n 是一个数字)，表示匹配第 n 个捕获的副本。

--捕获第一个引号，用它来指明第二个引号，第一个捕获的是引号本身，第二个捕获的是引号中的内容。
q, qc = string.match([[then he said: "It's all right"]], "([\"'])(.-)%1")
print(q, qc)

print(string.match("a = [=[[[ something ]] ]==] ]=]; print(a)", "%[(=*)%[(.*)%]%1%]"))

--gsub 中替换部分

--如果 repl 是一个字符串
-- repl 中的所有形式为 %d 的串表示 第 d 个捕获到的子串，d 可以是 1 到 9 。串 %0 表示整个匹配。 串 %% 表示单个 %。
print(string.gsub("hello world", "(%w+)", "%1- %1"))

print(string.gsub("hello world", "%w+", "%0- %0"))

print(string.gsub("hello world", "%w+", "%0- %0", 1))

print(string.gsub("hello world from Lua", "(%w+)%s*(%w+)", "%2- %1"))

function trim(s)
    return string.gsub(s, "^%s*(.-)%s*$", "%1")
end
print(trim("\t a bc d "))

--如果 repl 是张表
print(string.gsub("$name-$version.tar.gz", "%$(%w+)", {
    name = "lua", version = "0.0.1"
}))

--如果 repl 是个函数
--如果 repl 是个函数，则在每次匹配发生时都会调用这个函数。
print(string.gsub("4+5 = $return 4+5$", "%$(.-)%$", function(s)
    return load(s)()
end))

print(string.gsub("PATH = $PATH, os = $OS", "%$(%w+)", os.getenv))