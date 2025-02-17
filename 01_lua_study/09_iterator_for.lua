--迭代器是一种结构，使能够遍历所谓的集合或容器中的元素。
arr = { "java", "c++" }

for k, v in ipairs(arr) do
    print(k, v)
end

--在 Lua 中，我们使用函数来表示迭代器。基于这些迭代器的功能状态保持，有两种主要类型：无状态的迭代器，有状态迭代器。

--虚变量(占位)
--用虚变量(_)来占位
for _, v in ipairs(arr) do
    print(v)
end

function myiter(tab)
    local idx = 0
    local cnt = #tab
    return function()
        idx = idx + 1
        if idx <= cnt then
            return tab[idx]
        end
    end
end

for v in myiter(arr) do
    print(v)
end

--泛型 for 与其等价关系
--for var-list in exp-list do
--  body
--end

--for var_1,...,var_n in explist do
--    block
--end

--explist 只会被计算一次。它返回三个值，一个 迭代器 函数_f，一个 状态_s，一个 迭代器的初始值_v。
--do
--    local _f,_s,_v = explist
--    while true do
--        local var_1,... ,var_n = _f(_s,_v)
--        if var_1 == nil then
--            break
--        end
--        _v = var_1
--        ----------------------------------
--        block
--        ----------------------------------
--    end
--end

--ipairs 与其等价关系
--do
--    local _f, _s, _v = ipairs
--    while true do
--        local k, v = _f(_s, _v)
--        if k == nil then
--            break
--        end
--        _v = k
--        --代码
--        --block
--    end
--end

--无状态的迭代器
--由名字本身就可以明白，这类型的迭代器功能不保留任何状态，也就是迭代版本，需要传入参数，得到下一个状态。

--引入 square, 3, 0
function square(max, ins)
    if ins < max then
        ins = ins + 1
        return ins, ins * ins
    end
end
for i, n in square, 3, 0 do
    print(i, n)
end

do
    local _f, _s, _v = square, 3, 0
    while true do
        local k, v = _f(_s, _v)
        if k == nil then
            break
        end
        _v = k
        print(k, v)
    end
end

--引入 square, 3, 0 -> for squareS(3)
function squareS(mx)
    return square, mx, 0
end

do
    local _f, _s, _v = squareS(3)
    while true do
        local k, v = _f(_s, _v)
        if k == nil then
            break
        end
        _v = k
        print(k, v)
    end
end

for i, n in squareS(3) do
    print(i, n)
end

--无状态 ipairs
--迭代的状态包括被遍历的表（循环过程中不会改变的状态常量）和当前的索引下标（控制变量）
arr = { 11, 22, 33, 44, 55 }

function myiter(arr, i)
    i = i + 1
    local v = arr[i]
    if v then
        return i, v
    end
end

function myiterS(arr)
    return myiter, arr, 0
end

for k, v in myiterS(arr) do
    print(k, v)
end

--有状态迭代器
function myiter2(arr)
    local i = 0
    return function()
        i = i + 1
        if arr[i] then
            return i, arr[i]
        end
    end
end

print("----------------------------------")

do
    local _f, _s, _v = myiter2(arr) --_s和_v是nil
    while true do
        local k, v = _f(_s, _v) --迭代函数不需要参数
        if k == nil then
            break
        end
        _v = k
        print(k, v)
    end
end

--myiter2只返回一个参数，给了_f，_s和_v都是nil
for k, v in myiter2(arr) do
    print(k, v)
end

--有状态 ipairs
--先用局部变量 k，实始化迭代值，然后，在闭包内更新迭代值 k，然后返回值迭代值 k与 v。
function ipairs2(arr)
    local idx = 0
    local cnt = #arr
    return function()
        idx = idx + 1
        if idx <= cnt then
            return idx, arr[idx]
        end
    end
end

for k, v in ipairs2(arr) do
    print(k, v)
end

--链表的创建与遍历
arr = { 1, 2, 3, 4, 5, 6, 7, 8 }
head = nil

local idx = 1
while true do
    if arr[idx] then
        head = { value = arr[idx], next = head }
        idx = idx + 1
    else
        break
    end
end

print("--------------------------")

--while head do
--    print(head.value)
--    head = head.next
--end

--无状态
--无状态，就是通过参数来传递迭代的状态
function iter_list(head, next)
    if next == nil then
        return head
    else
        return next.next
    end
end

function iter_lists(head)
    return iter_list, head, nil
end

print("--------------------------")

for v in iter_lists(head) do
    print(v.value)
end

--有状态
--有状态就是通过闭包，保存迭代的状态
function iter_list2(head)
    local tmp = nil
    return function()
        if tmp == nil then
            tmp = head
        else
            tmp = tmp.next
        end
        return tmp
    end
end

print("--------------------------")

for v in iter_list2(head) do
    print(v.value)
end