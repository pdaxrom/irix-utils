#include "compat_config.h"

#ifndef COMPAT_IRIX_65

//#include "netdb.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>

/* Allocate and copy string */
static char *strdup_safe(const char *s)
{
    if (!s) return NULL;
    char *copy = malloc(strlen(s) + 1);
    if (copy) strcpy(copy, s);
    return copy;
}

void freeaddrinfo(struct addrinfo *res)
{
    while (res) {
        struct addrinfo *next = res->ai_next;
        if (res->ai_addr) free(res->ai_addr);
        if (res->ai_canonname) free(res->ai_canonname);
        free(res);
        res = next;
    }
}

const char *gai_strerror(int errcode)
{
    switch (errcode) {
        case 0: return "Success";
        case EAI_FAIL: return "Non-recoverable failure";
        case EAI_MEMORY: return "Memory allocation failure";
        case EAI_NONAME: return "Name or service not known";
        case EAI_FAMILY: return "Address family not supported";
        case EAI_SERVICE: return "Service not supported";
        case EAI_OVERFLOW: return "Buffer overflow";
        case EAI_SYSTEM: return "System error";
        default: return "Unknown error";
    }
}

int getaddrinfo(const char *node, const char *service,
                const struct addrinfo *hints, struct addrinfo **res)
{
    struct hostent *he = NULL;
    struct servent *se = NULL;
    struct sockaddr_in *sa;
    struct addrinfo *ai = NULL;
    int port = 0;

    if (!node && !service) return EAI_NONAME;
    if (hints && hints->ai_family != AF_INET && hints->ai_family != AF_UNSPEC)
        return EAI_FAMILY;

    if (service) {
        port = atoi(service);
        if (port == 0) {
            se = getservbyname(service, NULL);
            if (!se) return EAI_SERVICE;
            port = ntohs(se->s_port);
        }
    }

    *res = NULL;
    int socktypes[2] = { SOCK_STREAM, SOCK_DGRAM };
    int ntypes = (hints && hints->ai_socktype) ? 1 : 2;

    for (int i = 0; i < ntypes; ++i) {
        int socktype = (ntypes == 1) ? hints->ai_socktype : socktypes[i];

        ai = (struct addrinfo *)calloc(1, sizeof(struct addrinfo));
        if (!ai) {
            freeaddrinfo(*res);
            return EAI_MEMORY;
        }

        ai->ai_family = AF_INET;
        ai->ai_socktype = socktype;
        ai->ai_protocol = (socktype == SOCK_DGRAM) ? IPPROTO_UDP : IPPROTO_TCP;
        ai->ai_flags = hints ? hints->ai_flags : 0;
        ai->ai_addrlen = sizeof(struct sockaddr_in);
        ai->ai_addr = malloc(sizeof(struct sockaddr_in));
        if (!ai->ai_addr) {
            free(ai);
            freeaddrinfo(*res);
            return EAI_MEMORY;
        }

        sa = (struct sockaddr_in *)ai->ai_addr;
        memset(sa, 0, sizeof(struct sockaddr_in));
        sa->sin_family = AF_INET;
        sa->sin_port = htons(port);

        if (!node) {
            sa->sin_addr.s_addr = (ai->ai_flags & AI_PASSIVE)
                                ? htonl(INADDR_ANY)
                                : htonl(INADDR_LOOPBACK);
        } else if (ai->ai_flags & AI_NUMERICHOST) {
            if (inet_aton(node, &sa->sin_addr) == 0) {
                freeaddrinfo(ai);
                freeaddrinfo(*res);
                return EAI_NONAME;
            }
        } else {
            he = gethostbyname(node);
            if (!he || he->h_addrtype != AF_INET) {
                freeaddrinfo(ai);
                freeaddrinfo(*res);
                return EAI_FAIL;
            }
            memcpy(&sa->sin_addr, he->h_addr, sizeof(struct in_addr));

            if ((ai->ai_flags & AI_CANONNAME) && !*res) {
                ai->ai_canonname = strdup_safe(he->h_name);
                if (!ai->ai_canonname) {
                    freeaddrinfo(ai);
                    freeaddrinfo(*res);
                    return EAI_MEMORY;
                }
            }
        }

        ai->ai_next = *res;
        *res = ai;
    }
    return 0;
}

int getnameinfo(const struct sockaddr *sa, socklen_t salen,
                char *host, size_t hostlen,
                char *serv, size_t servlen, int flags)
{
    const struct sockaddr_in *sin = (const struct sockaddr_in *)sa;

    if (sa->sa_family != AF_INET || salen < sizeof(struct sockaddr_in))
        return EAI_FAMILY;

    if (host && hostlen > 0) {
        const char *ip = inet_ntoa(sin->sin_addr);
        if (!ip || strlen(ip) >= hostlen)
            return EAI_OVERFLOW;

        if (flags & NI_NUMERICHOST) {
            strncpy(host, ip, hostlen);
        } else {
            struct hostent *he = gethostbyaddr((const char *)&sin->sin_addr,
                                               sizeof(sin->sin_addr),
                                               AF_INET);
            if (!he || strlen(he->h_name) >= hostlen)
                return EAI_FAIL;
            strncpy(host, he->h_name, hostlen);
        }
    }

    if (serv && servlen > 0) {
        int port = ntohs(sin->sin_port);
        if (flags & NI_NUMERICSERV) {
            if (snprintf(serv, servlen, "%d", port) >= servlen)
                return EAI_OVERFLOW;
        } else {
            struct servent *se = getservbyport(htons(port), NULL);
            if (!se || strlen(se->s_name) >= servlen)
                return EAI_FAIL;
            strncpy(serv, se->s_name, servlen);
        }
    }

    return 0;
}

#endif
