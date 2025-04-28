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
#	$(AR) rcs $@ $(OBJS)
#	$(RANLIB) $@

clean:
	rm -f $(TARGET) $(OBJS)

ifneq (,$(PREFIX))
install: all
	cp -f compat_wchar.h $(PREFIX)/include
#	cp -f $(TARGET) $(PREFIX)/lib/
	cp -f $(TARGET) $(PREFIX)/lib/
	ln -sf $(TARGET) $(PREFIX)/lib/$(LIBNAME)
endif
