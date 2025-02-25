#include <iostream>
#include "Sunnet.h"
using namespace std;

void test() {
    auto t = make_shared<string>("gateway");
    uint32_t gateway = Sunnet::inst->NewService(t);
}

int main() {
    new Sunnet();
    Sunnet::inst->Start();
    test();
    Sunnet::inst->Wait();
    return 0;
}
