#ifndef _STDBOOL_H_
#define _STDBOOL_H_

#ifdef __cplusplus
extern "C" {
#endif


#ifndef __cplusplus
typedef unsigned char bool;
#define true  1
#define false 0
#define __bool_true_false_are_defined 1
#endif

#ifdef __cplusplus
}
#endif

#endif /* _STDBOOL_H_ */
