"""
  
  Cha Li
  HetCMP Project
  7 May 2012

  Statistical Analysis for a set of counters describing the behavior of a
  thread over its lifetime. Given a dataset (CSV file) with M samples and N
  counters, this script reduces the total number of counters to a smaller
  subset of counters which represent the original data most completely.
  This is done through covariance analysis. The extracted counters are then
  used in various learning models to classify the phase of the thread
  for each sample.

  Original code written in MATLAB
"""

import os, sys, csv
import numpy as np
from operator import itemgetter

#performance constants
TOP = 4;            #cut off ranking when determining uniqueness 
CORR_THRESH = .75;  #correlation threshold used for grouping
COVERAGE = .3;      #percentage of removed counters to be used

AXIS_COLS = 1;
AXIS_ROWS = 0;


#read the file of human-readable counter names
label_file = open("labels.txt", "r");
counter_names = label_file.read();
counter_names = counter_names.split("\n");
NUM_COUNTERS = len(counter_names);


#directory where benchmark data is located
data_dir = "./benchmark-data";
datasets = os.listdir(data_dir);

#process each dataset
for dataset in datasets:
  labels = range(1,NUM_COUNTERS + 1);
  print "\n\n********************************************"
  print "=====> analyzing %s" % dataset
  print "********************************************"
  new_data = [];
  to_rm = [];
  data = csv.reader(open(data_dir + "/" + dataset, "rb")); 


  #convert string dataset to numerical dataset
  for sample in data:
    new_sample = [];
    for variable in sample:
      new_sample.append(int(variable));
    new_data.append(new_sample);


  #add counter labels to dataset
  new_data.insert(0, labels);
  
  #convert dataset in numpy format
  np_dataset = np.array(new_data);

  #remove attributes(counters) containing all zeros, ignore the first row
  #since it contains labels

  for col in range(len(np_dataset[0])):
    attribute = [];
    for row in range(1,len(np_dataset)):
      attribute.append(np_dataset[row][col]);
    
    if np.mean(attribute) == 0 and np.std(attribute) == 0:
      to_rm.append(col); 

  print "\n1]=====> zero filled(unused) counters"
  print np_dataset[([0],to_rm)]
  np_dataset = np.delete(np_dataset, to_rm, axis=AXIS_COLS);

  #create the covariance matrix, and add the counter labels
  labels = np_dataset[0];
  cov_dataset = np.corrcoef(np_dataset[1:], rowvar=0);
  cov_dataset = np.insert(cov_dataset, 0, labels, axis=AXIS_ROWS);

  #see which counters have high inter-counter correlation. highly correlated 
  #counters can be removed (abstracted away through grouping) since they 
  #represent redundant knowledge
  print "\n2]=====> correlated counters [%f]" % CORR_THRESH
  keep = []; destroy = []; groups = [];
  for col in range(len(cov_dataset[0])):
    if col not in destroy:
      members = []; #keep track of counters correlated with this counter
      
      for row in range(1, len(cov_dataset)):
        
        #only consider a counter if:
        # 1. it isn't marked for removal
        # 2. it isn't being compared to itself
        # 3. it isn't marked for being kept
        if cov_dataset[row, col] > CORR_THRESH and \
          (row - 1) not in destroy and \
          (row - 1) != col and \
          (row - 1) not in keep:
          
          members.append(labels[row - 1]);
          if col not in keep:
            keep.append(col);

          destroy.append(row - 1);
      
      if len(members) > 0:
        groups.append((np_dataset[0, col], len(members) ,members));

  #sort groups by descending group size
  groups = sorted(groups, key=itemgetter(1), reverse=True);
  
  print "%10s %15s\t%-15s" % ("counter", "group size", "correlated group" )
  for group in groups:
    print "%10d %15d\t" % (group[0], group[1]),
    print group[2];

  #remove destroyed counters
  destroy = np.array(destroy);
  print "\n3]=====> removed redundant counters"
  print cov_dataset[0, destroy];
  cov_dataset = np.delete(cov_dataset, destroy, axis=AXIS_COLS);
  cov_dataset = np.delete(cov_dataset, destroy + 1, axis=AXIS_ROWS);


  extracted_counters = [];    #hold results of extraction process 

  coverage = 0;
  print "\n4]=====> extracted counter groups"
  while ( float(coverage) / len(destroy) ) < COVERAGE:
    group = groups.pop(0);
    coverage += group[1];
    extracted_counters.append(group[0]);
    extracted_counters += group[2];
    print "%4d\t%s" % (group[0], counter_names[group[0] - 1])

  print "removed counter coverage: %f" % (float(coverage) / len(destroy))

  #calculate the mean and std dev values of the remaining columns for
  #determining uniqueness
  means = np.mean(cov_dataset[1:], axis=AXIS_ROWS);
  stdd = np.std(cov_dataset[1:], axis=AXIS_ROWS);

  #attach labels to means and stdd
  lbl_means = []; lbl_stdd = [];
  for i,label in enumerate(cov_dataset[0]):
    lbl_means.append([label, means[i]]);  
    lbl_stdd.append([label, stdd[i]]);  
  
  #sort these values into ascending order
  np_means = np.abs(np.array(sorted(np.abs(lbl_means), key=itemgetter(1))));
  np_stdd = np.array(sorted(lbl_stdd, key=itemgetter(1)));
  
  #pick out unique counters --> low mean corr and low std dev for corr values
  unique_counters = []
  cut = min(TOP, len(lbl_means));

  for i, counter in enumerate(np_means[:, 0]):
    j = np.nonzero(np_stdd == counter)[0][0];
    if np.average([i, j]) <= (cut - 1):
      unique_counters.append(int(counter))

  print "\n5]=====> unique counters"
  for ctr in unique_counters:
    print "%4d %s" % (ctr, counter_names[ctr - 1]);
    extracted_counters.append(ctr);


  print "\n6]=====> extracted counters"
  extracted_counters = np.unique(extracted_counters);
  print extracted_counters

  #write extracted counters to file
  fname = 'benchmark-analysis/' + dataset + '-output'
  fout = open(fname, "w");
  np.save(fout, extracted_counters);
  fout.close();

  #np.savetxt(fout, extracted_counters, fmt="%d", newline=",", delimiter=" ");

