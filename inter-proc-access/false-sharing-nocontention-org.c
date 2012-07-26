/*
 
cc false-sharing-org.c -lpthread -lrt  -o false-sharing-org-x86

core i5-3550

1) 2.07238 5.18121e+08 ips
2) 2.07426 1.0353e+09 ips
3) 2.12481 1.51601e+09 ips
4) 2.24804 1.91054e+09 ips

felix.recg.rice.edu (8-core machine)

1) 2.84093 3.77954e+08 ips
2) 2.95773 7.26058e+08 ips
3) 2.97088 1.08427e+09 ips
4) 2.96255 1.44976e+09 ips
5) 2.96406 1.81127e+09 ips
6) 2.94951 2.18425e+09 ips
7) 2.95677 2.54203e+09 ips
8) 3.08167 2.78742e+09 ips

*/

#include <pthread.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/time.h>
#include <errno.h>

#define NUM_THREADS 2
#define NUM_ITERATIONS ((uint64_t)1 << 28)    // xzl: for shorter run time: 1<<28 for omap4, 1<<30 for x86 

#define CACHE_SIZE 512          // 512 works for i5 3550; 256 seems not

typedef struct {
   uint32_t d;
   char buffer[CACHE_SIZE-sizeof(uint32_t)];
} Data;

Data *data;
   
void *thread_function( void *args )
{
   uint64_t i;
   long j = (long)args;
       

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

    long index = j * 63;
   for ( i = 0; i < NUM_ITERATIONS; i++ )
   {
       // random access, to defeat prefetching
       //index = (index * 13 + 1) % 64;   // won't work. the computation does not scale with threads??
       //index = (index + 31) & 63;
       //printf("thread %d index %d\n", j, index);

       //index = 63 - index;            // only a small computation here will harm scalability, why?

       data[j].d += (uint32_t)(i & 0xffffffff);      // W, subject to opt?
    
       // not quite working
       //asm volatile ("dmb");

       //data[63-index].d += (uint32_t)(i & 0xffffffff);      // W, subject to opt?

       //data[j].d = i;
       //data[j].d = (uint32_t)(i & 0xffffffff);      // W, subject to opt?
        //data[j].d += (uint32_t)(i & 0xffffffff);       
   }
   
   printf("%ld", data[j]); // consume the data
   return NULL;
}   
   
int main( int argc, char **argv )
{   
   long i, j;
   pthread_t ids[NUM_THREADS-1];
   struct timeval start, end;
   double d;
   
   printf("NUM_THREAD = %d NUM_ITERATIONS = %lu\n", NUM_THREADS, NUM_ITERATIONS);
   
   //data = (Data*)malloc( sizeof(Data)*NUM_THREADS );
   data = (Data*)malloc( sizeof(Data)*64 );
       
   for ( j = 1; j <= NUM_THREADS; j++ )
   {       
       for ( i = 0; i < NUM_THREADS; i++ )
       {
           data[i].d = 0;
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
