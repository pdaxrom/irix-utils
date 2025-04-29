#ifndef COMPAT_GETOPT_LONG_H
#define COMPAT_GETOPT_LONG_H

#define no_argument		0
#define required_argument	1
#define optional_argument	2

#ifdef __cplusplus
extern "C" {
#endif

struct option {
    /* name of long option */
    const char *name;
    /*
     * one of no_argument, required_argument, and optional_argument:
     * whether option takes an argument
     */
    int has_arg;
    /* if not NULL, set *flag to val when option found */
    int *flag;
    /* if flag not NULL, value to set *flag to; else return value */
    int val;
};

extern int optreset;

int compat_getopt(int nargc, char * const *nargv, const char *options);

int getopt_long(int nargc, char * const *nargv, const char *options,
    const struct option *long_options, int *idx);

int getopt_long_only(int nargc, char * const *nargv, const char *options,
    const struct option *long_options, int *idx);

#ifdef __cplusplus
}
#endif

#endif
