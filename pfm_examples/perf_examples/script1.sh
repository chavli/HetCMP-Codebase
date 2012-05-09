#script

cmd=$1  #cmd to run
prefix=$2   #output file prefix 

#run mem intensive test first
./task -p -e PERF_COUNT_HW_CACHE_REFERENCES -e PERF_COUNT_HW_CACHE_MISSES -e PERF_COUNT_HW_CACHE_LL -e PERF_COUNT_HW_CPU_CYCLES $cmd > test_results/"$prefix"res.txt
./task -p -e PERF_COUNT_HW_INSTRUCTIONS -e PERF_COUNT_SW_PAGE_FAULTS $cmd >> test_results/"$prefix"res.txt
#run perl script on the result data, it will give us a .csv 
# "Usage: pfm_data_parser.pl -filename|f <input_filename.txt> -output|o <output_filename.csv>\n" 
perl test_results/pfm_data_parser.pl -f test_results/"$prefix"res.txt -o "$prefix"graph.csv

