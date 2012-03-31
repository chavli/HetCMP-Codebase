#Auth: Nathan Hega
#Date: 2.23.12
#File: pfm_data_parser.pl
#Desc: Script that will read in the counters provided by perfmon and output them into a file
# that will be an a format that Microsoft Excel will easily parse


use Getopt::Long;
use LWP::Simple;
#get command line arguments
GetOptions("filename|f=s" => \$filein , "output|o=s" => \$fileout);

#throw error if they are not properly defined
if(!(defined $filein) || !(defined $fileout)){
	print "Error: Incorrect arguments \n";
	print "Usage: pfm_data_parser.pl -filename|f <input_filename.txt> -output|o <output_filename.csv>\n";
	exit;
}

#open input data file
open (INPUT, "$filein") or die("Error: could not open the file -> $filein <- \n");

#send file to array
@input_data = <INPUT>;
#close file
close INPUT;
#hash to store results
%parse_results = ();
foreach $line (@input_data){
	chomp $line;
	#parse input and begin to hash values
	if($line =~ m/^\s+(\d+)\s(\w+)\s.*$/){
		$value = $1;
		$counter_name = $2; 
		#print "$value $counter_name \n";
		
		#if $counter_name exists, add values to the array pointer sitting there
		if(exists $parse_results{$counter_name}){
			push(@{$parse_results{$counter_name}},$value);
		
		}
		#create array pointer with $value as it's only member
		else{
			$parse_results{$counter_name} = [$value];
			#print "$parse_results{$counter_name} \n";
		}
		
	}
	
}

open (OUTPUT, ">>$fileout") or die("Error: could not open the file -> $fileout <- \n");

#print counter names first for formatting purposes
#create array of array pointers to the actual counter values for formatting purposes
#grab the max lengh of the arrays for the print loop below
$i = 0;
$max_data = 0;
$temp_len = 0;
@placeholder = ();
foreach $cn (keys %parse_results){
	print OUTPUT "$cn,";
	$placeholder[$i] = $parse_results{$cn};
	$temp_len = @{$parse_results{$cn}};
#	print "$temp_len \n";
	if($temp_len > $max_data){
		$max_data = $temp_len;
	}
	$i++;
}
print OUTPUT "\n";
$z;
#print "$max_data\n";
#all arrays have equal length so print out a value of each  seperated by comma
#print loop
for($z=0;$z<$max_data;$z++){	
	for($i=0;$i<@placeholder;$i++){
		if(exists ${@placeholder[$i]}[$z]){
			print OUTPUT "@{@placeholder[$i]}[$z],";
		}
		else{
			print OUTPUT "0,";
		}
	}
	print OUTPUT "\n";
}
#foreach $w (keys  %parse_results){
#	print OUTPUT "$w,\n";
#	@this_ar = @{$parse_results{$w}};
	#print "-----------------------------\n";
#		foreach $vs (@this_ar){
#				print OUTPUT "$vs,\n";
#		}
#}


close OUTPUT;
