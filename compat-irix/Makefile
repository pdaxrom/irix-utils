VERSION = .0.1
LIBNAME = libcompat_irix
SHARED_SUFFIX = .so
STATIC_SUFFIX = .a
TARGET = $(LIBNAME)$(SHARED_SUFFIX)$(VERSION)

all: $(TARGET)

CC = $(CROSS)gcc
AR = $(CROSS)ar
RANLIB = $(CROSS)ranlib

CFLAGS = -O2 -DSTANDALONE

OBJS = compat_wchar.o snprintf.o getopt_long.o inet.o strto.o

$(TARGET): $(OBJS)
	$(CC) -shared -o $@ $^ -lm
	$(AR) rcs $(LIBNAME)$(STATIC_SUFFIX) $^

clean:
	rm -f $(TARGET) $(OBJS) $(LIBNAME)$(STATIC_SUFFIX)

ifneq (,$(PREFIX))
install: all
	mkdir -p $(PREFIX)/include/arpa $(PREFIX)/include/sys  $(PREFIX)/lib
	cp -f compat_wchar.h compat_snprintf.h getopt_long.h getopt.h stdbool.h \
	    stdio.h complex.h $(PREFIX)/include
	cp  compat_strto.h stdlib.h $(PREFIX)/include
	cp -f inet.h $(PREFIX)/include/arpa
	cp -f types.h $(PREFIX)/include/sys
	ln -sf compat_wchar.h $(PREFIX)/include/wchar.h
	cp -f $(LIBNAME)$(STATIC_SUFFIX) $(PREFIX)/lib/
	cp -f $(TARGET) $(PREFIX)/lib/
	ln -sf $(TARGET) $(PREFIX)/lib/$(LIBNAME)$(SHARED_SUFFIX)
endif
