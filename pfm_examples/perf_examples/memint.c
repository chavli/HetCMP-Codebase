#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <signal.h>

#define GIGABYTE 1073741824

void sig_end(int);
void stress_cpu(void);
void stress_memio(void);
void stress_fileio(void);


void stress_cpu(void){
  unsigned int iseed = (unsigned int)time(NULL);
  float rando;
  srand (iseed);
  time_t start;
  time(&start);
    
  while(time(0) - start < 30){
    rando = rand();
    rando *= 1.9987823;
    rando /= .977288;
    float result = cosh( sqrt(rando) * cos(rando) * sin(rando) * acos(rando) * asin(rando) * atan(rando) * atan2(rando, rando) ) ;
    result = result * rando;
    result = result / pow(rando, 2.999999998);
    result = ((int)result << 17) * 1.0000000001;
    srand ((long int)result);
  }
}

void stress_memio(void){


  time_t start;
  time(&start);

  while(time(0) - start < 60){
    long int i = 0;
    char *pool = (char *)malloc(GIGABYTE);
    for(i=0;i<16777216;i++){
      *(pool+(i*64)) = 'F';
    }
    free(pool);
  }
}


int main (int argc, char **argv){
  //stress_cpu();
  stress_memio();
  return 0;
}
