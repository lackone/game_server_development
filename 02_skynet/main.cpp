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

int main() {

    return 0;
}