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

 */

#include <pthread.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/time.h>

#define NUM_THREADS 4
#define NUM_ITERATIONS ((uint64_t)1 << 32)    // xzl: for shorter run time: 1<<28 for omap4, 1<<32 for x86 

uint32_t *data;

void *thread_function( void *args )
{
   uint64_t i;
   long j = (long)args;

   for ( i = 0; i < NUM_ITERATIONS; i++ )
   {
       data[j] = (uint32_t)(i & 0xffffffff);
   }

   return NULL;
}

int main( int argc, char **argv )
{
   long i, j;
   pthread_t ids[NUM_THREADS-1];
   struct timeval start, end;
   double d;

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
