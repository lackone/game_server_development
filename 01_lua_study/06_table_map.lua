--前一章讲的是 table 中 k 为整数的情况，初始表 t = {"r","g","b"}和 t = {[1] = "r", [2] = "g", [3] = "b"}，是等价的，通常我们会写为第一种形式。

--k-v->hash
aa = { x = 0, y = 0 }
bb = { ["x"] = 0, ["y"] = 0 }

--成员赋值
aa.x = 33
bb.x = 44

--成员访问
print(aa.x)
print(bb["x"])

--数组的初始化，存入单值，哈希初始化，放的是键值对。数组的访问方式是统一的[]，哈希的访问方式有两种， 一种是 . 一种是 []。
cc = {}
key = "x"
cc[key] = 99
print(cc[key], cc["x"])
cc[10] = "ok"
key = 10
print(cc[key], cc[10])

--a.x with a["x"]
dd = {}
key = "y"
dd[key] = 10
print(dd[key])
print(dd.key) --输出nil
print(dd.y)

--index in any type
--可以用任意类型的值来作数组的索引，但这个值不能是 nil。
ee = {}
ee[10] = "aa"
ee["10"] = "bb"
ee["+10"] = "cc"
ee[tonumber("11")] = "dd"
ee[1.0] = 3.33
ee[2.0] = 4.44

--遍历
stu = {
    name = "test",
    age = 22,
    sex = "男"
}
for k, v in pairs(stu) do
    print(k, v)
end

--引用
--我们用到的所有的 table 都是匿名的，所有的变量，只是对其引用而己。我们对于 table的操作仅仅是对其引用的操作。
a = {}
a["x"] = 88
b = a
print(b["x"], a["x"])
b["x"] = 99
print(b["x"], a["x"])
a = nil --取消引用
print(b["x"])
b = nil --取消引用

--表可以赋值，比较吗？
--表不存在赋值，只有引用。假设 a 引用一张表，b 也引用一张表，现在将 b = a，只能说 b 不再引用原先的表，现在同 a 引用同一个表。

--拷贝 copy
a = { x = 1, y = 2, z = 3 }

function copy(a, b)
    a = a or {}
    for k, v in pairs(b) do
        a[k] = v
    end
    return a
end

copy_a = copy(copy_a, a)
for k, v in pairs(copy_a) do
    print(k, v)
end

--比较 ==
--比较的是地址，不是值
a = { 1, 2, 3 }
b = { 1, 2, 3 }
if a == b then
    print("a == b")
else
    print("a != b")
end
c = a --引用相同
if a == c then
    print("a == c")
else
    print("a != c")
end

--表中元素个数(# table)
--Lua 中的表有两部分: "数组" 部分(使用 t = {1，2，3}生成) 和 "哈希" 部分(使用 t = {a= "foo"，["b"] = 2}生成); 这两者可以灵活地结合在一起。
--#table 返回最短的"数组"部分长度(没有任何缺口，即下标连续) 而 table.maxn(t) 返回最长的 "数组" 部分(Lua 5.3 移除了这个函数)。 "哈希" 部分没有定义长度。
print(#{ 1, 2, 3, 4 }) --4
print(#{ 1, 2, 3, [10] = 100, 4, 5, 6 }) --6
print(#{ 1, 2, [10] = 100, 3, 4, 5, name = "test", age = 33 }) --5

--只有键值从 1 开始连续的元素放在 table 里，才可以作为数组 sequence 使用，否则针对 sequence 的操作行为都是未定义的。

--真哈希(无数组)

--真 Array
--Array 可以看成一种特殊情况下的 Map。
arr = { 1, 2, 3, 4, 5 }

--真 map
--哈希，就要保持其为纯纯的哈希。即仅用于存入键值对使用，若混有数组的部分，语义不明确是其一，还可能要单独处理。
map = { name = "test", age = 33, addr = "中国" }

--混合 table
a = { 11, 22, x = 1, y = 99, 1000 }

for k, v in pairs(a) do
    print(k, v)
end