#include <iostream>

using namespace std;

//安装skynet
//git clone https://github.com/cloudwu/skynet.git
//cd skynet
//make linux

//安装依赖
//yum install git gcc autoconf readline-devel

//如果速度太慢，可换下面国内镜像
//git clone https://gitee.com/mirrors/skynet.git

//下载jemalloc
//cd skynet/3rd
//git clone https://gitee.com/mirrors/jemalloc.git

//启动Skynet
//./skynet examples/config

//启动客户端
//./3rd/lua/lua examples/client.lua

//节点和服务
//每个Skynet进程（操作系统进程）称为一个节点，每个节点可以开启数千个服务。不同节点可以部署在不同的物理机上，提供分布式集群的能力。
//每个Skynet节点可以调度数千个Lua服务，让它们并行工作。每个服务都是一个Actor。

//skynet配置文件

//必须配置
//thread = 8                        --启用多少个工作线程
//cpath = root.."cservice/?.so"     --用C编写的服务模块的位置

//bootstrap配置项
//bootstrap = "snlua bootstrap"     --启动的第一个服务
//start = "main"                    --主服务入口
//harbor = 1                        --使用主从节点模式

//lua配置项
//luaservice = root.."service/?.lua;"..root.."test/?.lua;"..root.."examples/?.lua;"..root.."test/?/init.lua"
//lualoader = root .. "lualib/loader.lua"
//lua_path = root.."lualib/?.lua;"..root.."lualib/?/init.lua"
//lua_cpath = root .. "luaclib/?.so"

//后台模式
//daemon = "./skynet.pid"
//logger = nil

//skynet中8个最重要的API
//newservice(name, ...)         启动一个名为name的新服务
//start(func)                   用func函数初始化服务，
//dispatch(type, func)          为type类型的消息设定处理函数func
//send(addr, type, cmd, ...)    向地址addr的服务发送一条type类型的消息
//call(addr, type, cmd, ...)    向地址addr的服务发送一条type类型的消息，等待对方的回应，call阻塞方法
//exit()                        结束当前服务
//self()                        返回当前服务的地址
//error(msg)                    向log服务发送一条消息

//第一个程序pingpong
// ./skynet examples/pconfig

//skynet.socket模块提供了网络编程的API
//socket.listen(host, port)         监听客户端连接
//socket.start(fd, connect)         新客户端连接时，回调方法connect会调用
//socket.read(fd)                   读取数据，阻塞方法
//socket.write(fd, data)            把数据写入队列
//socket.close(fd)                  关闭连接，阻塞方法


//学习数据库模块
//skynet.db.mysql模块提供操作MySQL数据库的方法
//mysql.connect()   连接数据库
//db:query(sql)   执行sql语句


//监控服务状态
//Skynet自带了一个调试控制台服务debug_console，启动它之后，可以查看节点的内部状态。
//skynet.newservice("debug_console", 8000)
//telnet 127.0.0.1 8000
//list   list指令用于列出所有的服务，以及启动服务的参数。
//mem指令 mem指令用于显示所有Lua服务占用的内存。
//stat指令  stat指令用于列出所有Lua服务的CPU时间、处理的消息总数（message）、消息队列长度（mqlen）、被挂起的请求数量（task）等。
//netstat指令  netstat指令用于列出网络连接的概况。


//使用节点集群建立分布式系统
//Skynet提供了cluster集群模式，可让不同节点中的服务相互通信。
//cluster.reload(cfg)  让本节点重新加载节点配置
//cluster.open(node)   启动节点，节点1需要调用cluster.open(node1)，节点2需要cluster.open(node2)
//cluster.send(node, address, cmd, ...)  向node节点，地址address的服务推送消息
//cluster.call(node, address, cmd, ...)  与send功能相似，不同的是，它是阻塞方法
//cluster.proxy(node, address)  为远程节点上的服务创建一个本地代理，它会返回代理对象，之后可以用skynet.send,skynet.call操作该代理

//使用代理
//先将节点2的pong服务作为代理（变量pong），之后便可以将它视为本地服务，在此方法中通过 skynet.send或skynet.call发送消息。

//协程的作用
//Skynet服务在收到消息时，会创建一个协程，在协程中会运行消息处理方法（即用skynet.dispatch设置的回调方法）。
//这意味着，如果在消息处理方法中调用阻塞API（如skynet.call、 skynet.sleep、socket.read），服务不会被卡住（仅仅是处理消息的协程被卡住），执行效率得以提高，但程序的执行时序将得不到保证。

int main() {

    return 0;
}