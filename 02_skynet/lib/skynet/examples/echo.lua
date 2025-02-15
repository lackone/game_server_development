local skynet = require "skynet"
local socket = require "skynet.socket"

skynet.start(function()
    local listen_fd = socket.listen("0.0.0.0", 8888)
    socket.start(listen_fd, connect) --新客户端发起连接时，connect方法将被调用
end)

function connect(fd, addr)
    --启用连接
    print(fd .. " connected addr : " .. addr)
    socket.start(fd)
    --消息处理
    while true do
        local read_data = socket.read(fd)
        if read_data ~= nil then
            print(fd .. " recv " .. read_data)
            socket.write(fd, read_data)
        else
            print(fd .. "close")
            socket.close(fd)
        end
    end
end