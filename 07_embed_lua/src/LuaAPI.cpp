#include "LuaAPI.h"

void LuaAPI::Register(lua_State *lua_state) {
    static luaL_Reg lualibs[] = {
        { "NewService", NewService },
        { "KillService", KillService },
        { "Send", Send },
        { "Listen", Listen },
        { "CloseConn", CloseConn },
        { "Write", Write },
        { NULL, NULL }
    };
    luaL_newlib (lua_state, lualibs);
    lua_setglobal(lua_state, "sunnet");
}

//当Lua调用C++时，被调用的方法会得到一个新的栈
//新栈中包含了Lua传递给C++的所有参数，而C++方法需要把返回的结果放入栈中，以返回给调用者。
//C++方法有一套固定的编写套路，一般分为“获取参数、处理、返回结果”三个步骤。
int LuaAPI::NewService(lua_State *lua_state) {
    //获取参数个数
    int num = lua_gettop(lua_state);
    //参数1：服务类型
    if (lua_isstring(lua_state, 1) == 0) { //1:是 0:不是
        lua_pushinteger(lua_state, -1);
        return 1;
    }
    size_t len = 0;
    const char *type = lua_tolstring(lua_state, 1, &len);
    char *str = new char[len + 1];
    str[len] = '\0';
    memcpy(str, type, len);
    auto t = make_shared<string>(str);
    //处理
    uint32_t id = Sunnet::inst->NewService(t);
    //返回值
    lua_pushinteger(lua_state, id);
    return 1;
}

int LuaAPI::KillService(lua_State *lua_state) {
    //获取参数个数
    int num = lua_gettop(lua_state);
    if (lua_isinteger(lua_state, 1) == 0) {
        return 0;
    }
    int id = lua_tointeger(lua_state, 1);
    //处理
    Sunnet::inst->KillService(id);
    //返回值
    return 0;
}

int LuaAPI::Send(lua_State *lua_state) {
    //获取参数个数
    int num = lua_gettop(lua_state);
    if (num != 3) {
        cout << "send fail, num err" << endl;
        return 0;
    }
    //1、发送源
    if (lua_isinteger(lua_state, 1) == 0) {
        cout << "send fail, arg1 err" << endl;
        return 0;
    }
    int source = lua_tointeger(lua_state, 1);
    //2、接收方
    if (lua_isinteger(lua_state, 2) == 0) {
        cout << "send fail, arg2 err" << endl;
        return 0;
    }
    int to = lua_tointeger(lua_state, 2);
    //3、发送内容
    size_t len = 0;
    const char* str = lua_tolstring(lua_state, 3, &len);
    char *new_str = new char[len];
    memcpy(new_str, str, len);
    //处理
    auto msg = make_shared<ServiceMsg>();
    msg->type = BaseMsg::TYPE::SERVICE;
    msg->source = source;
    msg->buf = shared_ptr<char>(new_str);
    msg->size = len;
    Sunnet::inst->Send(to, msg);
    //返回值
    return 0;
}

//开启网络监听
int LuaAPI::Listen(lua_State *lua_state) {
    //获取参数个数
    int num = lua_gettop(lua_state);
    if (lua_isinteger(lua_state, 1) == 0) {
        lua_pushinteger(lua_state, -1);
        return 1;
    }
    int port = lua_tointeger(lua_state, 1);
    if (lua_isinteger(lua_state, 2) == 0) {
        lua_pushinteger(lua_state, -1);
        return 1;
    }
    int id = lua_tointeger(lua_state, 2);
    int fd = Sunnet::inst->Listen(port, id);
    lua_pushinteger(lua_state, fd);
    return 1;
}

//关闭连接
int LuaAPI::CloseConn(lua_State *lua_state) {
    //获取参数个数
    int num = lua_gettop(lua_state);
    if (lua_isinteger(lua_state, 1) == 0) {
        return 0;
    }
    int fd = lua_tointeger(lua_state, 1);
    //处理
    Sunnet::inst->CloseConn(fd);
    //返回值
    return 0;
}

//第1个参数代表Socket描述符，第2个参数代表要发送的内容
int LuaAPI::Write(lua_State *lua_state) {
    //获取参数个数
    int num = lua_gettop(lua_state);
    //参数1，fd
    if (lua_isinteger(lua_state, 1) == 0) {
        lua_pushinteger(lua_state, -1);
        return 1;
    }
    int fd = lua_tointeger(lua_state, 1);
    if (lua_isstring(lua_state, 2) == 0) {
        lua_pushinteger(lua_state, -1);
        return 1;
    }
    size_t len = 0;
    const char* str = lua_tolstring(lua_state, 2, &len);
    //处理
    int ret = write(fd, str, len);
    //返回值
    lua_pushinteger(lua_state, ret);
    return 1;
}