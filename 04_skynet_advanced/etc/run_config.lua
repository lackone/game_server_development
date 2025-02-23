return {
    --集群
    --cluster项指明服务端系统包含两个节点，分别为node1和node2。
    cluster = {
        node1 = "127.0.0.1:7771",
        node2 = "127.0.0.1:7772",
    },
    --agentmgr
    --agentmgr项指明全局唯一的agentmgr服务位于节点1处。
    agent_mgr = {
        node = "node1",
    },
    --scene
    --scene项指明在节点1开启编号为1001和1002的两个战斗场景服务
    scene = {
        node1 = { 1001, 1002 },
        --node2 = {1003},
    },
    --节点1
    --node1和node2描述了各节点的“本地”服务。两个节点分别开启了两个gateway和两个login
    node1 = {
        gateway = {
            [1] = { port = 8001 },
            [2] = { port = 8002 },
        },
        login = {
            [1] = {},
            [2] = {},
        },
    },
    --节点2
    node2 = {
        gateway = {
            [1] = { port = 8011 },
            [2] = { port = 8022 },
        },
        login = {
            [1] = {},
            [2] = {},
        },
    },
}