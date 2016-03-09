#include <lua.h>
#include <lauxlib.h>

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define IP_LEN 14

#define PORT_START (1<<15)
#define PORT_RANGE (1<<15)

#define IP1_START (1<<7)
#define IP1_RANGE (1<<7)

#define IP2_START 0
#define IP2_RANGE (1<<8)

#define LIB_VERSION  "lua-portlock-module 0.1"

#if LUA_VERSION_NUM < 502
#   define luaL_newlib(L, f)  { lua_newtable(L); luaL_register(L, NULL, f); }
#endif

//elfhash function modified from https://en.wikipedia.org/wiki/PJW_hash_function
int elfhash( const char* key )
{
    unsigned long hash = 0;
    unsigned long high;

    while( *key ){

        hash = (hash << 4) + (*key++);

        high = hash & 0xF0000000L;

        if( high ){
            hash ^= high >> 24;
        }

        hash &= ~high;
    }

    hash = hash & 0x7FFFFFFF;

    return hash;
}

void init_addr( const char *name, struct sockaddr_in *sockaddr )
{
    int hash;
    int p1, p2, port;
    char ip[ IP_LEN ] = {0};

    hash = elfhash( name );

    p1 = hash % IP1_RANGE + IP1_START;
    hash /= IP1_RANGE;

    p2 = hash % IP2_RANGE + IP2_START;
    hash /= IP2_RANGE;

    port = hash % PORT_RANGE + PORT_START;

    sprintf( ip, "127.1.%d.%d", p1, p2 );

    memset(sockaddr, 0, sizeof(*sockaddr));
    sockaddr->sin_family = AF_INET;
    sockaddr->sin_addr.s_addr = inet_addr( ip );
    sockaddr->sin_port = htons( port );
}

int lock_port( lua_State *L )
{
    int sock;
    int ret;
    int n;
    struct in_addr addr;
    struct sockaddr_in sockaddr;
    const char *lockname  = NULL;


    n = lua_gettop(L);
    if(n != 1){
        lua_pushnil(L);
        lua_pushfstring(L, "lock port: only one argument is excepted,\
                                                              but got %d", n);
        return 2;
    }

    lockname = luaL_checkstring(L, 1);

    init_addr(lockname, &sockaddr);

    sock = socket(AF_INET, SOCK_STREAM, 0);
    if( sock == -1 ){
        lua_pushnil(L);
        lua_pushfstring(L, "create socket error: %s(errno: %d)",\
                                                      strerror(errno), errno);
        return 2;
    }

    memcpy(&addr, &sockaddr.sin_addr.s_addr, 4);

    ret = bind(sock, (struct sockaddr*)&sockaddr, sizeof(sockaddr));
    if( ret != 0 ){
        lua_pushnil(L);
        lua_pushfstring(L,"bind socket(ip: %s port: %d) error: %s(errno: %d)",\
                        inet_ntoa(addr), ntohs(sockaddr.sin_port), strerror(errno), errno);
        return 2;
    }

    lua_pushnumber(L, sock);
    lua_pushfstring(L,"bind socket(ip: %s port: %d) success",\
                                        inet_ntoa(addr), ntohs(sockaddr.sin_port));

    return 2;
}

int unlock_port( lua_State *L )
{
    int sock;
    int ret;
    int n;

    n = lua_gettop(L);
    if(n != 1){
        lua_pushnil(L);
        lua_pushfstring(L, "unlock port: only one argument is excepted,\
                                                              but got %d", n);
        return 2;
    }

    sock = luaL_checknumber(L, 1);
    ret = close( sock );

    if(ret != 0){
        lua_pushstring(L, "close failed");
        lua_pushstring(L, "unlock port failed");
    }
    else{

        lua_pushnil(L);
        lua_pushstring(L, "unlock port success");
    }

    return 2;
}

static const luaL_Reg s2portlock[] = {
    { "lock_port", lock_port },
    { "unlock_port", unlock_port },
    { NULL, NULL }
};

int luaopen_s2portlock( lua_State *L )
{
    luaL_newlib(L, s2portlock);

    lua_pushliteral(L, "VERSION");
    lua_pushstring(L, LIB_VERSION);
    lua_settable(L, -3);

    return 1;
}

