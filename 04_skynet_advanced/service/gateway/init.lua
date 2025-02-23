local skynet = require "skynet"
local socket = require "skynet.socket"
local s = require "service"
local run_config = require "run_config"

--gateway需要使用两个列表，一个用于保存客户端连接信息，另一个用于记录已登录的玩家信息。
conns = {} -- [fd] = conn
players = {} -- [player_id] = gate_player

local closing = false

--连接类
function conn()
    local m = {
        fd = nil,
        player_id = nil,
    }
    return m
end

--gateway可以做到双向查找
--若客户端发送了消息，可由底层Socket获取连接标识fd。gateway则由fd索引到conn对象，再由playerid属性找到player对象，进而知道它的代理服务（agent）在哪里，并将消息转发给agent。
--若agent发来消息，只要附带着玩家id，gateway即可由playerid索引到gateplayer对象，进而通过conn属性找到对应的连接及其fd，向对应客户端发送消息。

--玩家类
function gate_player()
    local m = {
        player_id = nil, --玩家id
        agent = nil, --对应的代理服务
        conn = nil, -- 对应的conn对象
        key = math.random(1, 99999999), --gateway会为每个玩家生成身份标识码
        lost_conn_time = nil, --记录最后一次断开连接的时间
        msg_cache = {}, --未发送的消息缓存
    }
    return m
end

--编码和解码
local str_unpack = function(str)
    local msg = {}
    while true do
        local arg, ret = string.match(str, "(.-),(.*)")
        if arg then
            str = ret
            table.insert(msg, arg)
        else
            table.insert(msg, str)
            break
        end
    end
    return msg[1], msg
end

--编码和解码
local str_pack = function(cmd, msg)
    return table.concat(msg, ",") .. "\r\n"
end

--断线重连
--1）做出严格的条件判断，只有断线的玩家才能接受重连。未登录（if not gplayer为真）、未掉线（if gplayer.conn为真）、身份标识错误（if gplayer.key~=key为真）均不可重连。
--2）绑定新连接（conn）和玩家对象（gplayer）。
--3）回应重连消息{"reconnect",0}。
--4）发送缓存中的消息。
local process_reconnect = function(fd, msg)
    local player_id = tonumber(msg[2])
    local key = tonumber(msg[3])
    local conn = conns[fd]
    if not conn then
        skynet.error("reconnect fail, conn not exist")
        return
    end
    local player = players[player_id]
    if not player then
        skynet.error("reconnect fail, player not exist")
        return
    end
    if player.conn then
        skynet.error("reconnect fail, conn not break")
        return
    end
    if player.key ~= key then
        skynet.error("reconnect fail, key error")
        return
    end
    --绑定
    player.conn = conn
    conn.player_id = player_id
    --回应
    s.resp.send_by_fd(nil, fd, { "reconnect", 0 })
    --发送缓存消息
    for i, cmsg in ipairs(player.msg_cache) do
        s.resp.send_by_fd(nil, fd, cmsg)
    end
    player.msg_cache = {}
end

--消息分发
local process_msg = function(fd, msg_str)
    local cmd, msg = str_unpack(msg_str)
    skynet.error("recv " .. fd .. " [" .. cmd .. "] {" .. table.concat(msg, ",") .. "}")
    local conn = conns[fd]
    local player_id = conn.player_id
    --特殊断线重连
    if cmd == "reconnect" then
        process_reconnect(fd, msg)
        return
    end
    if not player_id then
        --尚未完成登录流程
        local node = skynet.getenv("node")
        local node_config = run_config[node]
        --随机选取一个登录服务器，并将消息转发给它处理
        local login_id = math.random(1, #node_config.login)
        local login = "login" .. login_id
        skynet.send(login, "lua", "client", fd, cmd, msg)
    else
        --完成登录流程
        local player = players[player_id]
        local agent = player.agent
        skynet.send(agent, "lua", "client", cmd, msg)
    end
end

--解析缓冲数据
local process_buff = function(fd, read_buf)
    while true do
        --分别代表取出的第一条消息和剩余的部分
        local msg, ret = string.match(read_buf, "(.-)\r\n(.*)")
        if msg then
            read_buf = ret
            process_msg(fd, msg)
        else
            return read_buf
        end
    end
end

local disconnect = function(fd)
    local conn = conns[fd]
    if not conn then
        return
    end
    --还没完成登录
    local player_id = conn.player_id
    if not player_id then
        return
    else
        --已在游戏中
        local player = players[player_id]
        player.conn = nil --掉线时仅仅取消玩家对象（player）与旧连接（conn）的关联

        --若5分钟后依然是掉线状态（if player.conn~=nil为假），则向agent_mgr请求下线。
        skynet.timeout(300 * 100, function()
            if player.conn ~= nil then
                return
            end
            local reason = "断线超时"
            skynet.call("agent_mgr", "lua", "req_kick", player_id, reason)
        end)
    end
end

--每一条连接接收数据处理
--协议格式 cmd,arg1,arg2,...#
local recv_loop = function(fd)
    --socket.start开启连接
    socket.start(fd)
    skynet.error("socket connected " .. fd)
    --定义字符串缓冲区
    local read_buf = ""
    while true do
        local recv_str = socket.read(fd)
        if recv_str then
            read_buf = read_buf .. recv_str
            read_buf = process_buff(fd, read_buf)
        else
            skynet.error("socket close " .. fd)
            disconnect(fd)
            socket.close(fd)
            return
        end
    end
end

--有新连接时
local connect = function(fd, addr)
    --如果服务端处于“关闭中”状态，不处理它。
    if closing then
        return
    end
    print("connect from " .. addr .. " " .. fd)
    local c = conn()
    conns[fd] = c
    c.fd = fd
    --recv_loop负责接收客户端消息
    --当客户端连接时，程序通过skynet.fork发起协程，协程recv_loop是个循环
    skynet.fork(recv_loop, fd)
end

function s.init()
    skynet.error("[start]" .. s.name .. " " .. s.id)
    local node = skynet.getenv("node") --node1
    local node_config = run_config[node]
    local port = node_config.gateway[tonumber(s.id)].port
    local listen_fd = socket.listen("0.0.0.0", port)
    skynet.error("listen socket:", "0.0.0.0", port)
    socket.start(listen_fd, connect)
end

--send_by_fd方法用于login服务的消息转发，功能是将消息发送到指定fd的客户端。
s.resp.send_by_fd = function(source, fd, msg)
    if not conns[fd] then
        return
    end
    local buf = str_pack(msg[1], msg)
    skynet.error("send " .. fd .. " [" .. msg[1] .. "] {" .. table.concat(msg, ",") .. "}")
    socket.write(fd, buf)
end

--send方法用于agent的消息转发，功能是将消息发送给指定玩家id的客户端。
s.resp.send = function(source, player_id, msg)
    local player = players[player_id]
    if player == nil then
        return
    end
    local conn = player.conn
    if conn == nil then
        --保存消息
        table.insert(player.msg_cache, msg)
        local msg_len = #player.msg_cache
        if msg_len > 500 then
            skynet.call("agent_mgr", "lua", "req_kick", player_id, "gate消息缓存过多")
        end
        return
    end
    s.resp.send_by_fd(nil, conn.fd, msg)
end

--确认登录接口
--在完成了登录流程后，login会通知gateway，让它把客户端连接和新agent关联起来。
s.resp.sure_agent = function(source, fd, player_id, agent)
    --将fd和player_id关联起来，它会先查找连接对象conn，再创建gate_player对象player，并设置属性。
    local conn = conns[fd]
    if not conn then
        skynet.call("agent_mgr", "lua", "req_kick", player_id, "未完成登录即下线")
        return false
    end
    conn.player_id = player_id

    local player = gate_player()
    player.player_id = player_id
    player.agent = agent
    player.conn = conn
    players[player_id] = player

    return true
end

--如果agentmgr仲裁通过，或是agentmgr想直接把玩家踢下线，在保存数据后，它会通知gateway做反向操作，来删掉玩家对应的conn和gateplayer对象。
s.resp.kick = function(source, player_id)
    local player = players[player_id]
    if not player then
        return
    end
    local conn = player.conn
    players[player_id] = nil
    if not conn then
        return
    end
    conns[conn.fd] = nil
    disconnect(conn.fd)
    socket.close(conn.fd)
end

--不再接收新连接
s.resp.shutdown = function()
    closing = true
end


--在用skynet.newservice启动服务时，可以传递参数给它。
s.start(...)