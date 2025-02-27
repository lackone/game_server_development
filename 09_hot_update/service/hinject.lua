--“_P”是Skynet提供的变量，用于获取旧代码的内容
local oldfun = _P.lua._ENV.onMsg

--“_P.lua._ENV.onMsg”即原先的onMsg方法
_P.lua._ENV.onMsg = function(data)
    local _, skynet = debug.getupvalue(oldfun, 1)
    local _, coin = debug.getupvalue(oldfun, 2)
    skynet.error("agent recv " .. data)
    --消息处理
    if data == "work\r\n" then
        coin = coin + 3
        debug.setupvalue(oldfun, 2, coin)
        return coin .. "\r\n"
    end
    return "err cmd\r\n"
end