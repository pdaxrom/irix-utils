#ifndef COMPAT_INTERNAL_TYPES_H
#define COMPAT_INTERNAL_TYPES_H

#include <sys/types.h>

/* Форсированное определение socklen_t для IRIX */
#ifndef COMPAT_SOCKLEN_T_DEFINED
typedef int socklen_t;
#define COMPAT_SOCKLEN_T_DEFINED
#define HAVE_SOCKLEN_T 1
#define _SOCKLEN_T 1
#define _SOCKLEN_T_DECLARED 1
#endif

#endif
