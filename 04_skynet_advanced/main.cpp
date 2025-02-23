#include <iostream>

using namespace std;

//用“长度信息”解TCP包
//长度信息法
//“长度信息法”指在数据包前面加上长度信息。游戏一般会使用2字节或4字节来表示长度

//安装lua-cjson模块
// luarocks install lua-cjson
// cp /usr/local/lib/lua/5.4/cjson.so ./luaclib

//设计完整协议格式
//前两个字节代表消息长度，即示例中“04move{"x"=1, "y"=2}”的长度（19字节），第3字节和第4字节为协议名长度，即示例中“move”的长度（4字节）。
//通过 协议名长度，程序可以正确解析协议名称，并根据名称做消息分发。 示例中“ { "x" = 1, "y" = 2 }” 为协议体，可由它解析出协议对象（Lua 表）。

//用Protobuf高效传输
//安装protobuf
//dnf install protobuf
//dnf --enablerepo=crb install protobuf-compiler
//安装pbc
//1、git clone https://github.com/cloudwu/pbc
//2、安装https://gmplib.org/
//3、cd pbc && make
//4、cd pbc/binding/lua53 && make
//5、cp protobuf.so ../../../../luaclib/
//6、cp protobuf.lua ../../../../lualib/


//编码和解码
//pbc模块常用的API有“register_file”“encode”和“ decode” 。
//使用pbc编解码之前，需先用register_file注册编译文件（.pb文件），然后用encode方法编码、 用decode方法解码。
//protoc --descriptor_set_out login.pb login.proto

//Key-Value表结构
//protoc --descriptor_set_out player_data.pb player_data.proto

//按照功能模块划分玩家数据表

int main() {
    return 0;
}
