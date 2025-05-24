#ifndef COMPAT_WCHAR_H
#define COMPAT_WCHAR_H

#include <compat_config.h>

#include <stddef.h>
#include <errno.h>

#include_next <wchar.h>

#ifdef __cplusplus
extern "C" {
#endif

int mbsinit(const mbstate_t *ps);
void mbszero(mbstate_t *ps) __attribute__((weak));

size_t wcrtomb(char *s, wchar_t wc, mbstate_t *ps);
size_t mbrtowc(wchar_t *pwc, const char *s, size_t n, mbstate_t *ps);
size_t mbsrtowcs(wchar_t *dst, const char **src, size_t len, mbstate_t *ps);
size_t wcsrtombs(char *dst, const wchar_t **src, size_t len, mbstate_t *ps);

#ifndef COMPAT_IRIX_65
int wctob(wchar_t wc);
wchar_t btowc(int c);
#endif

size_t wcsnlen(const wchar_t *s, size_t n);
wchar_t *wmemcpy(wchar_t *dest, const wchar_t *src, size_t n);
wchar_t *wmempcpy(wchar_t *dest, const wchar_t *src, size_t n);
wchar_t *wmemchr(const wchar_t *s, wchar_t c, size_t n);

size_t mbrlen(const char *s, size_t n, mbstate_t *ps);
int mbscmp(const char *s1, const char *s2);
int mbscasecmp(const char *s1, const char *s2);
size_t mbsnrtowcs(wchar_t *dst, const char **src, size_t n, size_t len, mbstate_t *ps);
char *mbschr(const char *s, int c);
wchar_t *wcsdup(const wchar_t *s);

//int wcwidth(wchar_t wc);
//int iswupper(wchar_t wc);
//int iswlower(wchar_t wc);
//wchar_t towupper(wchar_t wc);
//wchar_t towlower(wchar_t wc);
//int iswalpha(wchar_t wc);
//int iswdigit(wchar_t wc);
//int iswalnum(wchar_t wc);

#ifdef __cplusplus
}
#endif

#endif /* COMPAT_WCHAR_H */
