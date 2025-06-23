#ifndef COMPAT_STDDEF_H
#define COMPAT_STDDEF_H

#include_next <stddef.h>

#ifndef SIZE_MAX
#define SIZE_MAX ((size_t)-1)
#endif

#endif
