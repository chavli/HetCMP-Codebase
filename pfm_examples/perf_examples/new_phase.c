/*Modification to phase.c that will take user input and 
 *run mem int and cpu int code for whatever amount of time
 *the user specifies
 * */

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
double cycles = 0;
double memrun = 0;
double cpurun = 0;

void stress_cpu(void){
  unsigned int iseed = (unsigned int)time(NULL);
  float rando;
  srand (iseed);
  time_t start;
  time(&start);
    
  while(time(0) - start < cpurun){
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

  while(time(0) - start < memrun){
    long int i = 0;
    char *pool = (char *)malloc(GIGABYTE);
    for(i=0;i<16777216;i++){
      *(pool+(i*64)) = 'F';
    }
    free(pool);
  }
}


int main (int argc, char **argv){
 int i; 
	if(argc == 4){	
		//arg 0 is number of cycles
  		cycles = atof(argv[1]);
	//	printf("argv1:%d ",cycles);	
		//arg 1 is memint time to run
  		memrun = atof(argv[2]);
	//	printf("argv2:%d ",memrun);	
		//arg 2 is cpuint
		cpurun = atof(argv[3]);
	//	printf("argv3:%d ",cpurun);	
	
	for(i=0;i<cycles;i++){
  		
	//		time_t t1; 
	//		t1 = time(NULL);
  			stress_memio();
			stress_cpu();
	//		time_t t2;
		//	t2 = time(NULL);
		//	double elapsed = difftime(t1,t2);
		//	printf("elapsed time is:  %d \n",elapsed);
		}
	
	}
  	else{
		printf("Wrong number of arguments - argc should be 4 not %d\n",argc);
		printf("arg1 is # of cycles arg2 is time to run memint arg3 is time to run cpuint\n");
	}

	return 0;
}





