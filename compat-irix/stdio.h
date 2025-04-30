#ifndef COMPAT_STDIO_H
#define COMPAT_STDIO_H

#include_next <stdio.h>
#include "compat_snprintf.h"

#define vsnprintf _compat_vsnprintf
#define snprintf _compat_snprintf

int isblank(int c);

#endif
