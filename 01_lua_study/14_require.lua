--模块化 Require

require "14_mymath"
print(mymath.add(3, 3))

my = require("14_mymath")
print(my.mul(3, 10))

--定义的包，如果是全局的，require 以后为全局的，即可直接使用本包，也可以在 require返回后，赋值给全局或本地变量。

--require 覆盖
mymath = { x = 10, y = 20 }
local ret = require("14_mymath")
print(ret.sub(3, 10))
print(mymath.x)

--加载次数
--多次打印，返回的表地址是一样的， 说明只加载一次。
print(require("14_mymath"))
print(require("14_mymath"))

--假设有模块叫，xxx.lua，实际上 require "xxx"后，会将 xxx 中的全局函数和数据放到表_G 中，所以也就能访问了。
--多次执行 require "xxx"，xxx.lua 只会被加载一次，可以多次打印其返值得到相同的table 地址。

--加载流程
--package.loaded
--加载一个模块。这个函数首先查找 package.loaded 表，检测 modname 是否被加载过。如果被加载过，require 返回 package.loaded[modname] 中保存的值。
for k, v in pairs(package.loaded) do
    print(k, v)
end

--package.preload
--然后 require 查找 package.preload[modname] ，预加载的库。
print("---------------------------------")
for k, v in pairs(package.preload) do
    print(k, v)
end

--package.path
--然后搜索 package.path，加载 lua 文件
print(package.path)

--package.cpath
--然后搜索package.cpath，加载 c 库。
print(package.cpath)

--require 搜索路径
--" . " 在 require 时会被替换为文件系统的分隔符，比如/，所以脚本所在的文件夹命名不能包含"."。
--require "xx.yy" --替换成 xx/yy

--自定义路径
package.path = package.path .. ";" .. "/xx/yy/?.lua"

--mymath2.lua 中有啥返回啥，没有啥，返回 true
local ret = require("14_mymath2")
print(ret) --true ，如果没有return,返回true


function require2(name)
    if not package.loaded[name] then
        local loader = findloader(name)
        if loader == nil then
            error("unable to load module" .. name)
        end
        package.loaded[name] = true
        local res = loader(name)
        if res ~= nil then
            package.loaded[name] = res
        end
    end
    return package.loaded[name]
end
print(require2("14_mymath"))