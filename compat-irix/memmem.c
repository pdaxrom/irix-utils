#include <string.h>

void *memmem(const void *haystack, size_t haystacklen, const void *needle, size_t needlelen)
{
    if (needlelen == 0)
        return (void *)haystack;

    if (haystacklen < needlelen)
        return NULL;

    const unsigned char *h = (const unsigned char *)haystack;
    const unsigned char *n = (const unsigned char *)needle;

    for (size_t i = 0; i <= haystacklen - needlelen; ++i) {
        if (h[i] == n[0] && memcmp(h + i, n, needlelen) == 0)
            return (void *)(h + i);
    }

    return NULL;
}
