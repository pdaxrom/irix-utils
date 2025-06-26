#ifndef COMPAT_STDLIB_H
#define COMPAT_STDLIB_H

#pragma push_macro("COMPAT_GETOPT_H")
#undef COMPAT_GETOPT_H
#define COMPAT_GETOPT_H 1
#include_next <stdlib.h>
#pragma pop_macro("COMPAT_GETOPT_H")

#include <compat_strto.h>

int compat_setenv(const char *name, const char *value, int overwrite);
int compat_unsetenv(const char *name);

#define setenv compat_setenv
#define unsetenv compat_unsetenv

char *mkdtemp(char *path);

#define strtof (float)strtod

#endif
