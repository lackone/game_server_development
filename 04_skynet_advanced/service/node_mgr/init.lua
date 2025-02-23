local skynet = require "skynet"
local s = require "service"

--nodemgr即节点管理服务，每个节点会开启一个。目前它只有一个功能，即提供创建服务的远程调用接口。
s.resp.new_service = function(source, name, ...)
    skynet.error("newservice " .. name)
    local agent = skynet.newservice(name, ...)
    return agent
end

s.start(...)