local skynet = require "skynet"
local socket = require "skynet.socket"
local s = require "service"
local run_config = require "run_config"

require "skynet.manager"

--关闭服务器的流程
--会先给gateway（网关）发送关闭服务器的消息，让它阻止新玩家连入；
--再缓慢地让所有玩家下线，下线过程中玩家数据都将得以保存；
--然后保存公会、排行榜等一些全局数据；最后才关闭整个节点。

function shutdown_gate()
    for node, _ in pairs(run_config.cluster) do
        local node_config = run_config[node]
        for k, v in pairs(node_config.gateway or {}) do
            local name = "gateway" .. k
            s.call(node, name, "shutdown")
        end
    end
end

function shutdown_agent()
    local anode = run_config.agent_mgr.node
    while true do
        local online_num = s.call(anode, "agent_mgr", "shutdown", 1)
        if online_num <= 0 then
            break
        end
        skynet.sleep(100)
    end
end

function stop()
    shutdown_gate()
    shutdown_agent()
    --...
    skynet.abort()
    return "ok"
end

function connect(fd, addr)
    socket.start(fd)
    socket.write(fd, "please enter cmd\r\n")
    local cmd = socket.readline(fd, "\r\n")
    if cmd == "stop" then
        stop()
    else

    end
end

s.init = function()
    local cfd = socket.listen("0.0.0.0", 8888)
    socket.start(cfd, connect)
end

s.start(...)