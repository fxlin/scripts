/*
 * flushing the memory 
 */
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

#define BUF_SIZE_KB 16*1024       // in KB
#define NUM_ITERATIONS  16

void print_config() {
    printf("write to %d KB buffer, iterations = %d\n", BUF_SIZE_KB, NUM_ITERATIONS);
}

int main(int argc, char **argv) {

    struct timeval start, end;
    double d;
    int j,i;

    print_config();


    uint32_t *p;
    
    // -------------------- random write -------------------
    p = (uint32_t *)malloc(BUF_SIZE_KB * 1024 * sizeof(uint32_t));
    if (!p) {
        perror("malloc");
        return 1;
    }

    int index = 0;
    gettimeofday( &start, NULL );
    for (i = 0; i < NUM_ITERATIONS; i++) {
        for (j =  BUF_SIZE_KB * 1024; j > 0; j--) {
            index = (index + 101) % (BUF_SIZE_KB * 1024); // to be fair with random write
        //for (j = 0; j <  BUF_SIZE_KB * 1024; j++)
            p[j] = 0xffffffff;
        }
    }
    gettimeofday( &end, NULL );
    d = end.tv_sec - start.tv_sec + (1.0e-6)*end.tv_usec - (1.0e-6)*start.tv_usec;
    printf( "%g sec %d\n", d, index);   // consume index

    free(p);

    return 0;
}
