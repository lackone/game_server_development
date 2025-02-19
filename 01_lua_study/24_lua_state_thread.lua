--Lua 的状态与线程
--Lua 不支持真正的多线程，而是一种协作式的多线程，彼此之间协作完成，并不是抢占完成任务，由于这种协作式的线程，因此可以避免由不可预知的线程切换所带来的问题；
--另一方面，Lua 的多个状态之间不共享内存，这样便为 Lua 中的并发操作提供了良好的基础。

--lua_State *lua_newthread (lua_State *L)
--只要创建一个 Lua 状态，Lua 就会自动在这个状态中创建一个新线程，这个线程称为"主线程"。主线程永远不会被回收。
--当调用 lua_close 关闭状态时，它会随着状态一起释放。 调用 lua_newthread 便可以在一个状态中创建其他的线程。


--线程交互 lua_xmove
--一旦有一个新线程，其使用方法同主线程。可以将元素压入栈中，可以从栈中弹出元素，还可以用其调用函数。
--void lua_xmove (lua_State *from, lua_State *to, int n)
--如上函数表示从栈 from 中弹出 n 个元素，压入 to 的栈中。

--lua 交出控制权
--int lua_resume (lua_State *L, lua_State *from, int nargs)
--该函数的用法，也是先将函数入栈，然后压入协程的参数，添入参数的数量 narg，L代表协程函数所在的虚拟机，而 from 则代表主线程，其栈中有 L。

function bbb(x)
    coroutine.yield(10, x)
end

function aaa(x)
    bbb(x + 1)
    return 3
end

--lproc
--每个线程 state 是完全独立的，不共享数据，也就是说，一个 lua 状态发生了什么，不会影响到其它的 lua 状态。
--luastate 之间，要进行通信，有且只有一条路径就是 c 语言接口。比如，如下的代码，就完成了两个 state，L1 和 L2 之间的通信。
--lua_pushstring(L2,lua_tostring(L1,-1));
--所有的数据，必须经由 c 语言来传递，因此 lua 状态之间只能够使用 C 语言表示的类型，比如数值和字符串，其它类型诸如表，则必须经由序列化以后才可能传递。