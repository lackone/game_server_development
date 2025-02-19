--lua-cjson
--luarocks install lua-cjson

print(package.cpath)

local cjson = require "cjson"
t = {}
t.name = "test"
t.age = 33
t.org = "www.ooo.com"
t.hobby = { "football", "basketball" }
local jsonstr = cjson.encode(t)
print(jsonstr)

local cjson = require "cjson"
local jsonstr = [[
{
    "age":"66",
    "Array":{"array":[8,9,11,14,25]},
    "org":"www.aaa.cn"
}
]];
local tjson = cjson.decode(jsonstr)
print(tjson.age)
print(tjson.Array.array[1])
print(tjson.org)