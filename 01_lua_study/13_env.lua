--_G
--所谓 lua 的环境就是指的是_G 这张表，_G 也是一张普通的全局表。只是他存储了全局环境的值。

for k, v in pairs(_G) do
    print(k, v)
end

--使用_G
--_G 代表的是全局有名空间，类似于 C++中的全局无名命名空间 :: ,假设有全局函数，也可以这样设用的，::func()。
_G.print("hello")

_G.print(_G.string.format("name=%s age=%d", "test", 33))

arr = { 3, 1, 2, 5, 8, 7, 6 }
_G.table.sort(arr)
_G.print(table.concat(arr, "-"))

_G.math.randomseed(_G.os.time())
for i = 1, 10 do
    print(_G.math.random(100))
end

--沙盒 sandbox

--改变环境(lua5.1)
--函数的上下文环境可以通过 setfenv(f，table) 函数改变，其中 table 是新的环境表，f 表示需要被改变环境的函数。
--如果 f 是数字，则将其视为堆栈层级(Stack Level)，从而指明函数( 1 为当前函数，2 为上一级函数 )：
a = 33
--setfenv(1, {}) --将当前环境表改变空表
print(a) --当前环境表中 print 已经不存在了

function test()
    a = 33
    --setfenv(1, { g = _G })
    --g.print(a) --nil
    --g.print(g.a) --33
end
test()

--沙盒(lua5.1)
local l_env = { -- 沙盒环境表，按需要添入允许的函数
    print = _G.print,
    os = _G.os,
    math = _G.math,
}
function run_sandbox(code)
    local func, msg = loadstring(code)
    if not func then
        return nil, msg
    end
    setfenv(func, l_env)
    return pcall(func)
end
--run_sandbox("print(\"abc\") print(os.time()) print(math.pi)")

--_ENV 变量(lua5.3)
--全局名字的本质
--Lua 5.2 中所有对全局变量 var 的访问都会在语法上翻译为 _ENV.var。而 _ENV 本身被 认为是处于当前块外的一个局部变量。
print(string.upper("test"))
_ENV.print(_ENV.string.upper("hello"))
_G.print(_G.string.upper("world"))

--我们用的_G，也是_ENV 中的_G，此时若将_G 置为 nil，print 函数依然是可以用的，为什么呢？
--因为此时只是将_ENV._G = nil 而己。若将_ENV = nil 而 print 函数不再可以使用了。
print(_ENV._G)
--_G = nil
print(_ENV._G) --nil
print("hello,world")
--_ENV = nil
--print("hello,world") --nil

--兼容_ENV 与_ENV._G 与_G
print(_G)
print(_ENV._G)
print(_ENV)

--5.3 以前，全局变量是以默认_G 开始的，5.3 以后，全部是以_ENV 开始的，也可以认为是_ENV._G 开始的，
--或是以_G 开始的，因为_ENV 和_ENV._G 是相等的，这样作是为兼容以前的版本。

--_ENV 使用规则
--1. 编译器在编译所有代码前，在外层创建 局部变量_ENV
--2. 编译器将所有全局的名称 var,变换为_EVN.var
--3. 函数 load 或(loadfile) 使用全局环境来初始化_ENV 作为一个上值。
a = 1
local a = 22
print(a) --22
print(_ENV.a) --1
print(_ENV._G.a) --1

b = 66
--_ENV = { g = _G }
b = 33
--g.print(b, g.b) --33 66

--创建局部沙盒环境
function factory(_ENV)
    return function()
        return c
    end
end
f1 = factory { c = 9 }
f2 = factory { c = 99 }
print(f1()) --9
print(f2()) --99

a = 88
function get_echo()
    local _ENV = { print = print, a = 2, string = string }
    return function()
        print(a) --88
        print(string.upper("test")) --TEST
    end
end
get_echo()()

--_ENV 改写 5.1 的案例
local l_env = {
    print = _ENV.print,
    os = _ENV.os,
    math = _ENV.math,
    string = _ENV.string,
}

function run_sandbox(code)
    local func, msg = load(code, "lua", "t", l_env)
    if func == nil then
        return nil, msg
    end
    pcall(func)
end
run_sandbox("print(\"abc\") print(os.time()) print(math.pi)")

--补充 load (chunk [, chunkname [, mode [, env]]])
--chunk 为函数或字符串
--mode 为加载模式:”t”文本样式,”b”二进制样式,”bt”二进制和文本模式.
--env 代码块需要的参数