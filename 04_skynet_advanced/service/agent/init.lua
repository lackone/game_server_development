local skynet = require "skynet"
local s = require "service"

s.client = {}
s.gate = nil

require "scene"

--os.time() 得到是当前时间距离1970.1.1.08:00的秒数
function get_day(timestamp)
    local day = (timestamp + 3600 * 8) / (3600 * 24)
    return math.ceil(day)
end

--每天第一次登录
function first_login_day()
    print("欢迎登录")
end

--1970年01月01日是星期四。此处以周四20:40点为界
function get_week_by_thu2040(timestamp)
    local week = (timestamp + 3600 * 8 - 3600 * 20 - 40 * 60) / (3600 * 24 * 7)
    return math.ceil(week)
end

--开启活动
function open_activity()
    print("开启活动")
end

--开启服务器时从数据库读取
--关闭服务器时保存
local last_check_time = 1582935650
--每隔一小段时间执行
function timer()
    local last = get_week_by_thu2040(last_check_time)
    local now = get_week_by_thu2040(os.time())
    last_check_time = os.time()
    if now > last then
        open_activity() --开启活动
    end
end

s.init = function()
    --加载角色数据
    skynet.sleep(200)
    s.data = {
        coin = 999,
        hp = 999,
        last_login_time = 1740324105,
    }

    --获取和更新登录时间
    local last_day = get_day(s.data.last_login_time)
    local day = get_day(os.time())
    s.data.last_login_time = os.time()
    --判断每天第一次登录
    if day > last_day then
        first_login_day() --每天第一次登录执行
    end
end

s.resp.kick = function(source)
    s.leave_scene()
    --保存角色数据
    skynet.sleep(200)
end

s.resp.exit = function(source)
    skynet.exit()
end

s.resp.send = function(source, msg)
    skynet.send(s.gate, "lua", "send", s.id, msg)
end

s.client.work = function(msg)
    s.data.coin = s.data.coin + 1
    return { "work", s.data.coin }
end

s.resp.client = function(source, cmd, msg)
    s.gate = source
    if s.client[cmd] then
        local ret = s.client[cmd](msg, source)
        if ret then
            --这里的s.id就是player_id
            --s.call(node,"node_mgr","new_service","agent","agent",playerid)最后两个参数会被传递到node_mgr中，再传递到agent服s.start(...)的可变参数中。
            --所以对于agent服务，s.name为“agent”，s.id为玩家id。
            skynet.send(source, "lua", "send", s.id, ret)
        end
    else
        skynet.error("s.resp.client fail", cmd)
    end
end

s.start(...)