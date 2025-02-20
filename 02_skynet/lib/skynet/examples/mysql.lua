local skynet = require "skynet"
local socket = require "skynet.socket"
local mysql = require "skynet.db.mysql"

local db = nil

skynet.start(function()
    db = mysql.connect({
        host = "192.168.1.4",
        port = 3306,
        database = "test",
        user = "root",
        password = "root",
        max_packet_size = 1024 * 1024,
        on_connect = nil
    })
    local lfd = socket.listen("0.0.0.0", 8888)
    socket.start(lfd, connect)
    --local ret = db:query("insert into msg(msg) values(\"hehe\")")
    --print(ret)
    --ret = db:query("select * from msg")
    --for k, v in pairs(ret) do
    --    print(k, v.id, v.msg)
    --end
end)

function connect(fd, addr)
    socket.start(fd)
    while true do
        local data = socket.read(fd)
        if data == "get\r\n" then
            local ret = db:query("select * from msg")
            for k, v in pairs(ret) do
                socket.write(fd, v.id .. " " .. v.msg .. "\r\n")
            end
        else
            local str = string.match(data, "set (.-)\r\n")
            db:query("insert into msg(msg) values(\"" .. str .. "\")")
        end
    end
end