print(package.cpath)

-- 获取当前脚本的完整路径
local info = debug.getinfo(1, "S")
local script_path = info.source
-- 去掉前缀 '@'（如果存在）
if script_path:sub(1, 1) == "@" then
    script_path = script_path:sub(2)
end
-- 提取目录部分
local script_dir = script_path:match("(.*[/\\])")
print(script_dir)

package.cpath = package.cpath .. ';' .. script_dir
print(package.cpath)


local abc = require "abc"
print(abc.myadd(1, 2, 3, 4, 5, 6))