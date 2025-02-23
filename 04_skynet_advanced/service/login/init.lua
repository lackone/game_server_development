local skynet = require "skynet"
local s = require "service"

s.client = {}

s.resp.client = function(source, fd, cmd, msg)
    if s.client[cmd] then
        local ret = s.client[cmd](fd, msg, source)
        skynet.send(source, "lua", "send_by_fd", fd, ret)
    else
        skynet.error("s.resp.client fail", cmd)
    end
end

--登录流程处理
--1）校验用户名密码
--2）给agentmgr发送reqlogin，请求登录。reqlogin会回应两个值，第一个值isok代表是否成功，agent代表已创建的代理服务id。
--3）给gate发送sure_agent
--4）如果全部过程成功执行，login服务会打印“login succ”，并给客户端回应成功信息
s.client.login = function(fd, msg, source)
    skynet.error("login recv " .. msg[1] .. " " .. msg[2])

    local player_id = tonumber(msg[2])
    local pwd = tonumber(msg[3])
    local gate = source
    local node = skynet.getenv("node")

    print(player_id, pwd, gate, node)

    --校验用户名密码
    if pwd ~= 123 then
        return { "login", 1, "密码错误" }
    end

    --给agent_mgr发消息
    local is_ok, agent = skynet.call("agent_mgr", "lua", "req_login", player_id, node, gate)
    if not is_ok then
        return { "login", 1, "请求mgr失败" }
    end

    --回应gate
    local is_ok = skynet.call(gate, "lua", "sure_agent", fd, player_id, agent)
    if not is_ok then
        return { "login", 1, "gate注册失败" }
    end

    skynet.error("login success " .. player_id)

    return { "login", 0, "登录成功" }
end

s.start(...)