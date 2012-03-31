#
# parsecmgmt-serial-all.pl
#
# runs all parsec benchmarks in serial mode.
#
# input: parsec input file to use (ie simlarge)
#

#all benchmarks which support gcc-serial
@benchmarks = ("blackscholes", "bodytrack", "canneal", "facesim", "ferret", "fluidanimate", "freqmine", "raytrace", "streamcluster", "vips", "x264");

use Getopt::Long;
use LWP::Simple;
GetOptions("parsecinput|i=s" => \$input);

foreach $benchmark (@benchmarks){
  print "running: ".$benchmark."...";

  #run the benchmark
  system("task3 -ip -o parsec-serial-results/".$benchmark."-".$input." -e PERF_COUNT_HW_CACHE_REFERENCES -e PERF_COUNT_HW_CACHE_MISSES -e PERF_COUNT_HW_CACHE_LL -e PERF_COUNT_HW_CPU_CYCLES parsecmgmt -a run -p ".$benchmark." -c gcc-serial -i ".$input);

  #check status of command
  if ( $? == -1 ){
    print ."FAILED $!\n";
  }
  else{
    printf "DONE %d\n", $? >> 8;
  }

  #cleanup 
  system("parsecmgmt -a fullclean");

}




