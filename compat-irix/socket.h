#ifndef COMPAT_SOCKET_H
#define COMPAT_SOCKET_H

#include <compat_config.h>
#include_next <sys/socket.h>

#ifndef COMPAT_IRIX_65
typedef unsigned short sa_family_t;

struct sockaddr_storage {
    sa_family_t ss_family;   /* address family */
    char _ss_pad[128 - sizeof(sa_family_t)]; /* padding to match modern size */
};
#endif

#endif
