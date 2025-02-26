--收到客户端移动指令
function on_shift_msg(player, msg)
    player.speedx = msg.x --msg.x和msg.y代表摇杆坐标（移动方向）
    player.speedy = msg.y
end

--每隔0.2秒调用一次
function move_update()
    for i, v in pairs(players) do
        v.x = v.x + v.speedx * 0.2
        v.y = v.y + v.speedy * 0.2
        if v.speedx ~= 0 or v.speedy ~= 0 then
            local msg = { "move", v.playerid, v.x, v.y }
            broadcast(msg)
        end
    end
end

--插值算法
--客户端收到移动协议后，不会直接设置角色坐标，而是让角色慢慢往目标点移动。

--缓存队列
--收到移动协议后，不立即进行处理，而是把协议数据存在队列中，再用固定的频率（比如，每隔0.2秒）取出，结合插值算法移动角色。
--“缓存队列”相当于是在客户端加一层缓存来缓解网络抖动的问题，这样做能够有效提高玩家的游戏体验。

--主动方优先
--“A击中B”的三种同步方式

--第1种：不管客户端的误差，一切以服务端的计算为准。

--第2种：信任主动方。客户端A发送“我击中了B”的协议，只要不是偏差太大（例如，角色A和B隔得太远），服务端就认定A真的击中了B。这种方式会提高玩家A的游戏体验，但玩家B可能会感到“莫名其妙被打死”。

--第3种：信任被动方。客户端B发送“我被A击中”的协议。这种方式会提高玩家B的游戏体验，但玩家A可能会感到“明明瞄准了却打不中”。

--各类同步方案及适用场景

--指令->状态   客户端发来的摇杆方向（即角色移动方向），输出是球的位置坐标，这种情况属于“指令-状态”同步
--状态->状态   客户端直接发送角色的位置坐标，服务端只进行转发
--指令->指令   客户端发送“向前走”之类的指令，服务端只做转发

--不同的同步方案适用于不同的游戏
--射击FPS      状态-状态
--即时战略RTS  指令-指令
--竞技MOBA    指令-指令
--角色扮演     指令-状态
--开房间休闲类  指令-状态 或 指令-指令

--
--客户端可以收集玩家一段时间内（如0.1秒）的所有操作，再一次性发给服务端
local msg = {
    _cmd = "client_sync", --协议名
    turn = 3, --轮（回合数）
    ops = { --操作指令
        [1] = { "move", 0, 1 }, --向(0,1)方向移动
        [2] = { "skill", 1001 } --释放1001号技能
    }
}

--服务端收集所有客户端的操作之后，将广播“各玩家在第N轮的操作指令”的协议
local msg = {
    _cmd = "server_sync", --协议名
    turn = 4, --轮（回合数）
    --各玩家的操作指令
    players = {
        [1] = { --玩家101的指令
            playerid = 101,
            ops = {
                [1] = { "move", 0, 1 },
                [2] = { "skill", 1001 }
            }
        },
        [2] = { --玩家103的指令
            playerid = 103,
            ops = {
                [1] = { "move", 1, 1 }
            }
        }
    }
}

local myturn = 0 --轮
local ops = {} --客户端的所有操作
local players = {} --玩家（角色）列表

--处理客户端协议
function msg_client_sync(playerid, msg)
    --丢弃错误帧
    if myturn ~= msg.turn then
        return
    end
    --
    local next = myturn + 1 --下一帧
    ops[next] = ops[next] or {}
    --已经存入，不再变更
    if ops[next][playerid] then
        return
    end
    --插入
    ops[next][playerid] = msg.ops
end

--每隔0.1秒调用一次on_turn
function on_turn()
    local next_turn = myturn + 1 --下一轮
    local next_op = ops[next] --取指令
    local count = #next_op --计算收集到的指令数
    if count >= player_count then
        --player_count代表战场玩家总数
        myturn = next --进入下一轮
        smsg = tomsg(next_op) --生成消息，具体实现略
        broadcast(smsg) --广播消息，具体实现略
    end
end

--每隔0.1秒调用一次
function on_fixed_trun()
    myturn = myturn + 1
    next_op = next_op[myturn]
    smsg = tomsg(frame)
    broadcast(smsg)
end

--收到客户端协议时
function msg_client_sync(playerid, msg)
    local next = myturn + 1
    --太旧的不要
    if msg.turn < myturn - 5 then
        return
    end
    --防止同一玩家同一轮的操作被覆盖
    --用recv记录已收到哪个玩家哪一轮的协议
    recv[msg.turn] = recv[msg.turn] or {}
    if recv[msg.turn][playerid] then
        return
    end
    recv[msg.turn][playerid] = true
    --插入
    ops = frames[next][playerid]
    ops = append(ops, msg.ops) --把msg.ops插入ops中，具体实现略
end

function moveto(x, y)
    local ceils = space.ceils
    --新坐标所在的格子
    local new_cx, new_cy = get_ceil_idx(x, y)
    --旧坐标所在的格子
    local old_cx, old_cy = get_ceil_idx(self.x, self.y)
    --保证连续地移动
    if math.abs(new_cx - old_cx) > 1 or math.abs(new_cy - old_cy)
    then
        return
    end
    --移动
    self.x = x
    self.y = y
    --9种情况
    -- 情况1：还在原来的格子
    if new_cx == old_cx and new_cy == old_cy then
        --无须处理
    end
    -- 情况2：向右走
    if new_cx == old_cx + 1 and new_cy == old_cy then
        on_leave(self.id, ceils[old_cx - 1][old_cy - 1])
        on_leave(self.id, ceils[old_cx - 1][old_cy])
        on_leave(self.id, ceils[old_cx - 1][old_cy + 1])
        remove(self.id, ceils[old_cx][old_cy])
        on_enter(self.id, ceils[old_cx + 2][old_cy - 1])
        on_enter(self.id, ceils[old_cx + 2][old_cy])
        on_enter(self.id, ceils[old_cx + 2][old_cy + 1])
        add(self.id, ceils[new_cx][new_cy])
    end
    --……更多情况略
    --向周围9个格子广播移动协议
    broadcast_move(self.id, ceils[new_cx][new_cy])
    broadcast_move(self.id, ceils[new_cx + 1][new_cy])
    --……
end


--可靠UDP
--KCP
--QUIC
--Enet
--RakNet
--UDT