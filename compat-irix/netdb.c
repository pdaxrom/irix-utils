#include "compat_config.h"

#ifndef COMPAT_IRIX_65

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <errno.h>

int getaddrinfo(const char *node, const char *service,
                const struct addrinfo *hints,
                struct addrinfo **res)
{
    struct hostent *he;
    struct sockaddr_in *addr;
    struct addrinfo *ai;
    int port = 0;

    if (!node && !service)
        return EAI_NONAME;

    if (service)
        port = htons(atoi(service));

    he = gethostbyname(node ? node : "localhost");
    if (!he)
        return EAI_FAIL;

    ai = (struct addrinfo *)malloc(sizeof(struct addrinfo));
    if (!ai)
        return EAI_MEMORY;

    memset(ai, 0, sizeof(struct addrinfo));

    addr = (struct sockaddr_in *)malloc(sizeof(struct sockaddr_in));
    if (!addr) {
        free(ai);
        return EAI_MEMORY;
    }

    memset(addr, 0, sizeof(struct sockaddr_in));
    addr->sin_family = AF_INET;
    addr->sin_port = port;
    memcpy(&addr->sin_addr, he->h_addr_list[0], he->h_length);

    ai->ai_family = AF_INET;
    ai->ai_socktype = hints ? hints->ai_socktype : SOCK_STREAM;
    ai->ai_protocol = hints ? hints->ai_protocol : 0;
    ai->ai_addrlen = sizeof(struct sockaddr_in);
    ai->ai_addr = (struct sockaddr *)addr;
    ai->ai_canonname = NULL;
    ai->ai_next = NULL;

    *res = ai;
    return 0;
}

void freeaddrinfo(struct addrinfo *res)
{
    if (res) {
        if (res->ai_addr)
            free(res->ai_addr);
        if (res->ai_canonname)
            free(res->ai_canonname);
        free(res);
    }
}

const char *gai_strerror(int errcode)
{
    switch (errcode) {
        case 0: return "Success";
        case EAI_NONAME: return "Name or service not known";
        case EAI_MEMORY: return "Memory allocation failure";
        case EAI_FAIL: return "Non-recoverable failure";
        default: return "Unknown error";
    }
}

int getnameinfo(const struct sockaddr *sa, socklen_t salen,
                char *host, socklen_t hostlen,
                char *serv, socklen_t servlen, int flags)
{
    if (!sa || salen == 0)
        return EAI_FAIL;

    if (sa->sa_family == AF_INET) {
        const struct sockaddr_in *sin = (const struct sockaddr_in *)sa;

        if (host && hostlen > 0) {
            if (flags & NI_NUMERICHOST) {
                const char *addr = inet_ntoa(sin->sin_addr);
                if (!addr)
                    return EAI_FAIL;
                if (strlen(addr) >= hostlen)
                    return EAI_OVERFLOW;
                strcpy(host, addr);
            } else {
                // DNS lookup would happen here (but skip for IRIX 5.3)
                return EAI_NONAME;
            }
        }

        if (serv && servlen > 0) {
            if (flags & NI_NUMERICSERV) {
                int port = ntohs(sin->sin_port);
                snprintf(serv, servlen, "%d", port);
            } else {
                // Service lookup would happen here (skip for IRIX 5.3)
                return EAI_NONAME;
            }
        }

        return 0;
    }

    // Only support AF_INET (IPv4) on IRIX 5.3
    return EAI_FAMILY;
}

#endif
