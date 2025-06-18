# Jivelite makefile

# Default build parameters (can be overridden from command line)
PREFIX ?= /usr/local
USE_LUAJIT ?= false
PCP_BUILD ?= false

# --- Setup Build Flags ---
# Define Lua include path and library name based on the selected variant
ifeq ($(USE_LUAJIT),true)
	LUAINC := $(PREFIX)/include/luajit-2.1
	LUA_CFLAGS := -DLUAJIT_VERSION=21
	LUA_LDFLAGS := -lluajit-5.1
else
	LUAINC := $(PREFIX)/include
	LUA_CFLAGS :=
	LUA_LDFLAGS := -llua
endif

# Base CFLAGS and LDFLAGS that will be passed to sub-makefiles
# SDL headers must be on the include path.
# The linker needs to know where to find libs.
EXTRA_CFLAGS := -I$(PREFIX)/include/SDL $(LUA_CFLAGS)
EXTRA_LDFLAGS := -L$(PREFIX)/lib $(LUA_LDFLAGS)

# Add the jivelite-specific -DOPTJIVELITE flag for pCP builds
ifeq ($(PCP_BUILD),true)
	EXTRA_CFLAGS += -DOPTJIVELITE
endif

all: srcs libs

srcs:
	$(MAKE) -C src PREFIX=$(PREFIX) PARENT_LDFLAGS="$(EXTRA_LDFLAGS)" PARENT_CFLAGS="$(EXTRA_CFLAGS)" LUAINC=$(LUAINC)

libs: lib

lib:
	$(MAKE) -C lib-src PREFIX=$(PREFIX) PARENT_LDFLAGS="$(EXTRA_LDFLAGS)" PARENT_CFLAGS="$(EXTRA_CFLAGS)" LUAINC=$(LUAINC)

clean:
	rm -Rf lib
	$(MAKE) -C src clean
	$(MAKE) -C lib-src clean

