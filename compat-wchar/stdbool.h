#ifndef _STDBOOL_H_
#define _STDBOOL_H_

#if __STDC_VERSION__ >= 199901L
#include <stdbool.h>
#else
typedef unsigned char bool;
#define true  1
#define false 0
#define __bool_true_false_are_defined 1
#endif

#endif /* _STDBOOL_H_ */
