--对象是真实世界的实体，对象与实体是一一对应的，也就是说现实世界的每一个实体都是对象，它是一个具体的概念。
--类是具体某些共同特征的实体的集合，它一种抽象的概念。
--而 lua 中 -对象是对象{}，类也是对象{}，对象{}也是类。

--数据成员
shape = {
    _width = 100,
    _height = 100,
    _getWidth = function()
        return _width --无法访问表中的数据成员
    end
}
print(shape._width)
print(shape._height)
print(shape._getWidth()) --nil

--函数成员与 self
shape = {
    _width = 100,
    _height = 100,
    area = function(self)
        --对象是不可以在函数中直接访问其数据成员的，每次要将对象作为参数传入才可
        return self._width * self._height
    end
}
print(shape.area(shape))

--self 与 function Shape:area()
--使用语法糖后，只能采用 self 作为默认传入的参数。
--且语法糖的函数定义只能为 function Shape:area()，而这种写法 Shape:area = function()，则不可行，且仅限于在表外实现。
shape = {
    _width = 100,
    _height = 100,
}
function shape:area()
    return self._width * self._height
end
print(shape:area()) --注意，这里是:

--继承
--三表结构-setmetatabl
local other = { x = 55 }
local mt = {
    __index = other
}
local my = {}
setmetatable(my, mt)
print(my.x)

local other = { x = 66 }
local mt = { __index = other }
local my = setmetatable({}, mt)
print(my.x)

--二表结构-自锁引
--所谓的自索引，即将元表中的，__index 方法指向，元表本身。可以省却一张额外的表。这种作法，在类继承中比较常用。
local mt = { x = 4 }
mt.__index = mt
local my = setmetatable({}, mt)
print(my.x)

--自索引结构中的函数成员
Father = {
    x = 1, y = 2
}

function Father:dis()
    --当 Son 来调用 Father 中的 dis 的时候，Father 中的 self 是 son 而不是Father,此时，self.x，仍然是找不到的。
    --再次找元表，找__index 元方法，__index 自索引到Father 本身，而 Father 中正好有 x 成员。
    print("in Father:dis", self)
    print(self.x, self.y)
end

Father.__index = Father

Son = {
    a = 11, b = 99
}

setmetatable(Son, Father)
print(Son.a, Son.b)
print(Son.x, Son.y)
print("Father=", Father)
print("Son=", Son)
Son:dis()

--类与对象
--lua 中并没有类这个概念，所谓的类也不过是一个对象，只是这个对象，提供了创建新对象的方法。
Account = { balance = 0 }

function Account:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self     --自索引
    return o
end

Account.balance = 11
a = Account:new()
b = Account:new()
print("Account balance", Account.balance) --11
print("a balance", a.balance) --11
print("b balance", b.balance) --11
a.balance = 22 --新加了字段
print(a.balance, b.balance, Account.balance) --22 11 11
b.balance = 99 --新加了字段
print(a.balance, b.balance, Account.balance) --22 99 11

--对象 a 和 b 第一次访问 balance 时候，self.balance 会引发__index 行为，
--而 self.balance被赋值，引发的时__newindex 行为，此时__index 是 Account 而__newindex 是空。
--故而 self.balance 访问了 Account 的 balance，而 self.balance 增加了 balance 字段。

function Account:deposit(v)
    self.balance = self.balance + v --两个 balance 并不一样 写时复制
end

function Account:withdraw(v)
    self.balance = self.balance - v
end

--对象的差异性(独立)来自，传入的参数和写时产生字段。
Account.balance = 0
a = Account:new()
b = Account:new()
print(a.balance, b.balance, Account.balance)
a:deposit(100)
print(a.balance, b.balance, Account.balance)
b:deposit(199)
print(a.balance, b.balance, Account.balance)

--类/对象/继承/覆写
Account = { balance = 0 }

function Account:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Account:deposit (v)
    self.balance = self.balance + v
end

function Account:withdraw (v)
    -- 普通账户不可以透支.
    if v > self.balance then
        --error("insufficient funds")
        print("insufficient funds")
    end
    self.balance = self.balance - v
end

acc = Account:new()
acc:deposit(300)
print(acc.balance)
acc:withdraw(500) --error("insufficient funds")

--子类(信用卡)
CreditAccount = Account:new()

--子类对象
--此时 new 是继承方法，CreditAccount 的 metatable 是 Account 是自索引的。
--Account 中有 new 方法。只不过，此时 new 中的 self 己经是 CreditAccount 了。
credit = CreditAccount:new({ limit = 2000.00 })

function CreditAccount:getLimit ()
    return self.limit or 0
end

--重写
function CreditAccount:withdraw (v)
    -- 信用卡账户在一定额度内可以透支。
    if v - self.balance >= self:getLimit() then
        --error "insufficient funds"
        print("insufficient funds")
    end
    self.balance = self.balance - v
end

--实际调用的是"Account.deposit()"
credit:deposit(100.00)
-- 此时调用的是"CreditAccount:withdraw()".
credit:withdraw(200.00)
print(credit.balance) --> -100.0

--读时，在本身中找，找不到到父类中找，写时，在本身中生成新字段。一旦有了新字段，则不需要再引发__index 行为。

--成员私有化-上值
--使用两个"table"，其一存储私有成员，另一个存储公有成员和公有方法，两个"table" 组成"Closure"，私有"table"作为公有"table"的"Closure"被访问，私有方法直接存储在 "Closure"中。
--闭包的构成，是返回函数中的函数，此时，返回的是表，但是表中有函数，是函数中 表的成员函数，也会构成闭包。
function newAccount(initialBalance)
    -- 私有"table".
    local priv = {
        balance = initialBalance,
        count = 0
    }
    -- 私有方法,未导出到公有"table"中,外部无法访问.
    local addCount = function(v)
        priv.count = priv.count + v * 0.1 -- 消费的 10%作为积分.
    end
    local withdraw = function(v)
        priv.balance = priv.balance - v
    end
    local deposit = function(v)
        priv.balance = priv.balance + v
        addCount(v)
    end
    local getBalance = function()
        return priv.balance
    end
    local getCount = function()
        return priv.count
    end
    -- 公有"table".
    return {
        withdraw = withdraw,
        deposit = deposit,
        getBalance = getBalance,
        getCount = getCount
    }
end

acc = newAccount(1000)
print(acc.balance)-- nil
print(acc.getBalance())--1000
print(acc.getCount())--0
acc.deposit(99)
print(acc.getBalance())--1099
print(acc.getCount())--9.9

--函数 self->函数独立
--self 保证了函数的独立性，只有逻辑没有数据，数据来自传入的调用者自身。

--对象 o = o or {}->数据独立
--对象提供的 new 中返回对象 o，保证的数据的独立性。

--机制 meta
--lua 中的 metatable 和 metafuction，提供了继承机制。
--self.balance = self.balance - v 。两个 self.balance 分别代表，在本对象添加新的成员和本对象内找不到会去父类查找。
--还有对象函数成员自实现，会覆盖父类成员，以实现增加新功能。


--cocos2dx-lua 之 class 函数
function class(classname, super)
    local superType = type(super)
    local cls
    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end
    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}
        if superType == "table" then
            -- copy fields from super
            for k, v in pairs(super) do
                cls[k] = v
            end
            cls.__create = super.__create
            cls.super = super
        else
            cls.__create = super
            cls.ctor = function()
            end
        end
        cls.__cname = classname
        cls.__ctype = 1
        --c++
        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k, v in pairs(cls) do
                instance[k] = v
            end
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, { __index = super })
            cls.super = super
        else
            cls = {
                ctor = function()
                end
            }
        end
        cls.__cname = classname
        cls.__ctype = 2
        -- lua
        cls.__index = cls
        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...) -- 调用父类或自实现
            return instance
        end
    end
    return cls
end

A = class("A")
function A:ctor()
    print("A:ctor")
end
function A:run()
    for i = 0, 10 do
        print("====", i, "====")
    end
end
a = A:new()
a:run()

--更简单的面向对象-函数实现
--面向对象的两大特性，一封装，二继承，封装己有表 table 来表示，继承，即复用，只要实现了复用，也就是实现了继承。
--如下采用了复制表和闭包的方式来实现复用。也是 lua 中常用的方式。

--复制表实现 clone-copy
function clone(t)
    local m = {}
    for k, v in pairs(t) do
        m[k] = v
    end
    return m
end

local Father = {}
function Father:getName ()
    print("fatherName : ", self.name)
end

function Father:new (name)
    local o = clone(Father)
    o.name = name
    return o
end

f = Father:new("zhangsan")
print(f:getName())

--Son public Father
function clone(t)
    local m = {}
    for k, v in pairs(t) do
        m[k] = v
    end
    return m
end

function copy(a, b)
    for k, v in pairs(b) do
        a[k] = v
    end
    return a
end

local Father = {}

function Father:getName ()
    print("fatherName : ", self.name)
end

function Father:new (name)
    local o = clone(Father)
    o.name = name
    return o
end

f = Father:new("zhangsan")
print(f:getName())

local Son = {}

function Son:getAge()
    print("sonAge : ", self.age)
end

function Son:new (name, age)
    local t = copy(clone(Son), Father:new(name))
    t.age = age
    return t
end

local s = Son:new("wangwu", 28)
print(s:getName())
print(s:getAge())
s.age = 99
print(s:getName())
print(s:getAge())

--闭包实现 closer
--当一个函数内嵌套另一个函数的时候，内函数可以访问外部函数的局部变量。具体可解析为：
--1）外部函数，通常可以称为工厂函数，
--2）内部函数通常称为闭包，
--3）可访问的局部变量称为上值。
function Class()
    local x = 1
    local y = 2
    local t = {}
    t.getx = function()
        return x
    end
    t.gety = function()
        return y
    end
    return t
end
local a = Class()
print(a.getx())
print(a.gety())

--Father 是一个函数，返回一个父类对象。
local function Father(name)
    local self = {}
    local function init()
        self.name = name
    end
    self.getName = function()
        print("my name is " .. self.name)
    end
    init()
    return self
end
local p = Father("zhangsan")
p.getName()

local function Son(name, age)
    --继承自父类，即获得父类的对象
    local fo = Father(name)
    local so = {}
    local function init()
        so.age = age
    end
    so.getAge = function()
        print("myage is " .. so.age)
    end
    so.getName = function()
        print("MY NAME IS " .. fo.name)
        fo.getName()
    end
    init()
    return so
end
local m = Son("lisi", 18)
m.getName()
m.getAge()