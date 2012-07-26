
#include <pthread.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

#define NUM_THREADS 8
#define NUM_ITERATIONS (1L << 28)
//#define NUM_ITERATIONS (1L << 22)


//http://stackoverflow.com/questions/3247373/how-to-measure-program-execution-time-in-arm-cortex-a8-processor

// false sharing
// http://www.mapleprimes.com/maplesoftblog/95842-False-Sharing

// affinity -- contributed by zhen
// ------------------------------------------------------------

static inline unsigned int get_cyclecount (void)
{
  unsigned int value;
  // Read CCNT Register
  asm volatile ("MRC p15, 0, %0, c9, c13, 0\t\n": "=r"(value));  
  return value;
}

double the_overhead = 18;

// about 18 cycles on panda
double get_couting_overhead() 
{
  // measure the counting overhead:

  unsigned int overhead;
  double sum = 0;
  int i;

  for (i = 0; i < 10000; i ++) {
      overhead = get_cyclecount();
      overhead = get_cyclecount() - overhead;    
      sum += overhead;
  }

  return sum / 10000;
}

static inline void init_perfcounters (int32_t do_reset, int32_t enable_divider)
{
  // in general enable all counters (including cycle counter)
  int32_t value = 1;

  // peform reset:  
  if (do_reset)
  {
    value |= 2;     // reset all counters to zero.
    value |= 4;     // reset cycle counter to zero.
  } 

  if (enable_divider)
    value |= 8;     // enable "by 64" divider for CCNT.

  value |= 16;

  // program the performance-counter control-register:
  asm volatile ("MCR p15, 0, %0, c9, c12, 0\t\n" :: "r"(value));  

  // enable all counters:  
  asm volatile ("MCR p15, 0, %0, c9, c12, 1\t\n" :: "r"(0x8000000f));  

  // clear overflows:
  asm volatile ("MCR p15, 0, %0, c9, c12, 3\t\n" :: "r"(0x8000000f));


}

///
// call this func to test if the perf cnt works
//
// 
void test_counter() {
// init counters:
  init_perfcounters (1, 0); 

  // measure the counting overhead:
  unsigned int overhead = get_cyclecount();
  overhead = get_cyclecount() - overhead;    

  unsigned int t = get_cyclecount();

  // do some stuff here..
  int j, i;
  for (i = 0; i < (1<<25); i++) 
    j += i;

  t = get_cyclecount() - t;

  printf ("test_counter: function took exactly %d cycles (including function call)\n ", t - overhead);
}

// -----------------------------------------------------------------------------------

long *data;

void *thread_function( void *args )
{
   long i;
   long j = (long)args; // thread index
   
   double sum = 0.0;

   unsigned int cycle_count;

   printf("thread_function index %ld launched\n", j);

    // ----------------- affinity
  unsigned long mask;
  int s;
  
  //    won't compile??
    //CPU_ZERO(&mask);
    //CPU_SET(j % 2, &mask);       
    
    mask = 1 << (j % 2); // we have 2 cpus on omap4.  
    s = pthread_setaffinity_np(pthread_self(), sizeof(mask), &mask);    
    
    if (s != 0) {
        perror("pthread_setaffinity_np");
        return NULL;
    } else {
        printf("thread_function index %d ===> cpu %ld\n", j, mask);
    }
        
   if (j == 0)
       cycle_count = get_cyclecount();

    struct timespec tp;
    double ts_ms1, ts_ms2;
    clock_gettime(CLOCK_THREAD_CPUTIME_ID, &tp);
    ts_ms1 = (double) tp.tv_sec * 1000 + (double) tp.tv_nsec / 1000 / 1000;    
    
   for ( i = 0; i < NUM_ITERATIONS; i++ )
   {
       // -------- init measuring -------------
       //if (j == 0 && i > (1<<20))
           //init_perfcounters(1, 0);

       //if (j == 0)
       //if (j == 0 && i > (1<<20))
           //cycle_count = get_cyclecount();

       data[j] = i;

       //if (j == 0) {
       //if (j == 0 && i > (1<<20)) {
        //   cycle_count = get_cyclecount() - cycle_count;
         //  sum += (double)cycle_count;
       //}
   }

    //sleep(5);  ----> used for testing per thread timer
    // time?

    clock_gettime(CLOCK_THREAD_CPUTIME_ID, &tp);
    ts_ms2 = (double) tp.tv_sec * 1000 + (double) tp.tv_nsec / 1000 / 1000;
    
    // cannot measure instr. cnt over the entire loop, since it is highly get preempted (?)
   //if (j == 0) {
   //    cycle_count = get_cyclecount() - cycle_count;
   //    sum = (double)cycle_count;
   //}

   if (j == 0)
       //printf("thread_function w %ld finished, avg cycles in accessing %f\n", j, sum/NUM_ITERATIONS);
    printf("thread_function w %ld finished, per thread clock advances %f ms\n", j, ts_ms2 - ts_ms1);

   return NULL;
}

int main( int argc, char **argv )
{
    int ret; 
   long i, j;
   pthread_t ids[NUM_THREADS-1];
   struct timeval start, end;
   double d;

   data = (long*)malloc( sizeof(long)*NUM_THREADS );

      // ----- xzl ------
       // -------- init measuring -------------
       init_perfcounters(1, 0);

      //the_overhead = get_couting_overhead();
      printf("counting overhead %.2f cycles\n", the_overhead);

   for ( j = 1; j <= NUM_THREADS; j++ )
   {
       // ----------- init data --------------
       for ( i = 0; i < NUM_THREADS; i++ )
       {
           data[i] = 0;
       }


       printf(" =============== new test round, # of threads %d =============\n", j);

       // ---------- now, cr test threads, i is the thread # -----------
       gettimeofday( &start, NULL );
       for ( i = 0; i < j-1; i++ )
       {
           ret = pthread_create( ids+i, NULL, thread_function, (void*)i );
           if (ret != 0) {
               perror("failed to cr thread");
               return 1;
           } else {
               printf("thread %d cr ok\n", i);
           }
       }

       // --------- this thread also does real thread work, index is the largest one  ------------
       thread_function( (void*)i );


       // --------- cleaning up threads ---------------------
       for ( i = 0; i < j-1; i++ )
       {
           pthread_join( ids[i], NULL );
       }

       gettimeofday( &end, NULL );

       d = end.tv_sec - start.tv_sec + (1.0e-6)*end.tv_usec - (1.0e-6)*start.tv_usec;

       // xzl --- ips is the # of mem accesses (from all threads) per sec
       printf( "%ld: %g elpased time/sec: %g ips\n", j, d, ((double)j*NUM_ITERATIONS)/d );
   }

   return 0;
}

