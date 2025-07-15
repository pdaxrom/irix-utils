#ifndef COMPAT_STDLIB_H
#define COMPAT_STDLIB_H

#pragma push_macro("DISABLE_COMPAT_GETOPT_LONG")
#define DISABLE_COMPAT_GETOPT_LONG 1
#include_next <stdlib.h>
#pragma pop_macro("DISABLE_COMPAT_GETOPT_LONG")

#ifdef __cplusplus
extern "C" {
#endif

int compat_setenv(const char *name, const char *value, int overwrite);
int compat_unsetenv(const char *name);

#define setenv compat_setenv
#define unsetenv compat_unsetenv

char *mkdtemp(char *path);

#define strtof (float)strtod

#ifdef __cplusplus
}
#endif

#endif
