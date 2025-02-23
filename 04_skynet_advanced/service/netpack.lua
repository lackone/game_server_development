local skynet = require "skynet"
local socket_driver = require "skynet.socketdriver"
local netpack = require "skynet.netpack"

local queue --消息队列

--queue是一个userdata，它是由C语言定义的数据对象，可按顺序存放待处理的完整消息
--消息的内容包括fd（哪个客户端发来的）、msg（消息内容）、sz（size，消息长度）等。

--当有网络事件（新连接、连接关闭、收到数据）发生时，先用socket_unpack方法解析它，再用dispatch方法处理它。
function socket_unpack(msg, sz)
    return netpack.filter(queue, msg, sz)
end

--有新连接
function process_connect(fd, addr)
    skynet.error("new conn fd:" .. fd .. " addr:" .. addr)
    socket_driver.start(fd)
end

--关闭连接
function process_close(fd)
    skynet.error("close fd:" .. fd)
end

--发生错误
function process_error(fd, error)
    skynet.error("error fd:" .. fd .. " error:" .. error)
end

--发生警告
function process_warning(fd, size)
    skynet.error("warning fd:" .. fd .. " size:" .. size)
end

--处理消息
--参数fd、msg、sz分别代表消息来源、消息内容和消息长度
function process_msg(fd, msg, sz)
    local str = netpack.tostring(msg, sz)
    skynet.error("recv from fd:" .. fd .. " str:" .. str)
end

--收到多于1条消息时
function process_more()
    for fd, msg, sz in netpack.pop, queue do
        --使用skynet.fork创建process_msg协程，是为了保障阻塞消息处理方法的时序一致性。
        skynet.fork(process_msg, fd, msg, sz)
    end
end

function socket_dispatch(_, _, q, type, ...)
    skynet.error("socket_dispatch type:" .. (type or "nil"))
    queue = q
    if type == "open" then
        --有新连接
        process_connect(...)
    elseif type == "data" then
        --netpack.filter对数据分包处理，如果分包后刚好有一条完整消息，触发data事件，如果不止一条，返回more消息
        process_msg(...)
    elseif type == "more" then
        --同上
        process_more(...)

    elseif type == "close" then
        --连接关闭
        process_close(...)
    elseif type == "error" then
        --发生错误
        process_error(...)
    elseif type == "warning" then
        --缓冲区积累数据过多时，发生warning事件
        process_warning(...)
    end
end

skynet.start(function()
    skynet.register_protocol({
        name = "socket",
        id = skynet.PTYPE_SOCKET,
        unpack = socket_unpack,
        dispatch = socket_dispatch,
    })
    local lfd = socket_driver.listen("0.0.0.0", 8888)

    --socket_driver.nodelay(lfd)

    socket_driver.start(lfd)
end)

--可使用socketdriver.nodelay(listenfd)禁用Nagle算法，这对实时性要求高的游戏很有帮助。
--Nagle算法是默认开启的，开启后发送端多次发送很小的数据包时，并不会立马发送它们，而是积攒到一定数量后再组成一个较大的数据包发送出去。
--Nagle算法可以节省数据流量（每个TCP包都要包含一些额外信息），但增加了延迟。