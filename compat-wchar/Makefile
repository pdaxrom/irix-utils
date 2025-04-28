VERSION = .0.1
LIBNAME = libcompat_wchar.so
TARGET = $(LIBNAME)$(VERSION)

all: $(TARGET)

CC = $(CROSS)gcc
AR = $(CROSS)ar
RANLIB = $(CROSS)ranlib

CFLAGS = -O2

OBJS = compat_wchar.o

$(TARGET): $(OBJS)
	$(CC) -shared -o $@ $^
	$(AR) rcs libcompat_wchar.a $^

clean:
	rm -f $(TARGET) $(OBJS)

ifneq (,$(PREFIX))
install: all
	mkdir -p $(PREFIX)/include $(PREFIX)/lib
	cp -f compat_wchar.h $(PREFIX)/include
	ln -sf compat_wchar.h $(PREFIX)/include/wchar.h
	cp -f libcompat_wchar.a $(PREFIX)/lib/
	cp -f $(TARGET) $(PREFIX)/lib/
	ln -sf $(TARGET) $(PREFIX)/lib/$(LIBNAME)
#	cp -f stdbool.h $(PREFIX)/include
endif
