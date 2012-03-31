clc
clear

labels = importdata('parsec-all-counters/labels.txt');
csv_file = 'phase.csv';
data_raw = load(sprintf('parsec-all-counters/%s',csv_file));

plot(data_raw);

num_ctrs = length(labels);
data_raw = vertcat((1:num_ctrs), data_raw);

samples_n = size(data_raw, 1);

%get rid of columns of all 0's
m0 =  mean(data_raw(2:samples_n, :)) == 0;
std0 = std(data_raw(2:samples_n, :)) == 0;
to_rm = find(m0 .* std0);
data_raw(:, to_rm) = [];
cur_labels = data_raw(1, :);

%log mu distribution
[counts_v, centers_v] = histogram_analysis('log(mu) counter distribution', log(mean(data_raw(2:samples_n, :))), 15, 0);




%normalize the data
data_norm = normalize_m(data_raw(2:samples_n, :), 1);
data_norm = vertcat(cur_labels, data_norm);



%data_norm = normalize_m(data_raw(2:samples_n, :), 1);
%data_norm = vertcat((1:num_ctrs), data_norm); %label the data

%cov_m = cov(data_norm);

%mean_v = mean(cov_m);
%std_v = std(cov_m);





%{
for i=1:size(data_raw, 2)
    delta = 2;
    [data_clean, m, s] = rm_outliers(data_raw(:, i), delta);

    mu = m * ones(size(data_clean, 1), 1);
    sigma = s * ones(size(data_clean, 1), 1);

    figure
    hold on
    plot(data_raw(:, i), 'b');
    plot(data_clean, 'c');

    plot(mu, 'r')
    plot(mu + sigma, 'g')
    plot(mu - sigma, 'g')
    plot(mu + delta*sigma, 'y')
    plot(mu - delta*sigma, 'y')
    
end
%}