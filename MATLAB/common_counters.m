clc
clear

feature_analysis

training_file = 'full-training.csv';

disp(' ~~~~~~ COMMON COUNTERS ~~~~~~');
f = fopen('parsec-all-counters/labels.txt', 'r');
counter_names = textscan(f, '%s');

infiles = dir(fullfile('./parsec-all-counters','*output'));


all_counters = [];
for f=1:size(infiles, 1)
    filename = sprintf('./parsec-all-counters/%s', infiles(f).name);
    data = load(filename);
    all_counters = horzcat(all_counters, data);
end

figure
[dist, centers] = hist(all_counters, max(all_counters));
hist(all_counters, max(all_counters));

dist = vertcat(1:139, dist)';
dist = sortrows(dist, -2);



%{
    6 - L3-CACHE-MISSES*
    13 - CPU-CLK-UNHALTED*
    32 - PERF-COUNT-HW-CPU-CYCLES
    47 - RETIRED-INSTRUCTIONS*
    68 - MEMORY-CONTROLLER-REQUESTS*
    98 - PERF-COUNT-HW-INSTRUCTIONS
    118 - PERF-COUNT-HW-CACHE-LL

    *used by task3.c

    IPC = RETIRED-INSTRUCTIONS / CPU-CLK-UNHALTED2
%}

%disp(dist(1:10, :));
features = 4;
%foo = [7, 9, 3, 4];
%foo = [3, 9];
%top = dist(foo, :);
%top = dist(1:features, :);
top = [6,0;47,0;13,0;68,0;];
%top = [6,0;13,0;];
names = {};

disp('common counters');
for i=1:features
    disp(sprintf('%d \t %s', top(i, 1), counter_names{1}{top(i, 1)}));
    names = horzcat(names, counter_names{1}{top(i, 1)});
end


%%
%prepare data for training 
path = sprintf('./training_data/%s',training_file);
thread_data = csvread(path);
%norm_data = thread_data;
norm_data = standardize_m(thread_data, 0);

ctrs = top(:, 1)';

%figure
%plot(thread_data(:, ctrs));

%only use the counters specified by the extraction
cols = [ctrs, size(norm_data, 2)];
norm_data = norm_data(:, cols);

%norm_data = horzcat(ipc, norm_data);


%%
% training and testing different models
disp('----- extracted results -----');
all_errs = zeros(3,100);

for trials=1:100
    K = 10;
    groupings = crossvalind('Kfold', (1:size(norm_data, 1)), K);
    avg_err = zeros(3, 1);
    
    for k=1:K

        test_data = norm_data(find(groupings == k), :);
        train_data = norm_data(find(groupings ~= k), :);
        attrs_n = size(test_data, 2);

        %logistic regression 1
        weights_v = online_glr(train_data, size(train_data, 1), 0, []);
        [predict_y, posterior_y] = binary_logistic_predict(test_data, weights_v);
        [err_count, err_rate] = misclass_count(test_data(:,attrs_n), predict_y);        
        avg_err(1, 1) = avg_err(1, 1) + err_rate;
        
        %support vector machine (SVM) 2
        [weights_v, bias] = svml(train_data(:, 1:attrs_n - 1), train_data(:, attrs_n), 5);
        [predict_y, posterior_y] = binary_svm_predict(test_data(:,1:attrs_n-1), weights_v, bias); 
        [err_count, err_rate] = misclass_count(test_data(:,attrs_n), predict_y);
        avg_err(2, 1) = avg_err(2, 1) + err_rate;
        
        %decision tree 3
        tree = classregtree(train_data(:, 1:attrs_n - 1), train_data(:, attrs_n), 'names', names, 'method', 'classification');    
        predict_y = cell2mat(eval(tree, test_data(:, 1:attrs_n - 1)));
        predict_y = str2num(predict_y);
        [err_count, err_rate] = misclass_count(test_data(:,attrs_n), predict_y);
        avg_err(3, 1) = avg_err(3, 1) + err_rate;

    end
    %disp(avg_conf / K);
    %disp(avg_err / K);
    all_errs(:, trials) = avg_err / K;
end

disp('average error');
disp(mean(all_errs, 2));
disp('average std');
disp(std(all_errs, 0, 2));


%%
%independent run of the decision tree against all counters of phase data
%{
disp('----- baseline -----');
all_errs = zeros(1,100);

%for trials=1:100

    K = 10;
    groupings = crossvalind('Kfold', (1:size(thread_data, 1)), K);
    avg_conf = [0,0; 0,0];
    avg_err = 0;

    for k=1:K

        test_data = thread_data(find(groupings == k), :);
        train_data = thread_data(find(groupings ~= k), :);

        attrs_n = size(test_data, 2);
        all_tree = classregtree(train_data(:, 1:attrs_n - 1), train_data(:, attrs_n), 'names', counter_names{1}, 'method', 'classification');
        predict_y = cell2mat(eval(all_tree, test_data(:, 1:attrs_n - 1)));
        predict_y = str2num(predict_y);

        [conf_m, stats_m] = binary_confusion_matrix(test_data(:,attrs_n), predict_y);
        [err_count, err_rate] = misclass_count(test_data(:,attrs_n), predict_y);

        avg_conf = avg_conf + conf_m;
        avg_err = avg_err + err_rate;
    end

    %disp(avg_conf / K );
    %disp(avg_err / K);
    all_errs(trials) = avg_err / K;
%end
disp('average error');
disp(mean(all_errs));
disp('average std');
disp(std(all_errs));
%}