VERSION = .0.1
LIBNAME = libcompat_irix
SHARED_SUFFIX = .so
STATIC_SUFFIX = .a
TARGET = $(LIBNAME)$(SHARED_SUFFIX)$(VERSION)

LIBDIR = $(PREFIX)/lib

all: $(TARGET)

CC = $(CROSS)gcc
AR = $(CROSS)ar
RANLIB = $(CROSS)ranlib

CFLAGS = -O2 -DSTANDALONE -I.

ifeq (6.5,$(IRIX_VERSION))
else
endif

OBJS = compat_wchar.o snprintf.o getopt_long.o inet.o strto.o strlcpy.o strcasestr.o setenv.o strndup.o memmem.o netdb.o mkdtemp.o getline.o

$(TARGET): compat_config.h $(OBJS)
	$(CC) -shared -o $@ $^ -lm
	$(AR) rcs $(LIBNAME)$(STATIC_SUFFIX) $^

compat_config.h:
ifeq (6.5,$(IRIX_VERSION))
	echo "#ifndef COMPAT_CONFIG_H\n#define COMPAT_CONFIG_H\n#define COMPAT_IRIX_65\n#endif" > compat_config.h
else
	echo "#ifndef COMPAT_CONFIG_H\n#define COMPAT_CONFIG_H\n#define COMPAT_IRIX_53\n#endif" > compat_config.h
endif

clean:
	rm -f $(TARGET) $(OBJS) $(LIBNAME)$(STATIC_SUFFIX) compat_config.h

ifneq (,$(PREFIX))
install: all
	mkdir -p $(PREFIX)/include/arpa $(PREFIX)/include/sys  $(LIBDIR)
	cp -f wchar.h compat_snprintf.h getopt_long.h getopt.h stdbool.h \
	    stdio.h complex.h netdb.h resolv.h compat_config.h $(PREFIX)/include
	cp  compat_strto.h stdlib.h inttypes.h string.h stddef.h unistd.h $(PREFIX)/include
	cp -f inet.h $(PREFIX)/include/arpa
	cp -f types.h socket.h $(PREFIX)/include/sys
	cp -f $(LIBNAME)$(STATIC_SUFFIX) $(LIBDIR)/
	cp -f $(TARGET) $(LIBDIR)/
	ln -sf $(TARGET) $(LIBDIR)/$(LIBNAME)$(SHARED_SUFFIX)
endif
