

%feature_analysis

%the training dataset
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

%%
%decide which counters to evaluate

%original counters used to measure IPC and LLCM
%{
    6 - L3-CACHE-MISSES*
    13 - CPU-CLK-UNHALTED*
    47 - RETIRED-INSTRUCTIONS*
    68 - MEMORY-CONTROLLER-REQUESTS*
    IPC = RETIRED-INSTRUCTIONS / CPU-CLK-UNHALTED2
%}

%choose or make a set of counters to evaluate
features = 10;
%top = [103,0];
%top = dist(1:features, :);          %use top extracted features
%top = [6,0;47,0;13,0;];       %use IPC and LLCM counters
%top = [103,0;13,0;67,0;48,0;];    %use best 4 extracted features
top = [103,0;13,0;111,0;120,0;];    %greedy counters
names = {};

disp('common counters');
for i=1:size(top, 1)
    disp(sprintf('%d \t %s', top(i, 1), counter_names{1}{top(i, 1)}));
    names = horzcat(names, counter_names{1}{top(i, 1)});
end


%%
%prepare data for training 
path = sprintf('./training_data/%s',training_file);
thread_data = csvread(path);
norm_data = standardize_m(thread_data, 0);

ctrs = top(:, 1)';

%only use the counters specified by the extraction
cols = [ctrs, size(norm_data, 2)];
norm_data = norm_data(:, cols);

%%
% training and testing different models
disp('----- extracted results -----');
T=10;
all_errs = zeros(3,T);

for trials=1:T
    K = 10;
    groupings = crossvalind('Kfold', (1:size(norm_data, 1)), K);
    avg_err = zeros(3, 1);
    disp(sprintf('iteration %d', trials));
    for k=1:K

        test_data = norm_data(find(groupings == k), :);
        train_data = norm_data(find(groupings ~= k), :);
        attrs_n = size(test_data, 2);
        
        %{
        %logistic regression 1
        weights_v = online_glr(train_data(:, 1:attrs_n-1), train_data(:, attrs_n), size(train_data, 1), 0, []);
        [predict_y, posterior_y] = binary_logistic_predict(test_data(:, 1:attrs_n-1), weights_v);
        [err_count, err_rate] = misclass_count(test_data(:,attrs_n), predict_y);        
        avg_err(1, 1) = avg_err(1, 1) + err_rate;
        %}
        
        %support vector machine (SVM) 2 
        non_zero = find( std(train_data(1:size(train_data, 1),:)) ~= NaN ); %only for all counters
        non_zero = 1:attrs_n-1;
        [weights_v, bias] = svml(train_data(:, non_zero), train_data(:, attrs_n), 5);
        [predict_y, posterior_y] = binary_svm_predict(test_data(:,non_zero), weights_v, bias); 
        [err_count, err_rate] = misclass_count(test_data(:,attrs_n), predict_y);
        avg_err(2, 1) = avg_err(2, 1) + err_rate;
        
        %{
        %decision tree 3
        tree = classregtree(train_data(:, 1:attrs_n - 1), train_data(:, attrs_n), 'names', names, 'method', 'classification');    
        predict_y = cell2mat(eval(tree, test_data(:, 1:attrs_n - 1)));
        predict_y = str2num(predict_y);
        [err_count, err_rate] = misclass_count(test_data(:,attrs_n), predict_y);
        avg_err(3, 1) = avg_err(3, 1) + err_rate;
        %}
        
    end
    all_errs(:, trials) = avg_err / K;
end

disp('average error');
disp(mean(all_errs, 2));