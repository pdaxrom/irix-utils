#include <stdio.h>
#include <stdlib.h>

int getline(char **lineptr, size_t *n, FILE *stream)
{
    char *buf;
    size_t size;
    int ch;
    size_t i;

    if (lineptr == NULL || n == NULL || stream == NULL) {
        return -1;
    }

    if (*lineptr == NULL || *n == 0) {
        *n = 128;
        *lineptr = (char *)malloc(*n);
        if (*lineptr == NULL) {
            return -1;
        }
    }

    buf = *lineptr;
    size = *n;
    i = 0;

    while ((ch = fgetc(stream)) != EOF) {
        if (i + 1 >= size) {
            size_t new_size;
            char *new_buf;

            new_size = size * 2;
            new_buf = (char *)realloc(buf, new_size);
            if (new_buf == NULL) {
                return -1;
            }

            buf = new_buf;
            size = new_size;
        }

        buf[i++] = (char)ch;

        if (ch == '\n') {
            break;
        }
    }

    if (i == 0 && ch == EOF) {
        return -1;
    }

    buf[i] = '\0';
    *lineptr = buf;
    *n = size;

    return (int)i;
}
