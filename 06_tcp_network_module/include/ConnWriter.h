#ifndef CONNWRITER_H
#define CONNWRITER_H

#include <list>
#include <memory>
#include <iostream>
#include "Sunnet.h"

using namespace std;

class WriteObject {
public:
    streamsize start; //start代表已经写入套接字写缓冲区的字节数
    streamsize len; //len代表某次发送的总字节数
    shared_ptr<char> buf; //buf代表某次发送的内容
};

class ConnWriter {
public:
    int fd;
private:
    bool is_closing = false; //是否正在关闭
    list<shared_ptr<WriteObject>> write_list; //双向链表
public:
    void EntireWrite(shared_ptr<char> buff, streamsize len);
    void LingerClose(); //全部发完后再关闭
    void OnWriteable();
private:
    void EntireWriteWhenEmpty(shared_ptr<char> buff, streamsize len);
    void EntireWriteWhenNotEmpty(shared_ptr<char> buff, streamsize len);
    bool WriteFrontObj();
};



#endif //CONNWRITER_H
