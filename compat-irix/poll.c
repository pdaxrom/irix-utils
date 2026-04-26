#include <sys/types.h>
#include <sys/time.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include "poll.h"

int poll(struct pollfd *fds, nfds_t nfds, int timeout)
{
    fd_set read_fds, write_fds, error_fds;
    struct timeval tv, *tvp;
    int max_fd = -1;
    nfds_t i;
    int ready;

    FD_ZERO(&read_fds);
    FD_ZERO(&write_fds);
    FD_ZERO(&error_fds);

    for (i = 0; i < nfds; i++) {
        if (fds[i].fd < 0) {
            continue;
        }

        if (fds[i].events & POLLIN) {
            FD_SET(fds[i].fd, &read_fds);
        }
        if (fds[i].events & POLLOUT) {
            FD_SET(fds[i].fd, &write_fds);
        }
        FD_SET(fds[i].fd, &error_fds);

        if (fds[i].fd > max_fd) {
            max_fd = fds[i].fd;
        }
    }

    if (timeout < 0) {
        tvp = NULL;
    } else {
        tv.tv_sec = timeout / 1000;
        tv.tv_usec = (timeout % 1000) * 1000;
        tvp = &tv;
    }

    ready = select(max_fd + 1, &read_fds, &write_fds, &error_fds, tvp);

    if (ready > 0) {
        for (i = 0; i < nfds; i++) {
            fds[i].revents = 0;
            if (fds[i].fd < 0) {
                continue;
            }

            if (FD_ISSET(fds[i].fd, &read_fds)) {
                fds[i].revents |= POLLIN;
            }
            if (FD_ISSET(fds[i].fd, &write_fds)) {
                fds[i].revents |= POLLOUT;
            }
            if (FD_ISSET(fds[i].fd, &error_fds)) {
                fds[i].revents |= POLLERR;
            }
        }
    }

    return ready;
}
