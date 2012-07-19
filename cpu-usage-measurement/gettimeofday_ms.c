#include <stdio.h>
#include <sys/time.h>

//
// Android date command seems not to impl. resolution higher than sec. (at least for ICS MIUI S2)
int main(int argc, char **argv) {
    struct timeval tv;

    gettimeofday(&tv, NULL);

    unsigned long long millisecondsSinceEpoch =
    (unsigned long long)(tv.tv_sec) * 1000 +
    (unsigned long long)(tv.tv_usec) / 1000;

    printf("%llu\n", millisecondsSinceEpoch);
}
