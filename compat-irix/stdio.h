#ifndef COMPAT_STDIO_H
#define COMPAT_STDIO_H

#include_next <stdio.h>
#include "compat_snprintf.h"

int isblank(int c);

#endif
