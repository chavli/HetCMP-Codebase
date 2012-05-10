"""

  Cha Li
  HetCMP Project
  7 May 2012 

  This program takes the output created by performance_analysis.py
  and determines which counters were extracted the most frequently 
  from a set of benchmarks.
  
  Original code was developed in MATLAB and then converted to Python.
"""

#import some libraries
import sys
import os
from operator import itemgetter
import numpy as np


#load the readable counter names from file
label_file = open("labels.txt", "r");
counter_names = label_file.read();
counter_names = counter_names.split("\n");

NUM_COUNTERS = len(counter_names);  #total number of counters

#number of counters to be extracted, determined by args. default = 10
if len(sys.argv) > 1:
  try:
    TOP = int(sys.argv[1]);
    print "extracting " + sys.argv[1] + " counters";
  except:
    print "ERROR: unrecognized extraction value, defaulting to 10";
    print "FORMAT: py extract_common.py <# to extract>";
    TOP = 10;
else:
  print "extracting 10 counters";
  TOP = 10;                           

#initialize data structure to keep track of how many times each counter was
#extracted
data = [];
for i in range(NUM_COUNTERS):
  data.append((i+1, 0)); 

#path to folder containing extraction results
result_dir = "./benchmark-analysis";
csvs = os.listdir(result_dir);

#read each output file and see which counters were extracted for that instance
for csv_file in csvs:
   
  fin = open(result_dir +"/" +csv_file, "r");
  counters = np.load(fin);


  for counter in counters:
    if counter != "":
      pair = data[int(counter) - 1];
      data[int(counter) - 1] = (int(counter), pair[1] + 1);
          

#sort the counters in descending order by number of times they were extracted
#and display them
data = sorted(data, key=itemgetter(1), reverse=True);
for pair in data[0:TOP]:
  print "%50s %4d|[%d]" % (counter_names[int(pair[0]) - 1] , int(pair[0]) \
  , int(pair[1]) ),;   
  print ("+" * int(pair[1]));

