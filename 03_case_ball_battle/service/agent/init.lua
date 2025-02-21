local skynet = require "skynet"
local s = require "service"

s.client = {}
s.gate = nil

s.init = function()
    --加载角色数据
    skynet.sleep(200)
    s.data = {
        coin = 999,
        hp = 999,
    }
end

s.resp.kick = function(source)
    --保存角色数据
    skynet.sleep(200)
end

s.resp.exit = function(source)
    skynet.exit()
end

s.client.work = function(msg)
    s.data.coin = s.data.coin + 1
    return { "work", s.data.coin }
end

s.resp.client = function(source, cmd, msg)
    s.gate = source
    if s.client[cmd] then
        local ret = s.client[cmd](msg, source)
        if ret then
            --这里的s.id就是player_id
            --s.call(node,"node_mgr","new_service","agent","agent",playerid)最后两个参数会被传递到node_mgr中，再传递到agent服s.start(...)的可变参数中。
            --所以对于agent服务，s.name为“agent”，s.id为玩家id。
            skynet.send(source, "lua", "send", s.id, ret)
        end
    else
        skynet.error("s.resp.client fail", cmd)
    end
end

s.start(...)