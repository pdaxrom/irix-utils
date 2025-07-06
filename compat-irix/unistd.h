#ifndef COMPAT_UNISTD_H
#define COMPAT_UNISTD_H

#pragma push_macro("DISABLE_COMPAT_GETOPT_LONG")
#define DISABLE_COMPAT_GETOPT_LONG 1
#include_next <unistd.h>
#pragma pop_macro("DISABLE_COMPAT_GETOPT_LONG")

#endif
