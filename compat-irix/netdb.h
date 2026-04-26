#ifndef COMPAT_NETDB_H
#define COMPAT_NETDB_H

#include <compat_config.h>
#include "compat_types.h"
#include <sys/socket.h>

/* Пытаемся включить системный netdb.h */
#include_next <netdb.h>

/* Если AI_PASSIVE не определен, значит в системе старый netdb.h */
#ifndef AI_PASSIVE

#define AI_PASSIVE     0x0001
#define AI_CANONNAME   0x0002
#define AI_NUMERICHOST 0x0004
#define AI_ADDRCONFIG  0x0020

#define NI_NUMERICHOST 1
#define NI_NUMERICSERV 2
#define NI_MAXHOST     1025
#define NI_MAXSERV     32

#define EAI_BADFLAGS	  -1
#define EAI_NONAME	  -2
#define EAI_AGAIN	  -3
#define EAI_FAIL	  -4
#define EAI_FAMILY	  -6
#define EAI_SOCKTYPE	  -7
#define EAI_SERVICE	  -8
#define EAI_MEMORY	  -10
#define EAI_SYSTEM	  -11
#define EAI_OVERFLOW	  -12
#define EAI_NODATA        -5
#define EAI_ADDRFAMILY    -9

struct addrinfo {
    int ai_flags;
    int ai_family;
    int ai_socktype;
    int ai_protocol;
    size_t ai_addrlen;
    struct sockaddr *ai_addr;
    char *ai_canonname;
    struct addrinfo *ai_next;
};

#ifdef __cplusplus
extern "C" {
#endif

int getaddrinfo(const char *node, const char *service,
                const struct addrinfo *hints, struct addrinfo **res);

void freeaddrinfo(struct addrinfo *res);

const char *gai_strerror(int errcode);

int getnameinfo(const struct sockaddr *sa, socklen_t salen,
                char *host, size_t hostlen,
                char *serv, size_t servlen, int flags);

#ifdef __cplusplus
}
#endif

#endif /* AI_PASSIVE */

#endif /* COMPAT_NETDB_H */
