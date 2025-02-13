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
//

int main() {

    return 0;
}