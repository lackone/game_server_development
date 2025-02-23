local skynet = require "skynet"
local cjson = require "cjson"

function test1()
    local msg = {
        _cmd = "balllist",
        balls = {
            [1] = { id = 101, x = 10, y = 20 },
            [2] = { id = 102, x = 20, y = 30 },
        }
    }
    local buf = cjson.encode(msg)
    print(buf)
end

function test2()
    local buf = [[{"_cmd":"balllist","balls":[{"id":101,"x":10,"y":20},{"id":102,"x":20,"y":30}]}]]
    local is_ok, msg = pcall(cjson.decode, buf)
    if is_ok then
        print(msg._cmd)
        print(msg.balls[1].id)
    else
        print("error")
    end
end

function json_pack(cmd, msg)
    msg._cmd = cmd
    local body = cjson.encode(msg) --协议体字节流
    local name_len = string.len(cmd) --协议名长度
    local body_len = string.len(body) --协议体长度
    local len = name_len + body_len + 2 --总协议长度
    local format = string.format("> i2 i2 c%d c%d", name_len, body_len)
    local buf = string.pack(format, len, name_len, cmd, body)
    return buf
end

--参数buff代表去掉“长度信息”后的消息体
function json_unpack(buf)
    local len = string.len(buf)
    local name_len_format = string.format("> i2 c%d", len - 2)
    local name_len, other = string.unpack(name_len_format, buf)
    local body_len = len - 2 - name_len
    local body_format = string.format("> c%d c%d", name_len, body_len)
    local cmd, body = string.unpack(body_format, other)
    local is_ok, msg = pcall(cjson.decode, body)
    if not is_ok or not msg or not msg._cmd or not cmd == msg._cmd then
        print("json_unpack error")
        return
    end
    return cmd, msg
end

function test3()
    local msg = {
        _cmd = "player_info",
        coin = 999,
        bag = {
            [1] = { 100, 1 },
            [2] = { 200, 5 },
        }
    }
    --编码
    local buf = json_pack("player_info", msg)
    local len = string.len(buf)
    print("len:" .. len)
    print(buf)
    --解码
    local format = string.format("> i2 c%d", len - 2)
    local _, buf2 = string.unpack(format, buf)
    local cmd, ret = json_unpack(buf2)
    print("cmd:" .. cmd)
    print(ret.coin)
    print(ret.bag[1][1])
    print(ret.bag[2][2])
end

skynet.start(function()
    test1()
    test2()
    test3()
end)