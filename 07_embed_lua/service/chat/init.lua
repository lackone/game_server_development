local sid;
local conns = {}

function OnInit(id)
    sid = id

    sunnet.Listen(8002, id)
end

function OnAcceptMsg(lfd, cfd)
    print("OnAcceptMsg : " .. cfd)
    conns[cfd] = true
end

function OnSocketData(fd, buf)
    print("OnSocketData : " .. fd)
    for f, _ in pairs(conns) do
        sunnet.Write(f, buf)
    end
end

function OnSocketClose(fd)
    print("OnSocketClose : " .. fd)
    conns[fd] = nil
end