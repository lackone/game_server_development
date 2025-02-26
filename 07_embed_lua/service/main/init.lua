print("main init")

function OnInit(id)
    print("[lua] main OnInit id:" .. id)

    --local ping1 = sunnet.NewService("ping");
    --local ping2 = sunnet.NewService("ping");
    --local pong = sunnet.NewService("ping");

    --sunnet.Send(ping1, pong, "start")
    --sunnet.Send(ping2, pong, "start")

    sunnet.NewService("chat")
end

function OnExit()
    print("[lua] main OnExit")
end