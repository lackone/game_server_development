local skynet = require "skynet"
local s = require "service"

--进入战场协议 enter,玩家ID,坐标,尺寸
--战场信息协议 balllist,玩家ID,坐标,尺寸    foodlist,食物ID,坐标
--生成食物协议 addfood,食物ID,坐标
--移动协议    shift,x,y    move,玩家ID,坐标
--吃食物协议  eat,玩家ID,食物ID,新尺寸
--离开协议    leave,玩家ID

--小球
local balls = {}
--食物
local foods = {}
local food_max_id = 0 --其初始值为0，每创建一个食物，给food_maxid加1
local food_count = 0 --记录战场中食物数量，以限制食物总量

--balls表会以玩家id为索引，保存战场中各个小球的信息。小球与玩家关联，它会记录玩家id（playerid）、代理服务（agent）的id、代理服务所在的节点（node）；
--每个球都包含x坐标、y坐标和尺寸这三种属性（x, y, size），以及移动速度speedx和speedy。玩家进入战场会新建ball对象，并为其赋予随机的坐标。
function ball()
    local m = {
        player_id = nil, --玩家id
        node = nil, --节点
        agent = nil, --代理
        x = math.random(0, 100), --x
        y = math.random(0, 100), --y
        size = 2, --大小
        speed_x = 0, --移动速度
        speed_y = 0,
    }
    return m
end

function food()
    local m = {
        id = nil,
        x = math.random(0, 100),
        y = math.random(0, 100),
    }
    return m
end

--收集战场中的所有小球，并构建balllist协议
local function balllist_msg()
    local msg = { "balllist" }
    for k, v in pairs(balls) do
        table.insert(msg, v.player_id)
        table.insert(msg, v.x)
        table.insert(msg, v.y)
        table.insert(msg, v.size)
    end
    return msg
end

--收集战场中的所有食物，并构建foodlist协议
local function foodlist_msg()
    local msg = { "foodlist" }
    for k, v in pairs(foods) do
        table.insert(msg, v.id)
        table.insert(msg, v.x)
        table.insert(msg, v.y)
    end
    return msg
end

--广播
function broadcast(msg)
    for k, v in pairs(balls) do
        s.send(v.node, v.agent, "send", msg)
    end
end

--进入
s.resp.enter = function(source, player_id, node, agent)
    if balls[player_id] then
        return false
    end
    local b = ball()
    b.player_id = player_id
    b.node = node
    b.agent = agent
    --广播
    local enter_msg = { "enter", player_id, b.x, b.y, b.size }
    broadcast(enter_msg)
    --记录
    balls[player_id] = b
    for k, v in pairs(balls) do
        print(k, v)
    end
    --回应
    local ret = { "enter", 0, "进入成功" }
    s.send(b.node, b.agent, "send", ret)
    --发送战场信息
    s.send(b.node, b.agent, "send", balllist_msg())
    s.send(b.node, b.agent, "send", foodlist_msg())
    return true
end

--退出
s.resp.leave = function(source, player_id)
    if not balls[player_id] then
        return false
    end
    balls[player_id] = nil
    local leave_msg = { "leave", player_id }
    broadcast(leave_msg)
end

--改变速度
s.resp.shift = function(source, player_id, x, y)
    local b = balls[player_id]
    if not b then
        return false
    end
    b.speed_x = x
    b.speed_y = y
end

--移动逻辑
function move_update()
    for k, v in pairs(balls) do
        v.x = v.x + v.speed_x * 0.2
        v.y = v.y + v.speed_y * 0.2
        if v.speed_x ~= 0 or v.speed_y ~= 0 then
            local msg = { "move", v.player_id, v.x, v.y }
            broadcast(msg)
        end
    end
end

--生成食物
--判断食物总量：场景中最多能有50个食物，多了就不再生成。
--控制生成时间：计算一个0到100的随机数，只有大于等于98才往下执行，即往下执行的概率是1/50。由于主循环每0.2秒调用一次food_update，因此平均下来每10秒会生成一个食物。
function food_update()
    if food_count > 50 then
        return
    end

    if math.random(1, 100) < 98 then
        return
    end

    food_max_id = food_max_id + 1
    food_count = food_count + 1
    local f = food()
    f.id = food_max_id
    foods[f.id] = f

    local msg = { "addfood", f.id, f.x, f.y }
    broadcast(msg)
end

--吞下食物
--它会遍历所有的球和食物，并根据两点间距离公式判断小球是否和食物发生了碰撞。如果发生碰撞，即视为吞下食物，服务端会广播eat协议，并让食物消失
function eat_update()
    for bid, b in pairs(balls) do
        for fid, f in pairs(foods) do
            if (b.x - f.x) ^ 2 + (b.y - f.y) ^ 2 < b.size ^ 2 then
                --吃食物
                b.size = b.size + 1
                food_count = food_count - 1
                local msg = { "eat", b.player_id, fid, b.size }
                broadcast(msg)
                foods[fid] = nil
            end
        end
    end
end

function update(frame)
    food_update()
    move_update()
    eat_update()
end

s.init = function()
    skynet.fork(function()
        local stime = skynet.now()
        local frame = 0
        while true do
            frame = frame + 1
            local is_ok, err = pcall(update, frame)
            if not is_ok then
                skynet.error(err)
            end
            local etime = skynet.now()
            local wait_time = frame * 20 - (etime - stime)
            if wait_time <= 0 then
                wait_time = 2
            end
            skynet.sleep(wait_time)
        end
    end)
end

s.start(...)