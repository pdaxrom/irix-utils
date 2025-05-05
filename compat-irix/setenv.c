#include <stdlib.h>
#include <string.h>
#include <errno.h>

/*
 * setenv - set environment variable
 * 
 * This is a implementation for systems that don't have it (like IRIX 5.3)
 * 
 * Parameters:
 *   name - variable name
 *   value - value to set
 *   overwrite - if 0, don't overwrite existing variable
 * 
 * Returns:
 *   0 on success, -1 on error with errno set
 */
int compat_setenv(const char *name, const char *value, int overwrite)
{
    char *env_entry;
    size_t name_len;
    size_t value_len;

    /* Validate input parameters */
    if (name == NULL || name[0] == '\0' || strchr(name, '=') != NULL) {
        errno = EINVAL;
        return -1;
    }

    /* If we're not overwriting and the variable exists, return success */
    if (!overwrite && getenv(name) != NULL) {
        return 0;
    }

    /* Calculate lengths */
    name_len = strlen(name);
    value_len = strlen(value);

    /* Allocate memory for "name=value" string */
    env_entry = malloc(name_len + 1 + value_len + 1);
    if (env_entry == NULL) {
        errno = ENOMEM;
        return -1;
    }

    /* Construct the environment entry */
    memcpy(env_entry, name, name_len);
    env_entry[name_len] = '=';
    memcpy(env_entry + name_len + 1, value, value_len);
    env_entry[name_len + 1 + value_len] = '\0';

    /* Put it in the environment */
    if (putenv(env_entry)) {
        free(env_entry);
        return -1;
    }

    return 0;
}
