local skynet = require "skynet"
local pb = require "protobuf"

function test()
    pb.register_file("./proto/login.pb")
    local msg = {
        id = 123,
        pwd = "123",
    }
    local buf = pb.encode("login.Login", msg)
    print("len:" .. string.len(buf))
    local ret = pb.decode("login.Login", buf)
    if ret then
        print(ret.id)
        print(ret.pwd)
    else
        print("error")
    end
end

skynet.start(function()
    test()
end)