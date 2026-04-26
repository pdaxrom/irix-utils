/* Simplified sys/queue.h for IRIX compatibility */

#ifndef COMPAT_SYS_QUEUE_H
#define COMPAT_SYS_QUEUE_H

/* Singly-linked List */
#define SLIST_HEAD(name, type)                      \
struct name {                                       \
    struct type *slh_first;                         \
}

#define SLIST_ENTRY(type)                           \
struct {                                            \
    struct type *sle_next;                          \
}

/* List */
#define LIST_HEAD(name, type)                       \
struct name {                                       \
    struct type *lh_first;                          \
}

#define LIST_ENTRY(type)                            \
struct {                                            \
    struct type *le_next;                           \
    struct type **le_prev;                          \
}

/* Tail queue */
#define TAILQ_HEAD(name, type)                      \
struct name {                                       \
    struct type *tqh_first;                         \
    struct type **tqh_last;                         \
}

#define TAILQ_ENTRY(type)                           \
struct {                                            \
    struct type *tqe_next;                          \
    struct type **tqe_prev;                         \
}

/* Basic macros */
#define SLIST_INIT(head) do { (head)->slh_first = NULL; } while (0)
#define SLIST_INSERT_HEAD(head, elm, field) do {            \
    (elm)->field.sle_next = (head)->slh_first;              \
    (head)->slh_first = (elm);                              \
} while (0)

#define LIST_INIT(head) do { (head)->lh_first = NULL; } while (0)
#define LIST_INSERT_HEAD(head, elm, field) do {             \
    if (((elm)->field.le_next = (head)->lh_first) != NULL)  \
        (head)->lh_first->field.le_prev = &(elm)->field.le_next; \
    (head)->lh_first = (elm);                               \
    (elm)->field.le_prev = &(head)->lh_first;               \
} while (0)

#define TAILQ_INIT(head) do {                               \
    (head)->tqh_first = NULL;                               \
    (head)->tqh_last = &(head)->tqh_first;                  \
} while (0)

#define TAILQ_INSERT_TAIL(head, elm, field) do {            \
    (elm)->field.tqe_next = NULL;                           \
    (elm)->field.tqe_prev = (head)->tqh_last;               \
    *(head)->tqh_last = (elm);                              \
    (head)->tqh_last = &(elm)->field.tqe_next;              \
} while (0)

#define TAILQ_FOREACH(var, head, field)                     \
    for ((var) = ((head)->tqh_first);                       \
        (var);                                              \
        (var) = ((var)->field.tqe_next))

#endif
