#include <stddef.h>

size_t
strlcpy(char *dst, const char *src, size_t size)
{
    const char *s = src;
    size_t left = size;

    if (left != 0) {
        while (--left != 0) {
            if ((*dst++ = *s++) == '\0')
                break;
        }
    }

    if (left == 0) {
        if (size != 0)
            *dst = '\0';  // null-terminate
        while (*s++)      // traverse to end of src
            ;
    }

    return s - src - 1;   // length of src
}
