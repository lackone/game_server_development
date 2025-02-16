--table 是 Lua 中唯一的数据结构，其他语言所提供的数据结构，如：arrays、records、lists、 queues、 sets 等，
--Lua 都是通过 table 来实现，并且在 lua 中 table 很好的实现了这些数据结构。

--在 Lua 中，数组下标从 1 开始计数。
--只有键值从 1 开始连续的元素放在 table 里，才可以作为数组 sequence 使用

--一维数组
arr = { "lua", "java", "c++" }
for i = 1, 3 do
    print(arr[i])
end

--给定下标
--使用负数索引数组
for i = -2, 2 do
    arr[i] = i * 2
end
for i = -2, 2 do
    print(arr[i])
end

--二维数组
--数组的数组(一维数组中的每个元素，又是一个数组)
--一维数组通过控制索引(一维数组，二维逻辑)
arr = {}
for i = 1, 3 do
    arr[i] = {}
    for j = 1, 3 do
        arr[i][j] = i * j
    end
end
for i = 1, 3 do
    for j = 1, 3 do
        io.write(arr[i][j], " ")
    end
    io.write("\n")
end

--一维数组通过控制索引
arr = {}
for i = 1, 3 do
    for j = 1, 3 do
        arr[(i - 1) * 3 + j] = i * j
    end
end
for i = 1, 3 do
    for j = 1, 3 do
        io.write(arr[(i - 1) * 3 + j], " ")
    end
    io.write("\n")
end

--table->array 库
--这个库提供了表处理的通用函数。 所有函数都放在表 table 中。
for k, v in pairs(table) do
    print(k, v)
end

--拼接 table.concat (list [, sep [, i [, j]]])
--排序 table.sort(list [, comp])
--插入 table.insert(list , [pos, ] value)
--打包 table.pack (...)
--解包 table.unpack (list [, i [, j]])
--删除 table.remove (list [, pos] )
--拷贝 table.move (a1, f, e, t [,a2])

--长度#
print(#"hello")
print(#{ 1, 2, 3, 4 })
test = { 11, 22, 33, 44, 55 }
print(test[#test]) -- 输出最后一个元素
test[#test] = nil --移除最后一个元素
test[#test] = 999 --把 999 添加到序列最后

--连接 concat
arr = { "aa", "bb", "cc" }
print(table.concat(arr))
print(table.concat(arr, " ")) --用字符串连接
print(table.concat(arr, " ", 2, 3)) --基于索引连接
print(table.concat(arr, " ", 1, 2)) --基于索引连接

--插入删除 insert&remove
--insert 和 remove 在没有指定下标的时候，指的是从尾部插入和删除。
table.insert(arr, "dd")
print(table.concat(arr, " "))
table.insert(arr, 2, "gg")
print(table.concat(arr, " "))
table.remove(arr)
print(table.concat(arr, " "))

--借助这两个函数，可以轻松的是实现，栈(Stack),队列(Queue)和双端队列(Doublequeue)。
--以栈为例：t = {} Push 操作可以使用 table.insert(t，1，x)实现，Pop 操作可以使用 table.remove(t，1)。
stack = {}
table.insert(stack, 1, "a")
table.insert(stack, 1, "b")
table.insert(stack, 1, "c")
print(table.concat(stack, " "))

for i = 1, #stack do
    print(table.remove(stack, 1))
end

--排序 sort
--sort 支持默认的排序规则，也可以人为的指定排序规则
word = { "aaa", "ddd", "ccc", "bbb" }

table.sort(word)
print(table.concat(word, " "))

table.sort(word, function(a, b)
    return a > b
end)
print(table.concat(word, " "))

--移动 move
--table.move(a,f,e,t) 调用该函数，可以将表 a 中从索引 f 到 e 的元素(闭区间)，移动到本表 a 位置 t 上。
arr = { "a", "b", "c" }
table.move(arr, 1, #arr, 2) --列表头插入元素
arr[1] = "gg"
print(table.concat(arr, " "))
table.move(arr, 2, #arr, 1) --删除头元素
arr[#arr] = nil
print(table.concat(arr, " "))

--table.move 还支持使用一个表作为可选参数 table.move(a, f, e, t, {})，当参数是一个表时，该函数将一个表中的元素 clone 第二个表中。
copy = table.move(arr, 1, #arr, 1, {})
print(table.concat(copy, " "))

--真序列(纯数组无哈希)
--真正的数组，必须满足，key 值为整型，下标从 1 开始，且连续，如果这些条件不满足，不能用数组的方式处理之。

--序列中无 nil 无效值
--数组中有了nil，会导致 #失效
print(#{ 1, 2, nil, 3 })
print(#{ 1, 2, nil, 3, nil })
-- ipairs 失效
--数组中的 nil 影响求长度，长度不定的数组，无法通过下标对其遍历，迭代函数 ipairs遍历则会中止。
arr = { 1, 2, 3, 4, nil, 6, 7, 8 }

for k, v in ipairs(arr) do
    print(k, v)
end

-- pairs 有效，但 nil 是不输出的。
for k, v in pairs(arr) do
    print(k, v)
end

--数组中尽可能不要放置无效值 nil，实在无可而为之，则可以采用记录数组长度的方式+nubmer for 来遍历，或用 pairs 迭代器访问。
for i = 1, 8 do
    --if arr[i] then
    --    print(arr[i])
    --end
    print(arr[i])
end

for _, v in pairs(arr) do
    print(v)
end