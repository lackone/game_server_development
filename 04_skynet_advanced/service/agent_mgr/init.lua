local skynet = require "skynet"
local s = require "service"

STATUS = {
    LOGIN = 2, --登录中
    GAME = 3, --游戏中
    LOGOUT = 4, --登出中
}

--玩家列表
local players = {}

function mgr_player()
    local m = {
        player_id = nil, --玩家id
        node = nil, --该玩家对应gateway和agent所在的节点
        agent = nil, --该玩家对应agent服务的id
        status = nil, --状态，例如“登录中”
        gate = nil, --该玩家对应gateway的id
    }
    return m
end

--1）登录仲裁：判断玩家是否可以登录（仅STATUS.GAME状态）。
--2）顶替已在线玩家：如果该角色已在线，需要先把它踢下线。
--3）记录在线信息：将新建的mgrplayer对象记录为 STATUS.LOGIN（登录中）状态。
--4）让nodemgr创建agent服务，待创建完成 且agent加载了角色数据后，才往下执行。
--5）登录完成，设置mgrplayer为STATUS.GAME状态（游戏中），并 返回true及agent服务的id。
s.resp.req_login = function(source, player_id, node, gate)
    skynet.error("req_login recv " .. player_id .. " " .. node .. " " .. gate)

    local player = players[player_id]
    if player and player.status == STATUS.LOGOUT then
        skynet.error("req_login fail at status LOGOUT " .. player_id)
        return false
    end
    --登录过程禁止顶替
    if player and player.status == STATUS.LOGIN then
        skynet.error("req_login fail at status LOGIN " .. player_id)
        return false
    end
    --在线，顶替
    if player then
        local node = player.node
        local agent = player.agent
        player.status = STATUS.LOGOUT --登出
        s.call(node, agent, "kick")
        s.send(node, agent, "exit")
        s.send(node, gate, "send", player_id, { "kick", "顶替下线" })
        s.call(node, gate, "kick", player_id)
    end
    --上线
    local new_player = mgr_player()
    new_player.player_id = player_id
    new_player.node = node
    new_player.gate = gate
    new_player.agent = nil
    new_player.status = STATUS.LOGIN
    players[player_id] = new_player
    local agent = s.call(node, "node_mgr", "new_service", "agent", "agent", player_id)
    new_player.agent = agent
    new_player.status = STATUS.GAME
    return true, agent
end

--请求登出接口
s.resp.req_kick = function(source, player_id, reason)
    local player = players[player_id]
    if not player then
        return false
    end
    --判断状态是否游戏中
    if player.status ~= STATUS.GAME then
        return false
    end

    local node = player.node
    local agent = player.agent
    local gate = player.gate
    player.status = STATUS.LOGOUT

    s.call(node, agent, "kick")
    s.send(node, agent, "exit")
    s.send(node, gate, "kick", player_id)
    players[player_id] = nil

    return true
end

--获取在线人数
function get_online_count()
    local count = 0
    for player_id, player in pairs(players) do
        count = count + 1
    end
    return count
end

--将num数量的玩家踢下线
s.resp.shutdown = function(source, num)
    --当前玩家数
    local count = get_online_count()
    --踢下线
    local n = 0
    for player_id, player in pairs(players) do
        skynet.fork(s.resp.req_kick, nil, player_id, "close server")
        n = n + 1 --计数，总共发num条下线消息
        if n >= num then
            break
        end
    end
    --等待玩家数下线
    while true do
        skynet.sleep(200)
        local new_count = get_online_count()
        skynet.error("shutdown online:" .. new_count)
        if new_count <= 0 or new_count <= count - num then
            return new_count
        end
    end
end

s.start(...)