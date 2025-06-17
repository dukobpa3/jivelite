# Makefile for lua libs used by jivelite
# NB - repo has modified paths which assume use of luajit2.0 from source

TARGET   ?= linux
LUAINC   ?= $(PREFIX)/include
LD_FLAGS ?= "-shared"

LIBS = cjson luaexpat luafilesystem luamd5 luasocket luazipfilter irbsp

all: $(LIBS)

cjson:
	$(MAKE) -C lua-cjson-2.1.0 LUA_INCLUDE_DIR=$(LUAINC) CJSON_LDFLAGS="$(LD_FLAGS)"
	mkdir -p $(PREFIX)/lib/lua/5.1
	cp lua-cjson-2.1.0/cjson.so $(PREFIX)/lib/lua/5.1/cjson.so

luaexpat:
	$(MAKE) -C luaexpat-1.2.0 LUA_INC=$(LUAINC) LIB_OPTION="$(LD_FLAGS)"
	mkdir -p $(PREFIX)/lib/lua/5.1
	cp luaexpat-1.2.0/src/lxp.so.1.2.0 $(PREFIX)/lib/lua/5.1/lxp.so

luafilesystem:
	$(MAKE) -C luafilesystem-1.6.2 LUA_INC=$(LUAINC) LIB_OPTION="$(LD_FLAGS)"
	mkdir -p $(PREFIX)/lib/lua/5.1
	cp luafilesystem-1.6.2/src/lfs.so $(PREFIX)/lib/lua/5.1/lfs.so	

luamd5:
	$(MAKE) -C luamd5 LUAINC=$(LUAINC) MYNAME=sha1 MYLDFLAGS="$(LD_FLAGS)"
	$(MAKE) -C luamd5 LUAINC=$(LUAINC) MYNAME=md5 MYLDFLAGS="$(LD_FLAGS)"
	mkdir -p $(PREFIX)/lib/lua/5.1
	cp luamd5/md5.so $(PREFIX)/lib/lua/5.1/
	cp luamd5/sha1.so $(PREFIX)/lib/lua/5.1/

luasocket:
	$(MAKE) -C luasocket-2.0.2 LD="gcc" PLATFORM=${TARGET} LUAINC=$(LUAINC) USE_LUAJIT=$(USE_LUAJIT)
	mkdir -p $(PREFIX)/lib/lua/5.1
	cp luasocket-2.0.2/src/socket.so.2.0.2 $(PREFIX)/lib/lua/5.1/socket.so
	cp luasocket-2.0.2/src/mime.so.1.0.2 $(PREFIX)/lib/lua/5.1/mime.so

luazipfilter:
	$(MAKE) -C luazipfilter LUAINC=$(LUAINC) MYLDFLAGS="$(LD_FLAGS)"
	mkdir -p $(PREFIX)/lib/lua/5.1
	cp luazipfilter/zipfilter.so $(PREFIX)/lib/lua/5.1/

irbsp:
	$(MAKE) -C lirc-bsp LUAINC=$(LUAINC) -f Makefile.jivelite
	mkdir -p $(PREFIX)/lib/lua/5.1
	cp lirc-bsp/ir_bsp.so $(PREFIX)/lib/lua/5.1/

clean:
	-$(MAKE) -C lua-cjson-2.1.0 clean
	-$(MAKE) -C luaexpat-1.2.0 clean
	-$(MAKE) -C luafilesystem-1.6.2 clean
	-$(MAKE) -C luamd5 MYNAME=sha1 clean
	-$(MAKE) -C luamd5 MYNAME=md5 clean
	-$(MAKE) -C luasocket-2.0.2 PLATFORM=${TARGET} clean
	-$(MAKE) -C luazipfilter clean
	-$(MAKE) -C lirc-bsp -f Makefile.jivelite clean

.PHONY: all cjson luaexpat luafilesystem luamd5 luasocket luazipfilter irbsp clean

