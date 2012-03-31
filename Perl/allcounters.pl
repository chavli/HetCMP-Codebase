#Auth: Nathan Hega
#Date: 3.14.12
#File: allcounters.pl
#Desc: Script that will read in the event_names.txt file and 
#compose a script that will run all counters found in event_names.txt
#on the specified process (memint,cpuint, or parsec process)

use Getopt::Long;
use LWP::Simple;
#get command line arguments
GetOptions("process|p=s" => \$process , "output|o=s" => \$fileout, "datafile|d=s" => \$dataout, "graph|g=s" => \$graph);


#throw error if they are not properly defined
if(!(defined $process) || !(defined $fileout) || !(defined $dataout) || !(defined $graph)){
	print "Error: Incorrect arguments \n";
	print "Usage: allcounters.pl -process|p <process_to_run> -output|o <output_filename.sh> -datafile|d <data_file.txt> -graph|g <graph.csv>\n";
	exit;
}
#else{
#	print "\$process is: $process\n";
#	print "\$fileout is: $fileout\n";
#	print "\$dataout is: $dataout\n";
#	print "\$graph is: $graph\n";
#}


open (INPUT, "event_names") or die("Error: could not open event_names \n");
#send data to array
@input_data = <INPUT>;
#close file
close INPUT;
open (OUTPUT, ">>$fileout") or die("Error: could not open the file -> $fileout <- \n");

$ct = 0;
#get total length of counters
$counter_amt = @input_data;
$counter_track = 1;
$flag = 0;
foreach $val (@input_data){
	chomp $val;
	#if we are on last counter we need to react accordingly	
	if($counter_track == $counter_amt){
		print OUTPUT "-e $val $process >> $dataout\n";
		$flag = 1;

	}
	if($flag != 1){
		if($ct==3){
			print OUTPUT "-e $val $process >> $dataout\n";
			#print OUTPUT "\$ct is $ct (3)";
			$ct = 0;
			}
		elsif($ct==1 || $ct==2){
			print OUTPUT "-e $val ";
			#print OUTPUT "\$ct is $ct (1-2)";
			$ct ++;
		}
		elsif($ct==0){
			print OUTPUT "task -ip -e $val ";
			#print OUTPUT "\$ct is $ct (0)";
			$ct++;
		}
		$counter_track++;
	}
	
}
print OUTPUT "#this is where I will call the pfm_data_parser \n";
print OUTPUT "perl pfm_data_parser.pl -f $dataout -o $graph\n";
close OUTPUT;
