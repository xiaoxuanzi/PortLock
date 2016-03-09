#!/bin/bash

lua=/usr/local/bin/lua
tmp_lua=tmp.lua

create_lua_script()
{
    if [ $# == 0 ]; then

   /bin/cat > $tmp_lua << __EOF__
local portlock = require("portlock")
local sock, msg = portlock.lock_port( "portlock" )
local n = 20
os.execute("sleep " .. n)
__EOF__

    else

   /bin/cat > $tmp_lua << __EOF__
local portlock = require("portlock")
local tableutil = require("tableutil")
local repr = tableutil.repr
local sock, err_msg = portlock.lock_port("portlock2")
assert( sock ~= nil, repr( {err=err_msg} ) )
local ret, err_msg = portlock.unlock_port( "sock")
assert( ret ~= nil ,repr( {err=err_msg} ))
__EOF__

    fi
}

del_lua_script()
{
    /bin/rm -f $tmp_lua
}

run_lua()
{
    $lua $tmp_lua &
}

test_killed()
{

    create_lua_script

    #echo "try: $lua $tmp_lua ..."

    run_lua
    local pid=`ps aux|grep $tmp_lua |grep -v grep | awk {'print $2'}`

    /usr/bin/kill -9 $pid > /dev/null 2>&1

    sleep 3
    #echo "pid is $pid "
    #echo "kill $pid, try $lua $tmp_lua again"

    run_lua
    local ret=$?
    sleep 3
    if [ $ret != 0 ]; then
        #echo "$after kill $tmp_lua, $lua $tmp_lua failed!"
        echo "test_killed failed"
        #del_lua_script
        exit -1
    fi

    #local newpid=`ps aux|grep $tmp_lua |grep -v grep | awk {'print $2'}`
    #echo "after kill $tmp_lua, run $tmp_lua successfully! new pid is $newpid"
    del_lua_script

    echo "test_killed success"
}

test_unlock_with_bad_argument()
{
    local flag='unlock'
    create_lua_script $flag

    $lua $tmp_lua

    local ret=$?

    del_lua_script

    if [ $ret == 0 ]; then
        echo "test_unlock_with_bad_argument failed"
        exit -1
    fi

    echo "test_unlock_with_bad_argument success"
}

test_killed
test_unlock_with_bad_argument
echo " ... OK!"

