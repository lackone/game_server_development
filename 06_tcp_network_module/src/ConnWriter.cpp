#include "ConnWriter.h"


void ConnWriter::EntireWrite(shared_ptr<char> buf, streamsize len) {
    //如果关闭，直接返回
    if (is_closing) {
        cout << "EntireWrite Closing" << endl;
        return;
    }
    //情况1，如果链表为空，说明还没有数据写入
    if (write_list.empty()) {
        EntireWriteWhenEmpty(buf, len);
    } else {
        //情况2：有待写入数据，添加到末尾
        EntireWriteWhenNotEmpty(buf, len);
    }
}

//全部发完后再关闭
void ConnWriter::LingerClose() {
    if (is_closing) {
        return;
    }
    is_closing = true;
    //只有链表里的数据空了，才真正关闭fd
    if (write_list.empty()) {
        Sunnet::inst->CloseConn(fd);
    }
}

void ConnWriter::OnWriteable() {
    auto conn = Sunnet::inst->GetConn(fd);
    if (!conn) {
        return;
    }

    while(WriteFrontObj()) {
        //循环的从链表头取出数据，发送
    }

    if (write_list.empty()) {
        //如果数据发送完了，则取消监听写
        Sunnet::inst->ModifyEvent(fd, false);

        if (is_closing) {
            //关闭指定套接字描述符 fd 的读取端
            shutdown(fd, SHUT_RD);

            //发送一个读消息，让服务端继续读
            //但是上面shutdown已经关闭了读，就会导致Bad file descriptor错误，从而进入错误处理，关闭socket
            auto msg= make_shared<SocketRWMsg>();
            msg->type = BaseMsg::TYPE::SOCKET_RW;
            msg->fd = conn->fd;
            msg->is_read = true;
            Sunnet::inst->Send(conn->service_id, msg);
        }
    }
}

void ConnWriter::EntireWriteWhenEmpty(shared_ptr<char> buf, streamsize len) {
    char* s = buf.get();
    //返回 >=0 时，表示写入的字节数
    //当 write() 返回 -1 且 errno 是 EAGAIN 时，表示写缓冲区已满，稍后重试写入操作
    //当 write() 返回 -1 且 errno 是 EINTR 时，调用被中断了，需要重新调用
    streamsize ret = write(fd, s, len);
    if (ret < 0 && errno == EINTR) {

    }
    //情况1，一次性全部写完
    if (ret >= 0 && ret == len) {
        return;
    }
    //情况2，写了一部分
    if ((ret > 0 && ret < len) || (ret < 0 && errno == EAGAIN)) {
        auto obj = make_shared<WriteObject>();
        obj->start = ret;
        obj->buf = buf;
        obj->len = len;
        write_list.push_back(obj);
        //监听写事件
        Sunnet::inst->ModifyEvent(fd, true);
    }
    //情况3，发生错误
    cout << "EntireWrite write error" << endl;
}

void ConnWriter::EntireWriteWhenNotEmpty(shared_ptr<char> buf, streamsize len) {
    auto obj = make_shared<WriteObject>();
    obj->start = 0;
    obj->buf = buf;
    obj->len = len;
    write_list.push_back(obj);
}

bool ConnWriter::WriteFrontObj() {
    //没待写数据
    if (write_list.empty()) {
        return false;
    }
    //获取链表第一个
    auto obj = write_list.front();

    //获取剩余没发送的
    char* s = obj->buf.get() + obj->start;
    //剩余长度
    int len = obj->len - obj->start;
    int ret = write(fd, s, len);

    //情况1；全部写完
    if (ret >= 0 && ret == len) {
        write_list.pop_front(); //弹出
        return true;
    }
    //情况2，写一部分
    if ((ret > 0 && ret < len) || (ret < 0 && errno == EAGAIN)) {
        obj->start += ret;
        return false;
    }
    //情况3，出错
    cout << "EntireWrite write error" << endl;
    return false;
}