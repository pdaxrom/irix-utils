// Copyright (C) 2019 Miroslaw Toton, mirtoto@gmail.com
#ifndef SNPRINTF_H_
#define SNPRINTF_H_

#include <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif

int vsnprintf(char *, size_t, const char *, va_list);
int snprintf(char *, size_t, const char *, ...);
int vasprintf(char **, const char *, va_list);
int asprintf(char **, const char *, ...);

#ifdef __cplusplus
}
#endif

#endif  // SNPRINTF_H_
