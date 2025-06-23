#ifndef COMPAT_STDLIB_H
#define COMPAT_STDLIB_H

#include_next <stdlib.h>

#include <compat_strto.h>

int compat_setenv(const char *name, const char *value, int overwrite);
int compat_unsetenv(const char *name);

#define setenv compat_setenv
#define unsetenv compat_unsetenv

char *mkdtemp(char *path);

#define strtof (float)strtod

#endif
