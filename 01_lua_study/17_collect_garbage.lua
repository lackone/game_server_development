--垃极回收 CollectGarbage

--Lua 运行了一个垃圾收集器来收集所有死对象 （即在 Lua 中不可能再访问到的对象）来完成自动内存管理的工作。 Lua 中所有用到的内存，如：字符串、表、用户数据、函数、线程、 内部结构等，都服从自动管理。

--Lua 实现了一个增量标记-扫描收集器。 它使用这两个数字来控制垃圾收集循环： 垃圾收集器间歇率和垃圾收集器步进倍率。 这两个数字都使用百分数为单位 （例如：值 100在内部表示 1 ）。

--接口介绍
--Lua 提供了以下函数 collectgarbage ([opt [, arg]])用来控制自动内存管理:

--("collect"):
--做一次完整的垃圾收集循环。通过参数 opt 它提供了一组不同的功;

--("count"):
--以 K 字节数为单位返回 Lua 使用的总内存数。 这个值有小数部分，所以只需要乘上 1024 就能得到 Lua 使用的准确字节数（除非溢出）。

--("restart"):
--重启垃圾收集器的自动运行。

--("setpause"):
--将 arg 设为收集器的 间歇率 。 返回 间歇率 的前一个值。

--("setstepmul"):
--返回 步进倍率 的前一个值。

--("step"):
--单步运行垃圾收集器。 步长"大小"由 arg 控制。 传入 0 时，收集器步进（不可分割 的）一步。 传入非 0 值， 收集器收集相当于 Lua 分配这些多（K 字节）内存的工作。 如 果收集器结束一个循环将返回 true 。

--("stop"):
--停止垃圾收集器的运行。 在调用重启前，收集器只会因显式的调用运行。

mytable = { "apple", "orange", "banana" }
print(collectgarbage("count") * 1024)
mytable = nil
print(collectgarbage("count") * 1024)
print(collectgarbage("collect"))
print(collectgarbage("count") * 1024)