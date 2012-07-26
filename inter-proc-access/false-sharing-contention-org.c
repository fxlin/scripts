/*
 * 
 ==============================
 x86, i5-3550, 4 cores

BUILD:
 cc false-sharing-contention-org.c -lpthread -o /tmp/fs 

iterations: 1<<32
 1) 8.19753 5.23935e+08 ips
 2) 20.0924 4.27522e+08 ips
 3) 39.5459 3.25821e+08 ips
 4) 54.8296 3.13332e+08 ips

 ===============================

 on omap4430(panda), 2 cores

BUILD:
 arm-linux-gnueabi-gcc  false-sharing-contention-org.c -static -lpthread -o /tmp/fs-arm
 adb push /tmp/fs-arm /data/local/

iterations: 1<<32
 1) 95.0957 4.51647e+07 ips
 2) 98.3868 8.73078e+07 ips
 3) 147.06 8.76168e+07 ips
 4) 194.092 8.85139e+07 ips

=================================
on galaxy s2 (exyons)

iterations 1<<28
1) 17.3351 1.54851e+07 ips
2) 24.0765 2.22985e+07 ips
3) 30.4564 2.64413e+07 ips
4) 37.0298 2.89967e+07 ips


perf:
perf stat -e cycles,instructions ./fs-arm 2
perf stat -e L1-dcache-stores,L1-dcache-store-misses,L1-dcache-loads,L1-dcache-load-misses 

/data/local # perf stat -e instructions,cycles,cache-references,cache-misses ./f
s-arm 2
NUM_THREAD = 2 NUM_ITERATIONS = 268435456
01) 6.49818 4.13093e+07 ips
002) 9.46931 5.66959e+07 ips

 Performance counter stats for './fs-arm 2':

       18316767060 instructions              #    0.84  insns per cycle        
       21742834351 cycles                    #    0.000 GHz                    
       10896084820 cache-references                                            
           1032975 cache-misses              #    0.009 % of all cache refs    

      15.969995716 seconds time elapsed

*/

#include <pthread.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/time.h>
#include <errno.h>

#define NUM_ITERATIONS ((uint64_t)1 << 28)    // xzl: for shorter run time: 1<<28 for omap4, 1<<30 for x86 

int NUM_THREADS=2;
uint32_t *data;

void *thread_function( void *args )
{
   uint64_t i;
   long j = (long)args;
   long k = 0;

    // ----------------- affinity --------------
    unsigned long mask;
    int s;
    mask = 1 << (j % 2); // we have 2 cpus on omap4.  
    printf("try affinity index %d ===> cpu %ld ... \n", j, mask);
    s = pthread_setaffinity_np(pthread_self(), sizeof(mask), &mask);    
    if (s != 0) {
        errno = s;
        perror("pthread_setaffinity_np");
        //printf("pthread_setaffinity_np failed %d", s);
        exit(1);
    } else {
        printf("thread_function index %d ===> cpu %ld\n", j, mask);
    }
    // -----------------------------------------

   for ( i = 0; i < NUM_ITERATIONS; i++ )
   {
       //data[j] = (uint32_t)(i & 0xffffffff);      // W
       data[j] += (uint32_t)(i & 0xffffffff);     // R+W
       //k += data[j];                                // R     read only, shouldn't harm scalability
   }

   printf("%ld", k); // consume the data
   return NULL;
}

int main( int argc, char **argv )
{
   long i, j;
   pthread_t ids[NUM_THREADS-1];
   struct timeval start, end;
   double d;

   if (argc > 1) {
       NUM_THREADS = atoi(argv[1]);
   }
   printf("NUM_THREAD = %d NUM_ITERATIONS = %lu\n", NUM_THREADS, NUM_ITERATIONS);

   data = (uint32_t*)malloc( sizeof(uint32_t)*NUM_THREADS );

   for ( j = 1; j <= NUM_THREADS; j++ )
   {
       for ( i = 0; i < NUM_THREADS; i++ )
       {
           data[i] = 0;
       }

       gettimeofday( &start, NULL );
       for ( i = 0; i < j-1; i++ )
       {
           pthread_create( ids+i, NULL, thread_function, (void*)i );
       }

       thread_function( (void*)i );

       for ( i = 0; i < j-1; i++ )
       {
           pthread_join( ids[i], NULL );
       }

       gettimeofday( &end, NULL );

       d = end.tv_sec - start.tv_sec + (1.0e-6)*end.tv_usec - (1.0e-6)*start.tv_usec;

       printf( "%ld) %g %g ips\n", j, d, ((double)j*NUM_ITERATIONS)/d );
   }

   return 0;
}
