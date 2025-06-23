#ifndef COMPAT_GETOPT_H
#define COMPAT_GETOPT_H

#include_next <getopt.h>

#ifndef DISABLE_COMPAT_GETOPT_LONG
#include <getopt_long.h>
#endif

#endif
