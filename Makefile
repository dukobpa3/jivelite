# Jivelite makefile

# set PREFIX for location of luajit include and libs
PREFIX ?= /usr/local

LUAJIT_VERSION = 2.1
export LUAJIT_VERSION
CFLAGS += -DLUAJIT_VERSION=21
export CFLAGS

all: srcs libs

srcs:
	cd src; PREFIX=$(PREFIX) make

libs: lib

lib:
	cd lib-src; PREFIX=$(PREFIX) make

clean:
	rm -Rf lib
	cd src; make clean
	cd lib-src; make clean

