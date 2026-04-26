#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>

int inet_pton(int af, const char *src, void *dst)
{
    if (af == AF_INET) {
        struct in_addr addr;
        if (inet_aton(src, &addr)) {
            memcpy(dst, &addr, sizeof(addr));
            return 1;
        } else {
            return 0; // Invalid address
        }
    }

    // IPv6 not supported in this stub
    return -1;
}

const char *inet_ntop(int af, const void *src, char *dst, socklen_t size)
{
    if (af == AF_INET) {
        char *s = inet_ntoa(*(const struct in_addr *)src);
        if (!s) {
            return NULL;
        }
        if (strlen(s) >= size) {
            return NULL;
        }
        strcpy(dst, s);
        return dst;
    }
    return NULL;
}
