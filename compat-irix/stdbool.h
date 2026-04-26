#ifndef _STDBOOL_H_
#define _STDBOOL_H_

#ifndef __cplusplus
#if !defined(__bool_true_false_are_defined)
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 202311L
/* bool, true and false are keywords in C23 */
#else
#define bool unsigned char
#define true 1
#define false 0
#endif
#define __bool_true_false_are_defined 1
#endif
#endif

#endif /* _STDBOOL_H_ */
