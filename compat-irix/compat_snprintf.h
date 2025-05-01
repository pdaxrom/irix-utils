// Copyright (C) 2019 Miroslaw Toton, mirtoto@gmail.com
#ifndef SNPRINTF_H_
#define SNPRINTF_H_

#include <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif

int rpl_vsnprintf(char *, size_t, const char *, va_list);
int rpl_snprintf(char *, size_t, const char *, ...);
int rpl_vasprintf(char **, const char *, va_list);
int rpl_asprintf(char **, const char *, ...);

#define vsnprintf rpl_vsnprintf
#define snprintf rpl_snprintf
#define vasprintf rpl_vasprintf
#define asprintf rpl_asprintf

#ifdef __cplusplus
}
#endif

#endif  // SNPRINTF_H_
