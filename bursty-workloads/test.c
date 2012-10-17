#include <stdio.h>
#include <unistd.h>
#include <sys/time.h>


#define SLEEP_INTERVAL_SEC 5


unsigned int busy() {
        
    // estimation:
    // suppose a 1GHz processor, where each addition takes around 1ns,
    // 1,000,000 additions takes around 1ms
    //

    unsigned int count = 1000 * 1000;
    unsigned int i;
    unsigned int total = 0;
    for (i = 0; i <= count; i++) {
        total += i;
    }

    return total;
}

int main(int argc, char **argv) {
    struct timeval tv;
    unsigned int k;

    printf(" --- bursty starts ---\n");

    while (1) {
        sleep(SLEEP_INTERVAL_SEC);

        k += busy();         // prevent compiler opt

        gettimeofday(&tv, NULL);

        unsigned long long millisecondsSinceEpoch =
        (unsigned long long)(tv.tv_sec) * 1000 +
        (unsigned long long)(tv.tv_usec) / 1000;

        // for debugging
        // printf("%llu\n", millisecondsSinceEpoch);
    }

    return k;
}

