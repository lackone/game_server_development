--协程 Coroutine
--Lua 协同程序(coroutine)与线程比较类似：拥有独立的堆栈，独立的局部变量，独立的指令指针，同时又与其它协同程序共享全局变量和其它大部分东西。
--线程与协同程序的主要区别在于，一个具有多个线程的程序可以同时运行几个线程，而协同程序却需要彼此协作的运行。
--在任一指定时刻只有一个协同程序在运行，并且这个正在运行的协同程序只有在明确的被要求挂起的时候才会被挂起。
--协同程序有点类似于，同步的多线程，在等待同一个线程锁的几个线程情况就有点类似于协程。

--协程注解
--协程本质上是在一个线程里面，因此不管协程数量多少，它们都是串行运行的，也就是说不存在同一时刻，
--属于同一个线程的不同协程同时在运行。因此它本身避免了所有多线程编程可能导致的同步问题。

--用 knuth 的话来说：子程序就是协程的一种特例。即函数 A 调用了函数 B，B 完成后 返回 A，而无交互的版本。有交互的版本，即协程。

--颗粒度 fine granularity
--进程>线程>协程>函数

--接口 API
--coroutine.create (f)  根据一个函数 f 创建一个协同程序
--coroutine.status (co)  以字符串形式返回协程 co 的状态：suspended running dead
--coroutine.resume (co [，val1, ...])  开始或继续协程 co 的运行
--coroutine.yield (...)  挂起正在调用的协程的执行
--coroutine.running ()  返回当前正在运行的协程和一个布尔量
--coroutine.wrap (f)   创建一个主体函数为 f 的新协程。

--协程状态
--协同有三个状态：挂起态(suspended)、运行态(running)、停止态(dead)。
co = coroutine.create(function()
    print("abc")
    print(coroutine.status(co)) --运行
end)
print(type(co))
print(coroutine.status(co), "a") --挂起
print(coroutine.resume(co), "b") --true
print(coroutine.status(co), "c") --dead
print(coroutine.resume(co), "d") --false

--yield 会出让当前的执行权限，而让自己处于 suspend 状态。
co = coroutine.create(function()
    print("1")
    coroutine.yield() --让出执行权限
    print("2")
    coroutine.yield() --让出执行权限
    print("3")
end)
coroutine.resume(co)
print("main1")
print(coroutine.status(co))
coroutine.resume(co)
print(coroutine.status(co))
print("main2")
coroutine.resume(co)
print(coroutine.status(co))

--协程传参
--yeild 三段式/resume 二情形
--Lua 中协程的强大能力，还在于通过 resume-yield 来交换数据。
--Lua 的协程称为不对称协程( asymmetric coroutines )，指"挂起一个正在执行的协同函数"与"使一个被挂起的协同程序再次执行的函数"是不同的，
--有些语言提供对称协程( symmetric coroutines )，即使用同一个函数负责"执行与挂起间的状态切换"。

--非协同协程，正是能过两个函数来实现的，coroutine.resume 和 coroutine.yield。
--协同的同时传递相关的数据。即 resume 和 yield 均是阻塞型的函数。

--Lua 中协同的强大能力，还在于通过 resume-yield 来交换数据：
--1> resume 把参数传给程序（相当于函数的参数调用）；
--2> 数据由 yield 传递给 resume;
--3> resume 的参数传递给 yield;
--4> 协同代码结束时的返回值，也会传给 resume
--协同中的参数传递形势很灵活，一定要注意区分，在启动 coroutine 的时候，resume的参数是传给主程序的；在唤醒 yield 的时候，参数是传递给 yield 的。
co = coroutine.create(function(a, b)
    print("co", a, b) --10 20
end)
print(coroutine.resume(co, 10, 20))

co = coroutine.create(function(a, b)
    print("co", a, b) -- co 10 20
    return a + b, a - b
end)
print(coroutine.resume(co, 10, 20)) --true 30	-10

co = coroutine.create(function(a, b)
    print("co", a, b) --co	10	20
    coroutine.yield(a + b, a - b)
end)
print(coroutine.resume(co, 10, 20)) --true 30 -10

--yield 的目的，就是为了让协程停下来，并且传值给 resume 作为返回。
--而 resume 再次开启协程，让 yield 返回，并获取 resume 传入参数，使新的协程再次有了新的状态值。
co = coroutine.create(function(a, b)
    print("berofe co yield ", a, b) --co 10 20
    a, b = coroutine.yield(a + b, a - b)
    print("after co yield", a, b) --co 1 2
end)
print("main coroutine", coroutine.resume(co, 10, 20)) --true 30 -10
print("main coroutine", coroutine.resume(co, 1, 2)) --true

--方法与结论-三段式-二情形

--a, b = coroutine.yield(a + b, a - b)
--三段式来看 yield，红色部分(a + b, a - b)，表示返回的数据，
--蓝色部分coroutine.yield，表示出让协程然后进入等待，
--紫色部分a, b =，表示等待再次唤醒，接收到的数据。

--coroutine.resume(co, 10, 20)  传递到函数 function(a, b)
--coroutine.resume(co, 1, 2)  传递到 coroutine.yield(a + b, a - b)
--二种方式来看 resume，一种传参到函数，一种是传参 yield.

--resume-yield 的相互传参关系
co = coroutine.create(function(a)
    local r = coroutine.yield(a + 1) -- yield()返回 a+1 给调用它的 resume()函数，即 2
    print("r=" .. r) -- r 的值是第 2 次 resume()传进来的，100
end)
print(coroutine.resume(co, 1)) -- resume()返回两个值，一个是自身的状态 true,一个是 yield 的返回值 2
coroutine.resume(co, 100) --resume()返回 true

--协程 co 中调用了 foo 函数，在 foo 函数中 yield 以后，是返回 foo 函数调用处呢，还是该协程 co 被 resume 的地方呢？
function foo (a)
    print("foo", a) --foo	2
    return coroutine.yield(2 * a)
end
co = coroutine.create(function(a, b)
    print("co-body 1", a, b) -- co-body	1	10
    local r = foo(a + 1)
    print("co-body 2", r) --co-body 2	r
    local r, s = coroutine.yield(a + b, a - b)
    print("co-body 3", r, s) --co-body 3	x	y
    return b, "end"
end)
print("main", coroutine.resume(co, 1, 10)) --main	true	4
print("main", coroutine.resume(co, "r")) --main	true	11	-9
print("main", coroutine.resume(co, "x", "y")) --main	true	10	end
print("main", coroutine.resume(co, "x", "y")) --main	false	cannot resume dead coroutine

--resume(co, 1, 10)传递给函数function(a, b)，则a=1,b=10，调用foo函数，参数2，遇到yield，把2*a返回给resume  4
--resume(co, "r")，让coroutine.yield(2 * a)返回，返回值是"r"，所以r = "r"，遇到yield，把a+b,a-b返回给resume  11 -9
--resume(co, "x", "y"),让coroutine.yield(a + b, a - b)返回，r="x", s="y"，return 10, "end"
--resume(co, "x", "y")，co已结束


--解决-双 while 交互问题
function Sleep(n)
    local start = os.clock()
    while os.clock() - start <= n do
    end
end
function f1()
    while true do
        local res, v1, v2 = coroutine.resume(c2, 100, 300)
        Sleep(1)
        print("co c1 f1", v1, v2)
    end
end
c1 = coroutine.create(f1)
function f2()
    while true do
        local v1, v2 = coroutine.yield(1, 3)
        Sleep(3)
        print("co,c2,f2", v1, v2)
    end
end
c2 = coroutine.create(f2)
coroutine.resume(c1)

--管道-生产者与消费者
--消费者，发起消费行为，但是没有数据，resume 一个生产者线程来，等待数据到来。
--此时生产者，开始产生数据，数据生产出来以后，yield 出让线程阻塞，并回传数据，消费者收到数据后，打印。
--消费者，再次 resume 发起消费，逻辑同上。也是双 while 结构。
function productor()
    local i = 0
    while true do
        i = i + 1
        send(i) -- 将生产的物品发送给消费者
    end
end
function consumer()
    while true do
        local i = receive() -- 从生产者那里得到物品
        print(i)
    end
end
function receive()
    local status, value = coroutine.resume(co)
    return value
end
function send(x)
    coroutine.yield(x) -- x 表示需要发送的值，值返回以后，就挂起该协同程序
end
-- 创建协程 获得句柄
co = coroutine.create(productor)
-- 消费驱动
consumer()

--非抢占式线程
--Lua 中的协同是一协作的多线程，每一个协同等同于一个线程，yield-resume 可以实现在线程中切换。然而与真正的多线程不同的是，协同是非抢占式的。

--lua 包 package 的安装
--luarocks
--lua 的第三方库，统一由 luarocks 来管理。官方地址：https://luarocks.org/ 第三方库非常的多也非常的简单易用。