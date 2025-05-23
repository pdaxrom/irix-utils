#ifndef COMPAT_STDIO_H
#define COMPAT_STDIO_H

#include <compat_config.h>

#include_next <stdio.h>
#include <compat_snprintf.h>

#ifndef COMPAT_IRIX_65
int isblank(int c);
#endif

#endif
