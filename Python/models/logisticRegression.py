"""
  logisticRegression.py

  Cha Li
  19 May 2012


  Online Logistic Regression

  This script calculates the decision boundry between two discriminant
  functions using gradient descent. Each sample in the given dataset
  is considered one at a time and after  each consideration the weights
  determining the boundary are updated.
  
  The model can also be trained one sample at a time (online) by bypassing
  the call to run() and using step() directly with the new data (sample)

  Logistic Regression is a supervised learning model.

  variable naming:
    *_v indicates a vector (array)
    *_m indicates a matrix (2-D array)
    all others can be assuned to be scalars
"""

import math;
import numpy as np;

class logisticRegression:
  
  #
  # __init__
  #   the constructor
  #
  # arguments:
  #   dataset_m - a matrix of data where columns are attributes with the final
  #               column being the labels. rows represent individual samples.
  #               the dataset -must- contain the labels. typically this is the
  #               training data.
  #
  #   binary    - are the labels binary values 0-1. the 0-1 requirement must
  #               be followed.
  #
  # returns:
  #   Nothing
  #
  def __init__(self, dataset_m, binary):

    size_v = dataset_m.shape;

    #the true labels for each sample
    self.truth_v = dataset_m[:, size_v[1]-1];
    
    #append the bias values to each sample
    self.samples_m = dataset_m[:, 0:size_v[1]-1]; 
    bias_v = np.ones((size_v[0],1));
    self.samples_m = np.hstack((bias_v, self.samples_m));
   
    #initialize weights to all 1's
    self.weights_v = np.ones((1, self.samples_m.shape[1]));
    
    self.binary = binary;

  #
  # run
  #   trains the logistic regression model on the given training set. samples
  #   are processed in the order they appear in the dataset and are processed
  #   exactly once.
  #
  # arguments:
  #   None
  #
  # returns:
  #   self.weights_v  - the vector of weights used to determine the decision 
  #                     boundary, where the first value is the bias weight.
  #
      
  def run(self):
    #process each sample
    for n, sample_v in enumerate(self.samples_m, start=1):
      sample_v = np.reshape(sample_v, (1, self.samples_m.shape[1]));

      #this function determines the influnce of each sample on the overall 
      #model, It can be tinkered with.
      alpha = 1.0 / math.sqrt(n);
      
      #update weight values
      self.step(sample_v, self.binary, True, self.truth_v[n-1], alpha);
    
    return self.weights_v;
  
  #
  # eval
  #   predict the labels of the given dataset using the currently trained 
  #   model.
  #
  # arguments:
  #   dataset_m - a matrix of data where columns are attributes with the final
  #               column being the labels. rows represent individual samples.
  #               typically this is the test data which contains different 
  #               samples than the training data but follows similar 
  #               distributions.
  #
  #   complete  - whether or not the given dataset contains the final column of
  #               sample labels.
  #
  # returns:
  #   predict_v - a vector of label predictions for each sample.
  #
  def eval(self, dataset_m, complete=False):

    #remove the labels if necessary
    if complete:
      size_v = dataset_m.shape
      samples_m = dataset_m[:, 0:size_v[1]-1]; 
    else:
      samples_m = dataset_m;
    
    #add the bias column
    size_v = samples_m.shape 
    bias_v = np.ones((size_v[0],1));
    samples_m = np.hstack((bias_v, samples_m));

    predict_v = np.array([]);

    #predict each sample
    for sample_v in samples_m:
      sample_v = np.reshape(sample_v, (1, samples_m.shape[1]));
      predict = self.step(sample_v, self.binary, False);
      predict_v = np.append(predict_v, predict);
    
    return predict_v;
 
  #
  # step
  #   This function is used by run() and eval() to train the model or 
  #   to label a sample, respectively. step() can also be called directly by
  #   an external program to train the model in an online setting (new samples
  #   given directly to the model as they are seen).
  #
  # arguments:
  #   sample_v  - the sample currently being processed
  #   binary    - whether or not the labels are binary labels
  #   train     - whether or not the sample is for training the model
  #   truth     - the true label of the sample (used in training)
  #   alpha     - the influence of the sample (used in training)
  #
  # returns:
  #   guess     - the predicted label for the given sample
  #
  def step(self, sample_v, binary=False, train=True, truth=1, alpha=1):
    
    #dot product of current sample and weights, this value is then passed to
    #the sigmoid function
    dot = np.dot(sample_v, self.weights_v.T).item(0);
    guess = self.__sigmoid(dot);

    #update weights if sample is used for training
    if train:
      self.weights_v = self.weights_v + alpha * (truth - guess) * sample_v;
    
    #round guess if binary labels are used.
    if binary:
      if guess >= .5: guess = 1;
      else: guess = 0;
    
    return guess;
  
  #
  # sigmoid (private)
  #   the sigmoid function.
  #
  # arguments:
  #   x - a scalar value used in the equation
  #
  # returns:
  #   a scalar result of the equation
  #
  def __sigmoid(self, x):
    return 1.0 / (1.0 + math.exp(-x));

