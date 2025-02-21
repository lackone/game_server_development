local skynet = require "skynet"
local cluster = require "skynet.cluster"

local M = {
    name = "", --服务名
    id = 0, --服务编号
    --回调函数，服务初始化，退出时会调用
    init = nil,
    exit = nil,
    --分发方法
    --resp表会存放着消息处理方法
    resp = {},
}

function M.start(name, id, ...)
    M.name = name
    M.id = tonumber(id)
    skynet.start(init)
end

--打印出错误提示和堆栈。
function traceback(err)
    skynet.error(tostring(err))
    skynet.error(debug.traceback())
end

--参数address：代表消息发送方。
--参数cmd：代表消息名的字符串
--func：消息处理方法
--xpcall：安全的调用fun方法。如果fun方法报错，程序不会中断，而是会把错误信息转交给第2个参数的traceback。
--如果程序报错，xpcall会返回false；如果程序正常执行，xpcall返回的第一个值为true，从第2个值开始才是fun的返回值。
local dispatch = function(session, address, cmd, ...)
    local func = M.resp[cmd]
    if not func then
        skynet.ret()
        return
    end

    --table.pack 是一个用于将多个值打包成一个表的函数
    local ret = table.pack(xpcall(func, traceback, address, ...))
    local is_ok = ret[1]

    if not is_ok then
        skynet.ret()
        return
    end

    skynet.retpack(table.unpack(ret, 2))
end

function init()
    skynet.dispatch("lua", dispatch)
    if M.init then
        M.init()
    end
end

--参数node代表接收方所在的节点，srv_name代表接收方的服务名。
function M.call(node, srv_name, ...)
    local my_node = skynet.getenv("node")
    if node == my_node then
        --如果接收方在同个节点
        return skynet.call(srv_name, "lua", ...)
    else
        return cluster.call(node, srv_name, ...)
    end
end

function M.send(node, srv_name, ...)
    local my_node = skynet.getenv("node")
    if node == my_node then
        return skynet.send(srv_name, "lua", ...)
    else
        return cluster.send(node, srv_name, ...)
    end
end

return M