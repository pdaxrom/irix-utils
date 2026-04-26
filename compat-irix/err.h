#ifndef COMPAT_ERR_H
#define COMPAT_ERR_H

#include <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif

void warn(const char *fmt, ...);
void warnx(const char *fmt, ...);

void err(int eval, const char *fmt, ...);
void errx(int eval, const char *fmt, ...);

#ifdef __cplusplus
}
#endif

#endif
