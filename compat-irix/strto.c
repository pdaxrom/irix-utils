#include <stdlib.h>
#include <errno.h>
#include <limits.h>

#include "compat_strto.h"

intmax_t strtoimax(const char *nptr, char **endptr, int base)
{
#if defined(HAVE_STRTOLL)
    return strtoll(nptr, endptr, base);
#else
    long result = strtol(nptr, endptr, base);
    if (result == LONG_MAX && errno == ERANGE)
        return (intmax_t)LONG_MAX;
    if (result == LONG_MIN && errno == ERANGE)
        return (intmax_t)LONG_MIN;
    return (intmax_t)result;
#endif
}

uintmax_t strtoumax(const char *nptr, char **endptr, int base)
{
#if defined(HAVE_STRTOULL)
    return strtoull(nptr, endptr, base);
#else
    unsigned long result = strtoul(nptr, endptr, base);
    if (result == ULONG_MAX && errno == ERANGE)
        return (uintmax_t)ULONG_MAX;
    return (uintmax_t)result;
#endif
}
