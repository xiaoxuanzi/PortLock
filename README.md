# PortLock

Cross process lock on linux, make sure one process executes only in one instance at a time

## Description
* Source code is written by C, but used for Lua
* Create a dynamic library called protlock.so
* Load protlock.so directly from within Lua

##How to use
* make
  Create protlock.so
* example
<pre><code>
    local portlock = require("portlock")

    local lockname = "portlock"
    local sock, err_msg = portlock.lock_port(lockname)

    --Do What You Love

    local ret, err_msg = portlock.unlock_port(sock)
</pre></code>
* For more unit testing ,please refer to [test](test)


