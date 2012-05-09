clc
clear

%feature_analysis

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

[dist, centers] = hist(all_counters, max(all_counters));

dist = vertcat(1:139, dist)';
dist = sortrows(dist, -2);

%use extracted counters
features = 10;
top = dist(1:features, :);
names = {};

disp('common counters');
for i=1:size(top, 1)
    disp(sprintf('%d \t %s', top(i, 1), counter_names{1}{top(i, 1)}));
    names = horzcat(names, counter_names{1}{top(i, 1)});
end


%%
%prepare data for analysis 
path = sprintf('./training_data/%s',training_file);
thread_data = csvread(path);
norm_data = standardize_m(thread_data, 0);

ctrs = top(:, 1)';

%only use the counters specified by the extraction
cols = [ctrs, size(norm_data, 2)];
norm_data = norm_data(:, cols);

%%
%use a decision tree to pick out the best counters
K = 10; T=100;
MAX_DEPTH = 20; 
avg_err = zeros(T, MAX_DEPTH);
trial_error = zeros(1, MAX_DEPTH);

for trial=1:100
    groupings = crossvalind('Kfold', (1:size(norm_data, 1)), K);
    test_data = norm_data(find(groupings == 4), :);
    train_data = norm_data(find(groupings ~= 4), :);

    attrs_n = size(norm_data, 2);
    tree = classregtree(train_data(:, 1:attrs_n - 1), train_data(:, attrs_n), 'names', names, 'method', 'classification', 'prune', 'on');    
    %disp('-----------------------');ctrs
    for level=0:max(prunelist(tree))
        p_tree = prune(tree, 'level', level);
        predict_y = cell2mat(eval(p_tree, test_data(:, 1:attrs_n - 1)));
        predict_y = str2num(predict_y);
        [err_count, err_rate] = misclass_count(test_data(:,attrs_n), predict_y);
        trial_error(level+1) = err_rate;
        %disp(sprintf('%d \t %f', level, err_rate));
    end
    avg_err(trial, :) = trial_error;
end

result = mean(avg_err, 1)
plot(0:11, result(1:12));
view(tree);