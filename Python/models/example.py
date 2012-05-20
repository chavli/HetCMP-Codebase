"""
  example.py

  Cha Li
  19 May 2012

  Example code that illustrates how to use the logisticRegression and 
  modelEvaluator classes

"""

import numpy as np;
from logisticRegression import *;
from modelEvaluator import *;

#load data to use with logistic regression
train_data = np.loadtxt("misc-data/pima_train.csv", delimiter=',');
test_data = np.loadtxt("misc-data/pima_test.csv", delimiter=',');

#create the model and give it the training data. label type
#is specified as boolean
boolean_labels = True;
model = logisticRegression(train_data, boolean_labels);

#run the model on the training data
model.run();


#predict the labels for the test data. complete specifies whether the
#test data contains the column of true labels. needs to be specified
#so model can parse the dataset correctly.
complete = True;
predict = model.eval(test_data, complete);

#create the modelEvaluator, specify labels are boolean
perf = modelEvaluator(boolean_labels);

#display the confusion matrix along with misclassification count and rate
print "===== test dataset =====";
print "Confusion Matrix:"
print perf.confusionMatrix(test_data[:, 8], predict);
print
print "Error Count and Rate:"
print perf.misclassCount(test_data[:, 8], predict);
