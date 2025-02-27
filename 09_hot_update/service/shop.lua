local M = {}

local goods = {
    [1001] = { name = "金创药", price = 10 },
    [1002] = { name = "葫芦", price = 2 }
}

--local remain = {
--    [1001] = 100, --今日剩余的金创药数量
--    [1002] = 200, --今日剩余的葫芦数量
--}

--把不需要更新的变量设为全局变量
--注意代码中没有local
remain = remain or {
    [1001] = 100,
    [1002] = 200,
}

M.onBuyMsg = function(player, id)
    local item = goods[id]
    --省略对金币和限购数量的判定
    player.coin = player.coin - item.coin
    remain[id] = remain[id] - 1
    --...
    local tip = string.format("player buy item %d, coin:%d remain:%d", id, player.coin, remain[id])
    print(tip)
end

M.onBuyMsg2 = function(player, id)
    local item = goods[id]
    --扣金币，这里缺少对金币数量是否充足的判定
    player.coin = player.coin - item.price
    --增加道具计数
    player.bag[id] = player.bag[id] or 0
    player.bag[id] = player.bag[id] + 1
    --...
    local tip = string.format("player buy item %d, coin:%d item_num:%d", id, player.coin, player.bag[id])
    print(tip)
end

return M