#ifndef COMPAT_INET_H
#define COMPAT_INET_H

#include_next <arpa/inet.h>

#include <compat_config.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifndef INET_ADDRSTRLEN
#define INET_ADDRSTRLEN 16
#endif

int inet_pton(int af, const char *src, void *dst);

#ifndef COMPAT_IRIX_65
const char *inet_ntop(int af, const void *src, char *dst, socklen_t size);
#endif

#ifdef __cplusplus
}
#endif

#endif
