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
#define MEMMODE 1
#define CPUMODE 0

void sig_end(int);
void stress_cpu(int);
void stress_memio(int);
void stress_fileio(void);
double cycles = 0;
int minrun = 0;
int maxrun = 0;
FILE *fp;


void stress_cpu(int seconds){
  unsigned int iseed = (unsigned int)time(NULL);
  float rando;
  srand (iseed);
  time_t start;
  time(&start);
    

  while(time(0) - start < seconds){
    fprintf(fp, "%d", 0);
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

void stress_memio(int seconds){
  time_t start;
  time(&start);


  while(time(0) - start < seconds){
    fprintf(fp, "%d", 1);
    long int i = 0;
    char *pool = (char *)malloc(GIGABYTE);
   for(i=0;i<16777216;i++){
      *(pool+(i*64)) = 'F';
    }
    free(pool);
  }
}


int main (int argc, char **argv){
  //shared file to write the current phase of this program
  fp = fopen("/afs/cs.pitt.edu/projects/mosse/HetCMP/home/chavli/Shared/randphase.state", "w");


 int i;
  srand( time(NULL));
	if(argc == 4){	
		//arg 0 is number of cycles
  		cycles = atof(argv[1]);
	//	printf("argv1:%d ",cycles);	
		//arg 1 is min time (sec) to run stress
  		minrun = atof(argv[2]);
	//	printf("argv2:%d ",minrun);	
		//arg 2 is max time (sec) to run stress
		maxrun = atof(argv[3]);
	//	printf("argv3:%d ",maxrun);	
	
	for(i=0;i<cycles;i++){
  		
	//		t1 = time(NULL);

  			stress_memio( rand() % (maxrun - minrun + 1) + minrun);

  			stress_cpu( rand() % (maxrun - minrun + 1) + minrun);
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
  fclose(fp);

	return 0;
}





