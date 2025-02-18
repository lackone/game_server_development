--标准库 Stdlib

--数学库
--math.ceil(x) 返回大于或等于 x 的最小整数.
--math.floor(x) 返回小于或等于 x 的最大整数.
--math.random([m, [n]])
--该函数直接调用 ANSI C 的伪随机生成函数.
--1>无参数时，生成 [0，1) 区间的均匀分布的随机值；
--2>只传入参数 m 时，函数生成一个位于区间 [1，m]的均匀分布伪随机值；
--3>同时传入参数 m，n 时，生成位于区间 [m，n] 的均匀分布伪随机值.
--math.randomseed(x) 初始化伪随机数生成器种子值.

print(math.floor(10.5055))
print(math.ceil(10.5055))
math.randomseed(os.time())
print(math.random(1, 100))
print(math.pow(10, 2))
print(math.sqrt(16))
print(math.max(3, 4, 2, 1, 99))
print(math.min(3, 4, 2, 1, 99))

--string 库


--os库
--os.clock() 以秒为单位返回程序运行所用 CPU 时间的近似 值.
--os.date([format[, time]]) 返回时间字符串或包含时间的表，时间按指定格式格式化.
--os.difftime(t2, t1) 返回从 t1 时刻至 t2 时刻经历的时间.在POSIX，windows，及其它某些系统中，该值就是t2-t1.
--os.execute([command]) 该函数等价于 ANSI C 中的 system 函数.传递的参数 command 由操作系统的 shell 执行.如果命令成功结束，则返回的第一个值为 true，否则为 nil.
--os.exit([code[, close]]) 调用 ANSI C 的 exit 函数，结束程序.如果code 为true，则返回状态为 EXIT_SUCESS；若 code 为 false，则返回状态为EXIT_FAILURE.如果 code 为数值，则返回状态也就为该数值.
--os.getenv(varname) 返回进程的环境变量 varname 的值，如果此环境变量没有定义则返回 nil.
--os.remove(filename) 删除文件(或 POSIX 系统中的空目录).如果函数失败，则返回 nil 以及描述错误的字符串与错误代码.
--os.rename(oldname, newname) 重命名文件或目录.如果函数失败，则返回 nil 以及描述错误的字符串与错误代码.
--os.setlocale(locale[, category]) 设置程序当前的地区(locale)，locale 是一个与操作系统相关的字符串.category 是一个可选的字符串，描述设置更改的范围，包括: all，collate，ctype，monetary，numeric，time.默认为 all.函数返回新地区的名称，如果函数调用失败则返回 nil.
--os.time([table]) 无参数时，返回当前时间；传入参数时，则返回指定参数表示的日期和时间.传入的参数必须包含以下的域:年、月、日.时(默认 12)、分(默认 0)、秒(默认 0)、isdst(默认 nil) 四个域是可选的.
--os.tmpname() 返回一个可作为临时文件名的字符串.这个临时文 件必须显式地打开，使用结束时也必须显式地删 除.
print(os.date("%Y-%m-%d"))
print(os.date())
print(os.time())
print(os.clock())
print(os.getenv("PATH"))

function createDir (dirname)
    os.execute("mkdir " .. dirname)
end
createDir("test")

--io库
--Lua I/O 库用于读取和处理文件。分为简单模式(和 C 一样)、完全模式。
--简单模式(simple model)拥有一个当前输入文件和一个当前输出文件，并且提供针对这些文件相关的操作。
--完全模式(complete model) 使用外部的文件句柄来实现。它以一种面对对象的形式，将所有的文件操作定义为文件句柄的方法

--简单模式
--io.lines([filename])
--io.input ([file])
--io.output ([file])
--io.read (...)
--io.write (...)
--io.write，io.read 是一对。默认情况下，他们从 stdin 读输入，输出到 stdout。

io.write(io.read(), "\n") --默认输入是键盘，输出是屏幕

io.write("<", "super lua", ">\n")

io.input("a.txt")
io.output("b.txt")
for cnt = 1, math.huge do
    line = io.read("l") --读取一行
    if line == nil then
        break
    end
    io.write(string.format("%2d", cnt), line, "\n")
end

--io.lines() 迭代器版本
local cnt = 0
for line in io.lines() do
    cnt = cnt + 1
    io.write(string.format("%2d", cnt), line, "\n")
end

--读取替换回写
--io.input(io.stdin)
--input = io.read("a")
--input = string.gsub(input, "bad", "good")
--io.write(input)

--排序一个文件
local lines = {}
for line in io.lines() do
    lines[#lines + 1] = line
end
table.sort(lines)
for _, l in ipairs(lines) do
    io.write(l, "\n")
end

--io.write 与 print 的不同
--print 输出的数据，只能到 stdout，而 io.write 而可以指定文件，print 输出的数据，间隔是 tab，
--而 io.write 输出的数据，无间隔，print 是以'\n'作为结束符的，而 io.write 是没有结束符的。
print("a", "b", "c");
print("a", "b", "c");
io.output(io.stdout);
io.write("a", "\t", "b", "\t", "c", "\n");

--完全模式

--file = io.open (filename [, mode])
--"r" 只读模式，这也是对已存在的文件的默认打开模式。
--"w" 可写模式，允许修改已经存在的文件和创建新文件。
--"a" 追加模式，对于已存的文件允许追加新内容，但不允许修改原有内容，同时 也可以创建新文件。
--"r+" 读写模式打开已存的在文件。
--"w+" 如果文件已存在则删除文件中数据；若文件不存在则新建文件。读写模式打 开。
--"a+" 以可读的追加模式打开已存在文件，若文件不存在则新建文件。

--debug 库

--debug() 进入交互式调试模式，在此模式下用户可以用 其它函数查看变量的值。
--getfenv(object) 返回对象的环境
--gethook(optional thread)  返回线程当前的钩子设置，总共三个值：当前钩子函数、当前的钩子掩码与当前的钩子计数。
--getinfo(optional thread,function or stack leve,optional flag)  返回保存函数信息的一个表。
--getlocal(optional thread, stack level, local index) 此函数返回在 level 层次的函数中指定索引位置处的局部变量和对应的值。
--getmetatable(value) 返回指定对象的元表，如果不存在则返回 nil。
--getregistry()  返回寄存器表。寄存器表是一个预定义的用于 C 代码存储 Lua 值的表。
--getupvalue(func function, upvalue index)  根据指定索引返回函数 func 的 upvalue 值
--setfenv( function or thread or userdata, environment table)  将指定的对象的环境设置为 table，即改变对象的作用域。
--sethook(optional thread, hook function, hook mask string with "c" and/or "r" and/or "l", optional instruction count) 把指定函数设置为钩子。字符串掩码和计数值表示钩子被调用的时机。
--setlocal(optional thread, stack level,local index, value)  在指定的栈深度的函数中，为 index 指定的局部变量赋予值。
--setmetatable(value, metatable)  为指定的对象设置元表，元表可以为 nil。
--setupvalue(function, upvalue index, value)  为指定函数中索引指定的 upvalue 变量赋值。
--traceback(optional thread, optional meesage string, opitona level argument)  用 traceback 构建扩展错误消息