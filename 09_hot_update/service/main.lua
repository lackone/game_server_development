local shop = require("shop")

local players = {} --玩家列表
players[101] = { coin = 1000, bag = {} } --假设玩家101已登录

--实现Lua热更新
--Lua的“require（模块名）”方法会加载一个Lua模块，并缓存到package.loaded[modelname]中。
--如果对同一个模块重复调用require方法，那么程序将会从缓存中取值，而不再加载Lua文件。因此，热更新前需要先清空缓存，再调用require方法。
function reload()
    package.loaded["shop"] = nil
    shop = require("shop")
    print("reload succ")

    --更新cmdHandle.b
    cmdHandle.b = shop.onBuyMsg
end

--用字符输入模拟网络消息
while true do
    cmd = io.read()
    if cmd == "b" then
        --buy
        shop.onBuyMsg(players[101], 1001)
    elseif cmd == "r" then
        --reload
        reload()
    end
end

local cmdHandle = {
    b = shop.onBuyMsg, --注意，注意，调用reload()后，这里仍然引用的旧的
    --s = shop.onSellMsg, --出售
    --w = work.onWorkMsg,
    r = reload,
}

while true do
    cmd = io.read()
    cmdHandle[cmd](players[101], 1001)
end