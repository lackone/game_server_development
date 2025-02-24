#include <iostream>
#include "Sunnet.h"
#include "Worker.h"
using namespace std;

//工程目录
//include   存放头文件
//src       存放源文件
//build     存放构建工程时生成的临时文件，可执行文件
//CMakeLists.txt cmake的指导文件

void test() {
    auto ping_type = make_shared<string>("ping");
    uint32_t ping1 = Sunnet::inst->NewService(ping_type);
    uint32_t ping2 = Sunnet::inst->NewService(ping_type);
    auto pong_type = make_shared<string>("pong");
    uint32_t pong = Sunnet::inst->NewService(pong_type);

    auto msg1 = Sunnet::inst->MakeMsg(ping1, new char[20]{'h', 'e', 'l', 'l', 'o', '\0'}, 20);
    auto msg2 = Sunnet::inst->MakeMsg(ping2, new char[20]{'t', 'e', 's', 't', '\0'}, 20);

    sleep(3);

    Sunnet::inst->Send(pong, msg1);
    Sunnet::inst->Send(pong, msg2);
}

int main() {
    new Sunnet();
    Sunnet::inst->Start();
    test();
    Sunnet::inst->Wait();
    return 0;
}
