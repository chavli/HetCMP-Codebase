
%feature_analysis

training_file = 'full-training.csv';

disp(' ~~~~~~ GREEDY COUNTERS ~~~~~~');
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

features = 10;
all_top = dist(1:features, :);
names = {};

%%
%prepare data for training 
path = sprintf('./training_data/%s',training_file);
thread_data = csvread(path);
norm_data = standardize_m(thread_data, 0);

graph_data = zeros(3, features);

greedy_lim = 4;
greedy_chosen = [];
for j=1:size(all_top, 1)
    
    min_err = Inf;
    greedy_ctr = 0;

    for i=1:size(all_top, 1)
    
        if ~any(greedy_chosen == all_top(i, 1))
            current_ctr = all_top(i, 1);
    
            %only use the counters specified by the extraction
            ctrs = [current_ctr, size(norm_data, 2)];
            working_data = norm_data(:, [greedy_chosen, ctrs]);

            %%
            % training and testing different models
            T = 10;
            all_errs = zeros(3,T);

            for trials=1:T
                K = 10;
                groupings = crossvalind('Kfold', (1:size(working_data, 1)), K);
                avg_err = zeros(3, 1);

                for k=1:K

                    test_data = working_data(find(groupings == k), :);
                    train_data = working_data(find(groupings ~= k), :);
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
            
            if( mean(mean(all_errs, 2), 1) < min_err )
                min_err = mean(mean(all_errs, 2), 1);
                greedy_ctr = current_ctr;  
            end

        end
    end
    greedy_chosen = horzcat(greedy_chosen, greedy_ctr);
    
    if length(greedy_chosen) == greedy_lim
        break;
    end
end
disp(greedy_chosen);