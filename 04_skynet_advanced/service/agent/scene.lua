local skynet = require "skynet"
local s = require "service"
local run_config = require "run_config"
local node = skynet.getenv("node")

s.snode = nil --scene_node
s.sname = nil  --scene_id


s.leave_scene = function()
    if not s.sname then
        return
    end
    print(s.id .. " leave_scene")
    s.call(s.snode, s.sname, "leave", s.id)
    s.snode = nil
    s.sname = nil
end

--随机选择场景
local function random_scene()
    local nodes = {}
    for k, v in pairs(run_config.scene) do
        table.insert(nodes, k)
        --具体做法是，先把所有配置了场景服务的节点都放在表nodes中，同一节点（mynode）会插入多次，使它能有更高被选中的概率。
        if run_config.scene[node] then
            table.insert(nodes, node)
        end
    end
    local idx = math.random(1, #nodes)
    local scene_node = nodes[idx]
    --具体场景
    local scene_list = run_config.scene[scene_node]
    local idx = math.random(1, #scene_list)
    local scene_id = scene_list[idx]
    return scene_node, scene_id
end

s.client.shift = function(msg)
    if not s.sname then
        return
    end
    local x = msg[2] or 0
    local y = msg[3] or 0
    s.call(s.snode, s.sname, "shift", s.id, x, y)
end

s.client.enter = function(msg)
    if s.sname then
        return { "enter", 1, "已在场景" }
    end
    local snode, sid = random_scene()
    local sname = "scene" .. sid
    print(snode, sname)
    local is_ok = s.call(snode, sname, "enter", s.id, node, skynet.self())
    if not is_ok then
        return { "enter", 1, "进入失败" }
    end
    s.snode = snode
    s.sname = sname
    return nil
end