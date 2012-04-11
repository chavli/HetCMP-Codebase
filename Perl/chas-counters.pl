#Auth: Nathan Hega
#Date: 3.18.12
#File: counters.pl
#Desc: A revised version of allcounters.pl that will take in only three parameters
#(to simplify things) one parameter for the name of the resulting .txt .csv and 
#.sh files and then one file that contains the counters the user would like to run
#and last but not least an input with the process to execute on task

use Getopt::Long;
use LWP::Simple;
#get command line arguments
GetOptions("process|p=s" => \$process , "output|o=s" => \$fileout, "counter|c=s"=>\$counter, "-a"=>\$auto);


#throw error if they are not properly defined
if(!(defined $process) || !(defined $fileout) || !(defined $counter)){
	print "Error: Incorrect arguments \n";
	print "Usage: counters.pl \n-process|p <process_to_run> \n-output|o <filename for output data (.sh .csv .txt)> 
	-counter|c <file containing counter names>\n[-a] include to automate the creation and execution of the shell script\n";
	exit;
}

open (INPUT, "$counter") or die("Error: could not open $counter \n");
#send data to array
@input_data = <INPUT>;
#close file
close INPUT;
open (OUTPUT, ">>$fileout.sh") or die("Error: could not open the file -> $fileout.sh <- \n");

$ct = 0;
#get total length of counters
$counter_amt = @input_data;
$counter_track = 1;
$flag = 0;
foreach $val (@input_data){
	chomp $val;
	#if we are on last counter we need to react accordingly	
	if($counter_track == $counter_amt){
		print OUTPUT "-e $val $process >> output/$fileout.txt\n";
		$flag = 1;

	}
	if($flag != 1){
		if($ct==3){
			print OUTPUT "-e $val $process >> output/$fileout.txt\n";
			$ct = 0;
			}
		elsif($ct==1 || $ct==2){
			print OUTPUT "-e $val ";
			$ct ++;
		}
		elsif($ct==0){
			print OUTPUT "task -ip -e $val ";
			$ct++;
		}
		$counter_track++;
	}
	
}
print OUTPUT "#this is where I will call the pfm_data_parser \n";
print OUTPUT "perl pfm_data_parser.pl -f output/$fileout.txt -o output/$fileout.csv\n";
close OUTPUT;



if(defined($auto)){
	#system returns execution to the script exec does not
	system("chmod u+x $fileout.sh");
	exec './'.$fileout.'.sh' or die "Could not execute $fileout.sh";
}


