OMIT_FRAME_PTR = -fomit-frame-pointer

LUAPKG = lua5.2
CFLAGS = `pkg-config $(LUAPKG) --cflags` -fPIC -O3 -Wall $(OMIT_FRAME_PTR)
# CFLAGS = `pkg-config $(LUAPKG) --cflags` -fPIC -O0 -g3 -Wall
LFLAGS = -shared


## If your system doesn't have pkg-config or if you do not want to get the
## install path from Lua, comment out the previous lines and uncomment and
## change the following ones according to your building environment.

#CFLAGS = -I/usr/local/include/ -fPIC -O3 -Wall $(OMIT_FRAME_PTR)
#LFLAGS = -shared
#INSTALL_PATH = /usr/local/lib/lua/5.2/


all: portlock.so

portlock.lo: portlock.c
	$(CC) -o portlock.lo -c $(CFLAGS) portlock.c

portlock.so: portlock.lo
	$(CC) -o portlock.so $(LFLAGS) $(LIBS) portlock.lo

clean:
	$(RM) *.so *.lo *.o

