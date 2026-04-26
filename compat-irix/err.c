#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>
#include "err.h"

void warn(const char *fmt, ...)
{
    va_list ap;
    int old_errno = errno;
    fprintf(stderr, "Warning: ");
    if (fmt) {
        va_start(ap, fmt);
        vfprintf(stderr, fmt, ap);
        va_end(ap);
        fprintf(stderr, ": ");
    }
    fprintf(stderr, "%s\n", strerror(old_errno));
}

void warnx(const char *fmt, ...)
{
    va_list ap;
    fprintf(stderr, "Warning: ");
    if (fmt) {
        va_start(ap, fmt);
        vfprintf(stderr, fmt, ap);
        va_end(ap);
    }
    fprintf(stderr, "\n");
}

void err(int eval, const char *fmt, ...)
{
    va_list ap;
    int old_errno = errno;
    fprintf(stderr, "Error: ");
    if (fmt) {
        va_start(ap, fmt);
        vfprintf(stderr, fmt, ap);
        va_end(ap);
        fprintf(stderr, ": ");
    }
    fprintf(stderr, "%s\n", strerror(old_errno));
    exit(eval);
}

void errx(int eval, const char *fmt, ...)
{
    va_list ap;
    fprintf(stderr, "Error: ");
    if (fmt) {
        va_start(ap, fmt);
        vfprintf(stderr, fmt, ap);
        va_end(ap);
    }
    fprintf(stderr, "\n");
    exit(eval);
}
