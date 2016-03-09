local portlock = require("portlock")
local tableutil = require("tableutil")
local repr = tableutil.repr

function unlock_after_invalid_test( sock )
    local ret, err_msg = portlock.unlock_port(sock)
    assert( ret == nil ,repr( {err=err_msg} ))
end

function test_success()

    local sock, err_msg = portlock.lock_port("portlock")
    assert( sock ~= nil, repr( {err=err_msg} ) )

    local ret, err_msg = portlock.unlock_port(sock)
    assert( ret == nil ,repr( {err=err_msg} ))

end

function test_lock_without_param()

    local sock, err_msg = portlock.lock_port()
    assert( err_msg ~= nil, repr( {err=err_msg} ) )

end

function test_lock_invalid_param()

    local sock, err_msg = portlock.lock_port("test1","test2")
    assert( err_msg ~= nil, repr( {err=err_msg} ) )
end

function test_unlock_without_param()

    local sock, err_msg = portlock.lock_port("portlock")
    assert( sock ~= nil, repr( {err=err_msg} ) )

    local ret, err_msg = portlock.unlock_port()
    assert( ret == nil ,repr( {err=err_msg} ))

    unlock_after_invalid_test( sock )

end

function test_unlock_invalid_param()

    local sock, err_msg = portlock.lock_port("portlock")
    --print(sock, err_msg)
    assert( sock ~= nil, repr( {err=err_msg} ) )

    local ret, err_msg = portlock.unlock_port( sock + 1 )
    --print(ret, err_msg)
    assert( ret ~= nil ,repr( {err=err_msg} ))

    unlock_after_invalid_test( sock )

end

function test_bind_in_use_address()

    local sock_1
    local sock_2
    local err_msg

    sock_1, err_msg = portlock.lock_port("portlock")
    --print(sock, err_msg)
    assert( sock_1 ~= nil, repr( {err=err_msg} ) )

    sock_2, err_msg = portlock.lock_port("portlock")
    --print(sock, err_msg)
    assert( sock_2 == nil, repr( {err=err_msg} ) )

    unlock_after_invalid_test( sock_1 )

end

test_success()
test_lock_without_param()
test_lock_invalid_param()
test_unlock_without_param()
test_unlock_invalid_param()
test_bind_in_use_address()

print("... OK!")
