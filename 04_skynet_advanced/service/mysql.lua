local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
local pb = require "protobuf"

local db

function test()
    local player = {}
    local res = db:query("select * from player where id = 1")
    if not res or not res[1] then
        print("loading error")
        return false
    end
    player.coin = res[1].coin
    player.name = res[1].name
    player.last_login_time = res[1].last_login_time
    print(player.coin, player.name, player.last_login_time)
end

function test2()
    pb.register_file("./storage/player_data.pb")
    --创建角色
    local player_data = {
        id = 111,
        coin = 999,
        name = "test",
        level = 3,
        last_login_time = os.time(),
    }
    local data = pb.encode("player_data.BaseInfo", player_data)
    print("len:" .. string.len(data))
    local sql = string.format("insert into base_info(id, data) values(%d, %s)", 111, mysql.quote_sql_str(data))
    local res = db:query(sql)
    if res.err then
        print("error:" .. res.err)
    else
        print("ok")
    end
end

function test3()
    pb.register_file("./storage/player_data.pb")
    local sql = string.format("select * from base_info where id = %d", 111)
    local res = db:query(sql)
    local data = res[1].data
    print("data len:" .. string.len(data))
    local player = pb.decode("player_data.BaseInfo", data)
    if not player then
        print("error")
        return false
    end
    print(player.coin, player.name, player.level, player.last_login_time, player.skin)
end

--local player_data = {
--    base_info = {}, --基本信息
--    bag = {}, --背包
--    task = {}, --任务
--    friend = {}, --朋友
--    mail = {}, --邮件
--    achieve = {}, --成就
--    title = {}, --称号
--}

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
    test()
    test2()
    test3()
end)