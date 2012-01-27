#
# Makefile for proxychains (requires GNU make), stolen from musl
#
# Use config.mak to override any of the following variables.
# Do not make changes here.
#

prefix = /usr/local
includedir = $(prefix)/include
libdir = $(prefix)/lib
confdir = $(prefix)/etc

exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin

SRCS = $(sort $(wildcard src/*.c))
OBJS = $(SRCS:.c=.o)
LOBJS = src/core.o src/libproxychains.o

CCFLAGS  = -Wall -O0 -g -std=c99 -D_GNU_SOURCE -D_BSD_SOURCE -pipe -DTHREAD_SAFE -Werror 
LDFLAGS = -shared -fPIC -ldl -lpthread
INC     = 
PIC     = -fPIC
AR      = $(CROSS_COMPILE)ar
RANLIB  = $(CROSS_COMPILE)ranlib

LDSO_PATHNAME = libproxychains4.so

SHARED_LIBS = $(LDSO_PATHNAME)
ALL_LIBS = $(SHARED_LIBS)
PXCHAINS = proxychains4
ALL_TOOLS = $(PXCHAINS)

-include config.mak

CCFLAGS+=$(USER_CFLAGS)
CFLAGS_MAIN=-DLIB_DIR=\"$(libdir)\"  -DINSTALL_PREFIX=\"$(prefix)\"


all: $(ALL_LIBS) $(ALL_TOOLS)

#install: $(ALL_LIBS:lib/%=$(DESTDIR)$(libdir)/%) $(DESTDIR)$(LDSO_PATHNAME)
install: 
	install -D -m 755 $(ALL_TOOLS) $(bindir)/
	install -D -m 644 $(ALL_LIBS) $(libdir)/
	install -D -m 644 src/proxychains.conf $(confdir)

clean:
	rm -f $(ALL_LIBS)
	rm -f $(ALL_TOOLS)
	rm -f $(OBJS)

%.o: %.c
	$(CC) $(CCFLAGS) $(CFLAGS_MAIN) $(INC) $(PIC) -c -o $@ $<

$(LDSO_PATHNAME): $(LOBJS)
	$(CC) $(LDFLAGS) -Wl,-soname=$(LDSO_PATHNAME) -o $@ $(LOBJS)

$(ALL_TOOLS): $(OBJS)
	$(CC) src/main.o -o $(PXCHAINS)


.PHONY: all clean install
