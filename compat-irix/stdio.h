#ifndef COMPAT_STDIO_H
#define COMPAT_STDIO_H

#include <compat_config.h>

#include <sys/types.h>
#include_next <stdio.h>
#include <compat_snprintf.h>

#ifndef COMPAT_IRIX_65
int isblank(int c);
#endif

#define ftello(fp) (off_t) ftell(fp)

#undef fileno

int fileno(FILE *stream);

#endif
