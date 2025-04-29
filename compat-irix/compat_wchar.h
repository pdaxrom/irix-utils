#ifndef COMPAT_UNICODE_H
#define COMPAT_UNICODE_H

#include <stddef.h>
#include <errno.h>

#if defined(__STDC_ISO_10646__) || defined(__GLIBC__) || defined(_WIN32)
#include <wchar.h>
#else /* fallback for old systems (like IRIX 5.3) */
#include_next <wchar.h>

#ifdef __cplusplus
extern "C" {
#endif

int mbsinit(const mbstate_t *ps);

size_t wcrtomb(char *s, wchar_t wc, mbstate_t *ps);
size_t mbrtowc(wchar_t *pwc, const char *s, size_t n, mbstate_t *ps);
size_t mbsrtowcs(wchar_t *dst, const char **src, size_t len, mbstate_t *ps);
size_t wcsrtombs(char *dst, const wchar_t **src, size_t len, mbstate_t *ps);

int wctob(wchar_t wc);
wchar_t btowc(int c);
size_t wcsnlen(const wchar_t *s, size_t n);
wchar_t *wmemcpy(wchar_t *dest, const wchar_t *src, size_t n);
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

#endif /* fallback */

#endif /* COMPAT_UNICODE_H */
