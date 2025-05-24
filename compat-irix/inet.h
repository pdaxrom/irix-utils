#ifndef COMPAT_INET_H
#define COMPAT_INET_H

#include_next <arpa/inet.h>

#ifdef __cplusplus
extern "C" {
#endif

int inet_pton(int af, const char *src, void *dst);

#ifdef __cplusplus
}
#endif

#endif
