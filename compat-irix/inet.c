#include <stdio.h>
#include <string.h>
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
