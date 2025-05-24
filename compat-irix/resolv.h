#ifndef COMPAT_RESOLV_H
#define COMPAT_RESOLV_H

#include <compat_config.h>

#include_next <resolv.h>

#ifndef COMPAT_IRIX_65

const char *inet_ntop(int af, const void *src, char *dst, socklen_t size);

#if 0
int __b64_ntop(u_char const *src, size_t srclength, char *target, size_t targsize);
int __b64_pton (char const *src, u_char *target, size_t targsize);
#define b64_pton __b64_pton
#define b64_ntop __b64_ntop
#endif
#endif

#endif
