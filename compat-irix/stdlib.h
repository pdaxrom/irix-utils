#ifndef COMPAT_STDLIB_H
#define COMPAT_STDLIB_H

#include_next "stdlib.h"

#include "compat_strto.h"

int compat_setenv(const char *name, const char *value, int overwrite);

#define setenv compat_setenv

#endif
