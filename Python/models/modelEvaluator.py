"""
  modelEvaluator.py

  Cha Li
  19 May 2012

  This class contains convenient methods used to calculate the performance of
  a learning model. Performance is measured using misclassification rates and
  confusion matrices.

  Currently, only binary classification tasks are handled by this class.

  variable naming:
    *_v indicates a vector (array)
    *_m indicates a matrix (2-D array)
    all others can be assumed to be scalars
"""
import numpy as np;
import math

class modelEvaluator:

  #
  # __init__
  #   the constructor
  #
  # arguments:
  #   binary  - boolean value specifying if labels are 0-1
  #
  # returns:
  #   Nothing
  #
  def __init__(self, binary):
    self.binary = binary;
  
  #
  # confusionMatrix
  #   creates the confusion matrix given the predicted labels and actual
  #   labels
  #
  #   the confusion matrix is defined as follows: 
  #     
  #       0   1
  #   0   TN  FN
  #   1   FP  TP
  #
  #   TN  - True Negative
  #   FN  - False Negative
  #   TP  - True Positive
  #   FP  - False Positive
  #
  #   columns are true values, rows are predicted values
  #
  # arguments:
  #   actual_v  - the true labels for each sample
  #   predict_v - the predicted labels for each sample
  #
  # returns:
  #   conf_m  - the confusion matrix
  #
  def confusionMatrix(self, actual_v, predict_v):
    conf_m = None;

    try:
      if not self.binary:
        print "Categorical and Continuous data not handled by this script yet";
      elif not len(actual_v) == len(predict_v):
        print "Vector lengths don't match."
      else: 
        conf_m = np.zeros((2, 2))

        for i in range(len(actual_v)):
          if actual_v[i] == 0 and predict_v[i] == 0: conf_m[0, 0] += 1;
          elif actual_v[i] == 0 and predict_v[i] == 1: conf_m[1, 0] += 1;
          elif actual_v[i] == 1 and predict_v[i] == 0: conf_m[0, 1] += 1;
          elif actual_v[i] == 1 and predict_v[i] == 1: conf_m[1, 1] += 1;
    
    except TypeError:
      print "confusionMatrix: Arguments must be vectors."
      
    return conf_m;
  
  #
  # misclassCount
  #
  # count the differences in classification labels
  #   
  # arguments:
  #   actual_v  - vector of true class labels
  #   predict_v - vector of predicted class labels
  #
  # returns:
  #   misclass_v  - a vector containing the misclassification count and
  #                 misclassification rate, respectively.
  #
  def misclassCount(self, actual_v, predict_v):
    misclass_v = None;
    
    try:
      if not self.binary:
        print "Categorical and Continuous data not handled by this script yet.";
      elif not len(actual_v) == len(predict_v):
        print "Vector lengths don't match."
      else:
        misclass_v = np.zeros((1, 2));
        for i in range(len(actual_v)):
          if not predict_v[i] == actual_v[i]: misclass_v[0] += 1;

        misclass_v[0, 1] = misclass_v[0, 0] / len(actual_v);
      
    except TypeError:
      print "misclassError: Arguments must be vectors."
    
    return misclass_v;
