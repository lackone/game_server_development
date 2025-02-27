local skynet = require "skynet"

local coin = 0

--策划人员觉得每次增加1个金币太少了，希望在不停服务的情况下改成2个金币。

--清除代码缓存
--要先登录调试控制台（debug_console）执行清除缓存的指令（clearcache）

--1）修改代码，将代码9-2中的“coin=coin+1”改成“coin=coin+2”。
--2）登录调试控制台，执行clearcache指令。
--热更新之后，旧客户端依然只增加1金币，但新连接的客户端会增加2金币

--注入补丁热更方案
--写完补丁文件，在调试控制台输入inject a examples/hinject.lua即可完成热更新。其中，“a”是代理服务的id

function onMsg(data)
    skynet.error("agent recv " .. data)
    --消息处理
    if data == "work\r\n" then
        --coin = coin + 1
        coin = coin + 2
        return coin .. "\r\n"
    end
    return "err cmd\r\n"
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        if cmd == "onMsg" then
            local ret = onMsg(...)
            skynet.retpack(ret)
        end
    end)
end)