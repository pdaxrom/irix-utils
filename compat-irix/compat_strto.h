#ifndef COMPAT_STRTO_H
#define COMPAT_STRTO_H

#include <inttypes.h>

//#ifdef __cplusplus
//extern "C" {
//#endif

extern intmax_t strtoimax(const char *nptr, char **endptr, int base);
extern uintmax_t strtoumax(const char *nptr, char **endptr, int base);

//#ifdef __cplusplus
//}
//#endif

#endif
