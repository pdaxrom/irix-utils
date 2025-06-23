#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>

char *mkdtemp(char *path)
{
    if (!path || strlen(path) < 6) {
        errno = EINVAL;
        return NULL;
    }

    char *XXXXXX = strstr(path, "XXXXXX");
    if (!XXXXXX) {
        errno = EINVAL;
        return NULL;
    }

    pid_t pid = getpid();
    time_t now = time(NULL);
    int tries = 100;

    for (int attempt = 0; attempt < tries; ++attempt) {
        unsigned long rnd = (unsigned long)(now + pid + attempt);

        // Fill XXXXXX with pseudo-random alphanumeric chars
        for (int i = 0; i < 6; ++i) {
            static const char charset[] =
                "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            XXXXXX[i] = charset[rnd % (sizeof(charset) - 1)];
            rnd /= (sizeof(charset) - 1);
        }

        // Try to make the directory
        if (mkdir(path, 0700) == 0)
            return path;

        // If mkdir failed for a reason other than EEXIST, abort
        if (errno != EEXIST)
            break;
    }

    // Failed after many attempts
    path[0] = '\0';
    return NULL;
}
