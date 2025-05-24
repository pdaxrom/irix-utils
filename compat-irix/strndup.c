#include <stdlib.h>
#include <string.h>

char *strndup(const char *s, size_t n)
{
    size_t len = strlen(s);
    if (len > n) len = n;

    char *copy = (char *)malloc(len + 1);
    if (!copy) return NULL;

    memcpy(copy, s, len);
    copy[len] = '\0';

    return copy;
}
