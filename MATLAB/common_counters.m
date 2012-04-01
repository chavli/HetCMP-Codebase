clc
clear

f = fopen('parsec-all-counters/labels.txt', 'r');
counter_names = textscan(f, '%s');

infiles = dir(fullfile('./parsec-all-counters','*output'));


all_counters = [];
for f=1:size(infiles, 1)
    filename = sprintf('./parsec-all-counters/%s', infiles(f).name);
    data = load(filename);
    all_counters = horzcat(all_counters, data);
end

[dist, centers] = hist(all_counters, max(all_counters));
hist(all_counters, max(all_counters));

dist = vertcat(1:139, dist)';
dist = sortrows(dist, -2);
%dist

features = 20;
top = dist(1:features, :);
names = {};

disp('common counters');
for i=1:features
    disp(sprintf('%d \t %s', top(i, 1), counter_names{1}{top(i, 1)}));
    names = horzcat(names, counter_names{1}{top(i, 1)});
end


%%
%prepare data for training 

thread_data = csvread('./training_data/all-training.csv');
phase_data = csvread('./training_data/training-phase.csv');

norm_data = normalize_m(thread_data, 0);
norm_phase = normalize_m(phase_data, 0);


%{
    6 - L3-CACHE-MISSES*
    13 - CPU-CLK-UNHALTED*
    32 - PERF-COUNT-HW-CPU-CYCLES
    47 - RETIRED-INSTRUCTIONS*
    68 - MEMORY-CONTROLLER-REQUESTS*
    98 - PERF-COUNT-HW-INSTRUCTIONS
    118 - PERF-COUNT-HW-CACHE-LL

    *used by task3.c

    IPC = RETIRED-INSTRUCTIONS / CPU-CLK-UNHALTED
%}

%ctrs = [6];
ctrs = top(:, 1)';

figure
plot(thread_data(:, ctrs));

%only use the counters specified by the extraction
cols = [ctrs, size(norm_data, 2)];
norm_data = norm_data(:, cols);

%norm_data = horzcat(ipc, norm_data);

trials = 100;

avg_err = 0;
avg_conf = [0,0;0,0];



%%
% training and testing different models

for t=1:trials
    [train_data, test_data] = divideset2(norm_data, .25);
    attrs_n = size(test_data, 2);

    %logistic regression 
    %weights_v = online_glr(train_data, size(train_data, 1), 0, []);
    %[predict_y, posterior_y] = binary_logistic_predict(test_data, weights_v);

    %support vector machine (SVM)
    %[weights_v, bias] = svml(train_data(:, 1:attrs_n - 1), train_data(:, attrs_n), 5);
    %[predict_y, posterior_y] = binary_svm_predict(test_data(:,1:attrs_n-1), weights_v, bias); 
    
    %decision tree
    [train_data, test_data] = divideset2(norm_data, .25);
    attrs_n = size(test_data, 2);
    tree = classregtree(train_data(:, 1:attrs_n - 1), train_data(:, attrs_n), 'names', names, 'method', 'classification');
    predict_y = cell2mat(eval(tree, test_data(:, 1:attrs_n - 1)));
    predict_y = str2num(predict_y);

        
    [conf_m, stats_m] = binary_confusion_matrix(test_data(:,attrs_n), predict_y);
    [err_count, err_rate] = misclass_count(test_data(:,attrs_n), predict_y);
    
    avg_err = avg_err + err_rate;
    avg_conf = avg_conf + conf_m; 
end

avg_conf ./ trials
avg_err / trials