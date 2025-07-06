#ifdef DISABLE_COMPAT_GETOPT_LONG

#include_next <getopt.h>

#else
# ifndef COMPAT_GETOPT_H
# define COMPAT_GETOPT_H

#include_next <getopt.h>
#include <getopt_long.h>

# endif
#endif
