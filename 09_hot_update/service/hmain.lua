local skynet = require "skynet"
local socket = require "skynet.socket"

--收到新连接时
function connect(fd, addr)
    --新连接
    skynet.error("new connnetion " .. fd)
    local id = skynet.newservice("hagent", fd)
    print("hagent : " .. id)
    socket.start(fd)
    --接收数据
    while true do
        local data = socket.read(fd) --忽略连接断开的情形
        local ret = skynet.call(id, "lua", "onMsg", data)
        socket.write(fd, ret)
    end
end

skynet.start(function()
    --调试控制台
    skynet.newservice("debug_console", 8000)
    --开启监听
    skynet.error("listen 0.0.0.0:8888")
    local lfd = socket.listen("0.0.0.0", 8888)
    socket.start(lfd, connect)
end)