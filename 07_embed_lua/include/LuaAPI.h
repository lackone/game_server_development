#ifndef LUAAPI_H
#define LUAAPI_H

#include <string.h>
#include <memory>
#include <string>
#include "Sunnet.h"

extern "C" {
    #include "lua.h"
    #include "lauxlib.h"
    #include "lualib.h"
}

class LuaAPI {
public:
    static void Register(lua_State *lua_state);
    static int NewService(lua_State *lua_state);
    static int KillService(lua_State *lua_state);
    static int Send(lua_State *lua_state);
    static int Listen(lua_State *lua_state);
    static int CloseConn(lua_State *lua_state);
    static int Write(lua_State *lua_state);
};



#endif //LUAAPI_H
