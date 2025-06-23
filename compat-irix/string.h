#ifndef COMPAT_STRING_H
#define COMPAT_STRING_H

#include_next <string.h>

char *strndup(const char *s, size_t n);
void *memmem(const void *haystack, size_t haystacklen, const void *needle, size_t needlelen);

size_t strlcpy(char *dst, const char *src, size_t size);

char *strcasestr(const char *haystack, const char *needle);

#endif
