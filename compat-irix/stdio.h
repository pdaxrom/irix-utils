#ifndef COMPAT_STDIO_H
#define COMPAT_STDIO_H

#include <compat_config.h>

#include <sys/types.h>

#pragma push_macro("COMPAT_GETOPT_H")
#undef COMPAT_GETOPT_H
#define COMPAT_GETOPT_H 1
#include_next <stdio.h>
#pragma pop_macro("COMPAT_GETOPT_H")

#include <compat_snprintf.h>

#ifndef COMPAT_IRIX_65
int isblank(int c);
#endif

#define ftello(fp) (off_t) ftell(fp)

#undef fileno

int fileno(FILE *stream);

#endif
