local skynet = require "skynet"
local skynet_manager = require "skynet.manager"
local run_config = require "run_config"
local cluster = require "skynet.cluster"

--主服务先开启nodemgr（每个节点必有一个），加载cluster（用于跨节点通信），再根据配置依次开启节点内的gate、login等服务。
--由于nodemgr、gateway、login是“本地服务”（见表3-1），因此使用skynet.name给它命名。agentmgr是“全局服务”，如果它在其他节点，则使用cluster.proxy创建一个代理。
skynet.start(function()
    skynet.error("[start main]")

    --初始化
    local node = skynet.getenv("node")
    local node_config = run_config[node]

    --节点管理
    local node_mgr = skynet.newservice("node_mgr", "node_mgr", 0)
    skynet.name("node_mgr", node_mgr)

    --集群
    cluster.reload(run_config.cluster)
    cluster.open(node)

    --gate
    for i, v in pairs(node_config.gateway or {}) do
        local srv = skynet.newservice("gateway", "gateway", i)
        skynet.name("gateway" .. i, srv)
    end

    --login
    for i, v in pairs(node_config.login or {}) do
        local srv = skynet.newservice("login", "login", i)
        skynet.name("login" .. i, srv)
    end

    --scene
    for _, sid in pairs(run_config.scene[node] or {}) do
        local srv = skynet.newservice("scene", "scene", sid)
        skynet.name("scene" .. sid, srv)
    end

    --agent_mgr
    local anode = run_config.agent_mgr.node
    if node == anode then
        local srv = skynet.newservice("agent_mgr", "agent_mgr", 0)
        skynet.name("agent_mgr", srv)
    else
        local proxy = cluster.proxy(anode, "agent_mgr")
        skynet.name("agent_mgr", proxy)
    end

    --admin
    local admin_node = "node1" --读run_config配置
    if node == admin_node then
        skynet.newservice("admin", "admin", 0)
    end

    skynet.exit()
end)