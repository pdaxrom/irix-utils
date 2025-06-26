#ifndef COMPAT_UNISTD_H
#define COMPAT_UNISTD_H

#pragma push_macro("COMPAT_GETOPT_H")
#undef COMPAT_GETOPT_H
#define COMPAT_GETOPT_H 1
#include_next <unistd.h>
#pragma pop_macro("COMPAT_GETOPT_H")

#endif
