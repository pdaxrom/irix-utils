#ifndef COMPAT_STRING_H
#define COMPAT_STRING_H

#include_next <string.h>

char *strndup(const char *s, size_t n);
void *memmem(const void *haystack, size_t haystacklen, const void *needle, size_t needlelen);

#endif
