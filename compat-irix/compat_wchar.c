#ifndef COMPAT_UNICODE_H
#define COMPAT_UNICODE_H

#include <stddef.h>
#include <errno.h>

#if defined(__STDC_ISO_10646__) || defined(__GLIBC__) || defined(_WIN32)

#include <wchar.h>

#else
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#include <wchar.h>

#ifndef COMPAT_IRIX_65
int isblank(int c)
{
    return c == ' ' || c == '\t';
}
#endif

int mbsinit(const mbstate_t *ps)
{
    return (ps == NULL || *ps == 0);
}

void mbszero(mbstate_t *ps)
{
    mbsinit(ps);
}

size_t wcrtomb(char *s, wchar_t wc, mbstate_t *ps)
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

size_t mbrtowc(wchar_t *pwc, const char *s, size_t n, mbstate_t *ps)
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

size_t mbsrtowcs(wchar_t *dst, const char **src, size_t len, mbstate_t *ps)
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

size_t wcsrtombs(char *dst, const wchar_t **src, size_t len, mbstate_t *ps)
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

#ifndef COMPAT_IRIX_65
int wctob(wchar_t wc)
{
    if ((unsigned int)wc <= 0xFF) {
        return (int)(unsigned char)wc;
    } else {
        return EOF;
    }
}

wchar_t btowc(int c)
{
    if (c == EOF) {
        return WEOF;
    }

    unsigned char uc = (unsigned char)c;
    return (wchar_t)uc;
}
#endif

size_t wcsnlen(const wchar_t *s, size_t n)
{
    size_t count = 0;

    while (count < n && s[count] != L'\0') {
        count++;
    }

    return count;
}

wchar_t *wmemcpy(wchar_t *dest, const wchar_t *src, size_t n)
{
    for (size_t i = 0; i < n; i++) {
        dest[i] = src[i];
    }

    return dest;
}

wchar_t *wmempcpy(wchar_t *dest, const wchar_t *src, size_t n)
{
    return (wchar_t *)wmemcpy(dest, src, n) + n;
}

wchar_t *wmemchr(const wchar_t *s, wchar_t c, size_t n)
{
    for (size_t i = 0; i < n; i++) {
        if (s[i] == c) {
            return (wchar_t *)(s + i);
        }
    }
    return NULL;
}

size_t mbrlen(const char *s, size_t n, mbstate_t *ps)
{
    if (s == NULL || n == 0) {
        return 0;  // Empty or null string
    }

    unsigned char c = (unsigned char)*s;
    size_t len = 1;  // Default to 1 byte (ASCII or first byte of multi-byte)

    /* Handle ASCII (single byte) */
    if (c <= 0x7F) {
        return len;
    }

    /* UTF-8 / multi-byte handling */
    if (c >= 0xC0) {
        // If it starts with 0xC0 or higher, it's multi-byte in UTF-8.
        while (len < n && (s[len] & 0xC0) == 0x80) {
            len++;
        }

        if (len == n) {
            return (size_t)-1;  // Invalid sequence or truncated
        }
    }

    return len;  // Return the length of valid multi-byte character
}

int mbscmp(const char *s1, const char *s2)
{
    mbstate_t state1 = {0}, state2 = {0};
    size_t len1, len2;

    while (*s1 || *s2) {
        len1 = mbrlen(s1, (size_t)-1, &state1);
        len2 = mbrlen(s2, (size_t)-1, &state2);

        if (len1 == (size_t)-1 || len2 == (size_t)-1) {
            /* Invalid sequence detected */
            return (len1 == (size_t)-1) ? (len2 == (size_t)-1 ? 0 : -1) : 1;
        }

        if (len1 != len2 || strncmp(s1, s2, len1)) {
            return (unsigned char)*s1 - (unsigned char)*s2;
        }

        s1 += len1;
        s2 += len2;
    }

    return 0;  // Both strings are equal
}

int mbscasecmp(const char *s1, const char *s2)
{
    mbstate_t state1 = {0}, state2 = {0};
    size_t len1, len2;

    while (*s1 || *s2) {
        len1 = mbrlen(s1, (size_t)-1, &state1);
        len2 = mbrlen(s2, (size_t)-1, &state2);

        if (len1 == (size_t)-1 || len2 == (size_t)-1) {
            /* Invalid sequence detected */
            return (len1 == (size_t)-1) ? (len2 == (size_t)-1 ? 0 : -1) : 1;
        }

        /* Case-insensitive comparison */
        for (size_t i = 0; i < len1 && i < len2; i++) {
            if (tolower((unsigned char)s1[i]) != tolower((unsigned char)s2[i])) {
                return (unsigned char)tolower((unsigned char)s1[i]) - (unsigned char)tolower((unsigned char)s2[i]);
            }
        }

        s1 += len1;
        s2 += len2;
    }

    return 0;  // Both strings are equal
}

size_t mbsnrtowcs(wchar_t *dst, const char **src, size_t n, size_t len, mbstate_t *ps)
{
    size_t i = 0;

    while (i < len && n > 0) {
        size_t char_len = mbrlen(*src, n, ps);
        if (char_len == (size_t)-1) {
            return (size_t)-1;  // Invalid sequence
        }
        if (char_len == 0) {
            break;  // Null terminator
        }

        if (dst) {
            *dst = (wchar_t)(unsigned char)(*src)[0]; // Storing wide character
        }

        *src += char_len;
        n -= char_len;
        dst++;
        i++;
    }

    return i;  // Number of wide characters written
}

char *mbschr(const char *s, int c)
{
    while (*s) {
        if ((unsigned char)*s == (unsigned char)c) {
            return (char *)s;
        }
        s++;
    }
    return NULL;  // Character not found
}

wchar_t *wcsdup(const wchar_t *s)
{
    size_t len = wcsnlen(s, (size_t)-1);
    wchar_t *dup = (wchar_t *)malloc((len + 1) * sizeof(wchar_t));  // Allocating memory

    if (dup) {
        wmemcpy(dup, s, len + 1);  // Copying the string
    }

    return dup;
}

#if 0
int wcwidth(wchar_t wc)
{
    if (wc == L'\0') {
        return 0;  // Null character
    }

    /* Control characters (non-printable) */
    if (wc < 0x20 || (wc >= 0x7F && wc <= 0x9F)) {
        return -1;  // Non-printable control characters
    }

    /* Unicode East Asian Wide characters (typically takes 2 columns) */
    if ((wc >= 0x1100 && wc <= 0x11FF) || (wc >= 0x2E80 && wc <= 0xA4CF) || (wc >= 0xAC00 && wc <= 0xD7A3)) {
        return 2;
    }

    /* Most other characters typically take 1 column */
    return 1;
}

int iswupper(wchar_t wc)
{
    return (wc >= L'A' && wc <= L'Z');
}

int iswlower(wchar_t wc)
{
    return (wc >= L'a' && wc <= L'z');
}

wchar_t towupper(wchar_t wc)
{
    if (iswlower(wc)) {
        return wc - L'a' + L'A';  // Convert to uppercase (basic ASCII)
    }
    return wc;  // No change if already uppercase
}

wchar_t towlower(wchar_t wc)
{
    if (iswupper(wc)) {
        return wc - L'A' + L'a';  // Convert to lowercase (basic ASCII)
    }
    return wc;  // No change if already lowercase
}

int iswalpha(wchar_t wc)
{
    return (wc >= L'A' && wc <= L'Z') || (wc >= L'a' && wc <= L'z');
}

int iswdigit(wchar_t wc)
{
    return (wc >= L'0' && wc <= L'9');
}

int iswalnum(wchar_t wc)
{
    return (iswalpha(wc) || iswdigit(wc));  // Checks if it's a letter or a digit
}
#endif

#if 0

size_t mbslen(const char *s)
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

size_t utf8_strlen(const char *s)
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

int utf8_validate(const char *s)
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

#endif

#endif
