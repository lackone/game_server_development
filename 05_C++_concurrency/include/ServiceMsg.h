#ifndef SERVICEMSG_H
#define SERVICEMSG_H

#include <memory>
#include "BaseMsg.h"

using namespace std;

//服务间消息
class ServiceMsg : public BaseMsg {
public:
    uint32_t source; //消息发送方
    shared_ptr<char> buf; //消息内容
    size_t size; //消息内容大小
};



#endif //SERVICEMSG_H
