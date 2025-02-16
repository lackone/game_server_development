-- Lua 语言提供的控制结构有 if，while，repeat，for，并提供 break 关键字来满足更丰富的需求。

--选择 if else
x = 10
if x > 0 then
    print("x > 0")
end

--两个分支 if-else 型
if x > 0 then
    print("x > 0")
else
    print("x <= 0")
end

-- if-elseif-then-else
score = 90

if score == 100 then
    print("100")
elseif score >= 60 then
    print(">=60")
else
    print("<60")
end

-- 与 C 语言的不同之处是 else 与 if 是连在一起的，若将 else 与 if 写成 "else if" 则相当于在 else 里嵌套另一个 if 语句

--while 循环
local i = 0
local sum = 0
while i < 100 do
    sum = sum + i --lua中没有+=
    i = i + 1 --lua中没有i++这种
end

--repeat 循环
--执行 repeat 循环体后，直到 until 的条件为真时才结束
x = 10
repeat
    print(x)
    x = x - 1
until x == 0

--for 控制结构
--for 语句有两种形式：数字 for(numeric for) 和范型 for(generic for)，循环的控制变量默认是局部的，循环完了就没了。
--var 从 exp1 变化到 exp2，每次变化以 exp3 为步长递增 var，并执行一次"执行体"。exp3是可选的，如果不指定，默认为 1。
--for var = exp1, exp2, exp3 do
--执行体
--end
--① 三个表达式，只计算一次
--② 且 var 是一个局部变量。
for i = 1, 10 do
    print(i)
end
for i = 10, 1, -1 do
    print(i)
end

--泛型 for 循环通过一个迭代器函数来遍历所有值，类似 C++模板库 STL 中的 foreach 语句。
--Lua 编程语言中泛型 for 循环语法格式，i 是数组索引值，v 是对应索引的数组元素值。
--ipairs 是 Lua 提供的一个迭代器函数，用来迭代数组。
local b = { 11, 22, 33, 44, 55 }
for k, v in ipairs(b) do
    print(k, v)
end

-- 跳转
-- break 和 return 可以跳出程序块，而 goto 可以跳到任意位置。

--多返值
function test()
    return 1, 2, 3
end
local a = test()
local x, y, z = test()
local aa, bb, cc, dd, ee = test()

--return 只能出现在，语句块的结尾，或是 end，else 和 until 的前面。
function test2()
    return --正常打印，return 无意义
    print("test2")
end
test2()

function test3()
    return 0 --报错
    --print("test3")
end
test3()

function test4()
    do
        return 0
    end --这样才能成功
    print("test4")
end
test4()

--break
--break 只用于循环结构 for，repeat，while。break 充当阈值的作用，到了点，就跳出循环。
for i = 1, 10 do
    if i == 5 then
        break
    end
    print(i)
end

--lua 虽然没有提供 continue 逻辑，contiune 的逻辑本质就是过滤，可以能过合理的安排逻辑解决，或是采用 goto 模仿 continue 逻辑。
for i = 1, 10 do
    if i % 2 == 0 then
        goto END
    end
    print(i)
    :: END ::
end

--goto(::LABEL::)
--goto 语句，可以跳到程序中的任意 Label 标号，其 Label 的书写方式 ::name:: 。
--注意标号处的语句是依次执行的。不要理解为 Label 后的语句是函数，等待被调用。
i = 0
:: Label ::
do
    print(i)
    i = i + 1
end
if i > 3 then
    os.exit()
end
goto Label

--1. Label 可见原则：不能在 block 外面跳入 block(因为 block 中的 Label 不可见)，但是可以跳出 block( do end )
--2. 不能跳出或者跳入一个函数 fucntion。根据第一条原则，跳入是不可以的，此时函数跳出也不可能。
--3. 不能跳入局部变量的作用域，在局部范围以内跳转，不能割裂一个局部变量的作用域。

--应用之 continue 与 redo
i = 0
while i < 10 do
    :: redo ::
    i = i + 1
    if i % 2 == 1 then
        goto continue
        -- 条件不满足,下一个continue
    else
        print(i)
        goto redo
        -- 条件满足,再来一次redo
    end
    :: continue ::
end