#include <string.h>
#include <errno.h>
#include <asm/segment.h>

// limit: 23
char msg[24];

int sys_iam(const char* name) {
    int i = 0;
    char tmp[30];
    for (i = 0; i < 30; i ++) {
        tmp[i] = get_fs_byte(name + i);
        if ('\0' == tmp[i]) {
            break;
        }
    }
    if (i > 23) { // if name is longer than 23 (except '\0')
        return -(EINVAL);
    }

    strcpy(msg, tmp);
    return i;
}

int sys_whoami(char* name, unsigned int size) {
    int len = 0;
    while ('\0' != msg[len]) {
        len ++;
    }
    if (len > size) {
        return -(EINVAL);
    }

	int i = 0;
	for(i = 0; i < size; i ++) {
		put_fs_byte(msg[i], name + i);
		if('\0' == msg[i]) {
            break;
        }
	}
	return i;
}
