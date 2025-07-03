#ifndef COMPAT_STDIO_H
#define COMPAT_STDIO_H

#include <compat_config.h>

#include <sys/types.h>

#pragma push_macro("DISABLE_COMPAT_GETOPT_LONG")
#define DISABLE_COMPAT_GETOPT_LONG 1
#include_next <stdio.h>
#pragma pop_macro("DISABLE_COMPAT_GETOPT_LONG")

#include <compat_snprintf.h>

#ifndef COMPAT_IRIX_65
int isblank(int c);
#endif

#define ftello(fp) (off_t) ftell(fp)

#undef fileno

int fileno(FILE *stream);

#endif
