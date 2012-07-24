#include <pthread.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/time.h>

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

#define NUM_THREADS 4
#define NUM_ITERATIONS (1L << 30)

#define CACHE_SIZE 128

typedef struct {
   long d;
   char buffer[CACHE_SIZE-sizeof(long)];
} Data;

Data *data;
   
void *thread_function( void *args )
{
   long i; 
   long j = (long)args;
       
   for ( i = 0; i < NUM_ITERATIONS; i++ )
   {
       data[j].d = i;
   }
   
   return NULL;
}   
   
int main( int argc, char **argv )
{   
   long i, j;
   pthread_t ids[NUM_THREADS-1];
   struct timeval start, end;
   double d;
   
   data = (Data*)malloc( sizeof(Data)*NUM_THREADS );
       
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
