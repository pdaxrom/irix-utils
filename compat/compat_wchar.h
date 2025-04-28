#ifndef COMPAT_UNICODE_H
#define COMPAT_UNICODE_H

#include <stddef.h>
#include <errno.h>

/* --- Check if system has good wchar_t support --- */
#if defined(__STDC_ISO_10646__) || defined(__GLIBC__) || defined(_WIN32)

#include <wchar.h>

/* System has native functions: wcrtomb, mbrtowc, mbsrtowcs, wcsrtombs */

#else /* fallback for old systems (like IRIX 5.3) */

#include <wchar.h>

/* Dummy mbstate_t */
/*typedef int mbstate_t; */

/* --- UTF-8 Encoding: wchar_t ➔ multibyte char --- */
static size_t wcrtomb(char *s, wchar_t wc, mbstate_t *ps)
{
    (void)ps;

    if (s == NULL) return 1;

    if ((unsigned int)wc > 0x10FFFF) {
        errno = EILSEQ;
        return (size_t)-1;
    }

    if ((unsigned int)wc <= 0x7F) {
        s[0] = (char)wc;
        return 1;
    } else if ((unsigned int)wc <= 0x7FF) {
        s[0] = (char)(0xC0 | (wc >> 6));
        s[1] = (char)(0x80 | (wc & 0x3F));
        return 2;
    } else if ((unsigned int)wc <= 0xFFFF) {
        s[0] = (char)(0xE0 | (wc >> 12));
        s[1] = (char)(0x80 | ((wc >> 6) & 0x3F));
        s[2] = (char)(0x80 | (wc & 0x3F));
        return 3;
    } else {
        s[0] = (char)(0xF0 | (wc >> 18));
        s[1] = (char)(0x80 | ((wc >> 12) & 0x3F));
        s[2] = (char)(0x80 | ((wc >> 6) & 0x3F));
        s[3] = (char)(0x80 | (wc & 0x3F));
        return 4;
    }
}

/* --- UTF-8 Decoding: multibyte char ➔ wchar_t --- */
static size_t mbrtowc(wchar_t *pwc, const char *s, size_t n, mbstate_t *ps)
{
    (void)ps;

    if (s == NULL) return 0;
    if (n == 0) return (size_t)-2;

    unsigned char c = (unsigned char)s[0];

    if (c <= 0x7F) {
        if (pwc) *pwc = c;
        return (c == '\0') ? 0 : 1;
    } else if ((c & 0xE0) == 0xC0) {
        if (n < 2) return (size_t)-2;
        if ((s[1] & 0xC0) != 0x80) goto ilseq;
        if (pwc) *pwc = ((c & 0x1F) << 6) | (s[1] & 0x3F);
        return 2;
    } else if ((c & 0xF0) == 0xE0) {
        if (n < 3) return (size_t)-2;
        if ((s[1] & 0xC0) != 0x80 || (s[2] & 0xC0) != 0x80) goto ilseq;
        if (pwc) *pwc = ((c & 0x0F) << 12) |
                         ((s[1] & 0x3F) << 6) |
                         (s[2] & 0x3F);
        return 3;
    } else if ((c & 0xF8) == 0xF0) {
        if (n < 4) return (size_t)-2;
        if ((s[1] & 0xC0) != 0x80 ||
            (s[2] & 0xC0) != 0x80 ||
            (s[3] & 0xC0) != 0x80) goto ilseq;
        if (pwc) *pwc = ((c & 0x07) << 18) |
                         ((s[1] & 0x3F) << 12) |
                         ((s[2] & 0x3F) << 6) |
                         (s[3] & 0x3F);
        return 4;
    } else {
ilseq:
        errno = EILSEQ;
        return (size_t)-1;
    }
}

/* --- UTF-8 Decoding: multibyte string ➔ wide string --- */
static size_t mbsrtowcs(wchar_t *dst, const char **src, size_t len, mbstate_t *ps)
{
    const char *s = *src;
    size_t count = 0;

    while (count < len) {
        wchar_t wc;
        size_t bytes = mbrtowc(&wc, s, (size_t)-1, ps);

        if (bytes == (size_t)-1) {
            return (size_t)-1; /* illegal sequence */
        }
        if (bytes == (size_t)-2) {
            return (size_t)-2; /* incomplete sequence */
        }
        if (wc == 0) {
            if (dst) dst[count] = L'\0';
            *src = NULL;
            return count;
        }

        if (dst) dst[count] = wc;
        s += bytes;
        count++;
    }

    *src = s;
    return count;
}

/* --- UTF-8 Encoding: wide string ➔ multibyte string --- */
static size_t wcsrtombs(char *dst, const wchar_t **src, size_t len, mbstate_t *ps)
{
    const wchar_t *s = *src;
    size_t count = 0;

    while (count < len) {
        char buf[4];
        size_t bytes = wcrtomb(buf, *s, ps);

        if (bytes == (size_t)-1) {
            return (size_t)-1; /* illegal character */
        }

        if (*s == L'\0') {
            if (dst) dst[count] = '\0';
            *src = NULL;
            return count;
        }

        if (dst) {
            if (count + bytes > len) {
                /* not enough space */
                break;
            }
            for (size_t i = 0; i < bytes; i++) {
                dst[count++] = buf[i];
            }
        } else {
            count += bytes;
        }

        s++;
    }

    *src = s;
    return count;
}

#ifndef WEOF
#define WEOF ((wchar_t)-1)
#endif

/* --- Single wide char � single byte --- */
static int wctob(wchar_t wc)
{
    if ((unsigned int)wc <= 0xFF) {
        return (int)(unsigned char)wc;
    } else {
        return EOF;
    }
}

/* --- Single byte � single wide char --- */
static wchar_t btowc(int c)
{
    if (c == EOF) {
        return WEOF;
    }

    unsigned char uc = (unsigned char)c;
    return (wchar_t)uc;
}

/* --- Return the length of a wide string (up to n characters) --- */
static size_t wcsnlen(const wchar_t *s, size_t n)
{
    size_t count = 0;

    while (count < n && s[count] != L'\0') {
        count++;
    }

    return count;
}

/* --- Copy n wide characters --- */
static void *wmemcpy(void *dest, const void *src, size_t n)
{
    wchar_t *d = (wchar_t *)dest;
    const wchar_t *s = (const wchar_t *)src;

    for (size_t i = 0; i < n; i++) {
        d[i] = s[i];
    }

    return dest;
}

#if 0
/* --- Check if mbstate_t is "initial" --- */
static int mbsinit(const mbstate_t *ps)
{
    /* In our fallback, mbstate_t is always int 0 = initial */
    return (ps == NULL || *ps == 0);
}

/* --- Count characters by decoding --- */
static size_t mbslen(const char *s)
{
    size_t len = 0;
    mbstate_t state = 0;
    wchar_t wc;
    size_t bytes;

    while (*s) {
        bytes = mbrtowc(&wc, s, (size_t)-1, &state);

        if (bytes == (size_t)-1 || bytes == (size_t)-2) {
            /* Bad sequence: stop */
            break;
        }

        s += bytes;
        len++;
    }

    return len;
}

/* --- Fast UTF-8 character count without decoding --- */
static size_t utf8_strlen(const char *s)
{
    size_t count = 0;

    while (*s) {
        unsigned char c = (unsigned char)*s;

        if ((c & 0xC0) != 0x80) {
            /* Not a continuation byte = start of new character */
            count++;
        }
        s++;
    }

    return count;
}

/* --- Validate UTF-8 string --- */
static int utf8_validate(const char *s)
{
    while (*s) {
        unsigned char c = (unsigned char)*s;

        if (c <= 0x7F) {
            /* ASCII */
            s++;
        } else if ((c & 0xE0) == 0xC0) {
            /* 2-byte */
            if ((s[1] & 0xC0) != 0x80) return 0;
            s += 2;
        } else if ((c & 0xF0) == 0xE0) {
            /* 3-byte */
            if ((s[1] & 0xC0) != 0x80 || (s[2] & 0xC0) != 0x80) return 0;
            s += 3;
        } else if ((c & 0xF8) == 0xF0) {
            /* 4-byte */
            if ((s[1] & 0xC0) != 0x80 ||
                (s[2] & 0xC0) != 0x80 ||
                (s[3] & 0xC0) != 0x80) return 0;
            s += 4;
        } else {
            /* Invalid byte */
            return 0;
        }
    }
    return 1;
}
#endif

#endif /* fallback */

#endif /* COMPAT_UNICODE_H */
