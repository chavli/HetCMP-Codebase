%
%
%   feature_analysis.m
%
%   Cha Li
%   CS2002 - HetCMP
%   29 March 2012
%
%   Statistical Analysis for a set of features describing some set of
%   events. Given a dataset of size M with N features (labels not
%   required) this script statistically calculates the features that should
%   be used when determing the labels.
%

clear
clc

%load the input files
f = fopen('parsec-all-counters/labels.txt', 'r');
counter_names = textscan(f, '%s');
data_raw = csvread('parsec-all-counters/ferret.csv');

%label the columns
labels_v = (1:size(data_raw, 2));
data_m = vertcat(labels_v, data_raw);

%%
%remove columns with all 0's (mean, stdev = 0)
%
disp('1] ====== removing zero filled counters ======');
mu0_v = (mean(data_m(2:size(data_m, 1),:)) == 0);
sigma0_v = (std(data_m(2:size(data_m, 1),:)) == 0);
targets_v = find(mu0_v .* sigma0_v);
disp('zero filled counters:');
disp(data_m(1, targets_v));
data_m(:, targets_v) = [];
disp(' ');

%%
%histogram analysis
%
disp('2] ====== histogram dist of log(mu) ======');
mu_v = mean(data_m(2:size(data_m, 1),:));

%show histogram of all the counters based on the log10 of their mean counter value
[count_v, center_v] = histogram_analysis('log(mu)-distribution (20 bins)', log10(mu_v), 20, 1);
bin_width = center_v(2) - center_v(1);
threshold = 0;  %tinkerable
indices = [];

%creating and displaying counters in their bins
for bin=1:20
    
    %find the counters whose mean value falls within the bounds of the
    %current bin
    filter_1 = (log10(mu_v) > (bin - 1)*bin_width);
    filter_2 = (log10(mu_v) <= bin*bin_width);
    new_indices = find(filter_1 .* filter_2);
    disp(sprintf('---- %d ----', bin));
    disp(new_indices);
    
    %remove counters that have a mean value below this threshold
    if bin <= threshold
        indices = horzcat(indices, new_indices);
    end
end
disp(sprintf('removed counters with mu <= 10^%d', threshold));
disp(data_m(1, indices));
data_m(:, indices) = [];    %remove counters listed in indices


%%
% standardize(normalized) the data 
%
data_norm = normalize_m(data_m(2:size(data_m, 1),:), 1);

%label standardized data
data_norm = vertcat(data_m(1, :), data_norm);
figure
plot(data_norm(2:size(data_norm, 1), :));
disp(' ');

%calcuate and label the covariance matrix
cov_m = cov(data_norm(2:size(data_norm, 1), :));
cov_m = vertcat(data_m(1, :), cov_m);

%group counters such that the correlation between all members of the group
%is greater than some defined value (.95). then pick a single counter from
%that group to represent the group
keep = []; destroy = [];
groups = {};    
for col=1:size(cov_m, 2)
    %skip columns marked for destruction
    if any(destroy == col)
        continue
    end
    count = 0;
    members = [];
    %start from row 2 to skip the labels
    for row=2:size(cov_m, 1)
        %don't compare a counter to itself
        if (col + 1) == row
            continue
        end
        
        %remove the row since this column represents it
        if ~any(keep == (row - 1)) && cov_m(row,col) > .95
            if ~any(destroy == row)
                count = count + 1;
                members(length(members) + 1) = cov_m(1, row-1);
                destroy(length(destroy) + 1) = row;
                %keep this column since it's needed to represent the removed
                %row
                if ~any(keep == col)
                    keep(length(keep) + 1) = col;
                end                
            end

        end
    end
    groups = vertcat(groups, {cov_m(1, col), count, members});
end

%%
% list the counters being removed

disp('3] ====== redundant counters removed ======');
disp(cov_m(1, destroy - 1));
cov_m(destroy, :) = [];
cov_m(:, destroy - 1) = [];
disp(' ');


%display the created groups
disp('4] ====== counter groups (ctr #, group size, members) ======');

srt_grps = sortrows(groups, -2); %sort into descending group size
for c=1:length(keep)
    mems = sprintf('%d ', srt_grps{c, 3});
    disp(sprintf('%d\t%d\t%s ', srt_grps{c, 1}, srt_grps{c, 2}, mems));
end
%make sure sum of groups sizes is the same as # destroyed
disp(sprintf('%d = %d', sum(cell2mat(srt_grps(:, 2))), length(destroy)));
disp(' ');

disp('5] ====== extracted counter groups ======');
%define the percentage of destroyed countes you want the chosen groups to
%cover
coverage = .50;

covered = 0; chosen = [];

%pick out largest groups first until coverage percentage is met
while (covered / length(destroy)) <= coverage
    index = length(chosen) + 1;
    chosen(index) = cell2mat(srt_grps(index, 1));
    covered = covered + cell2mat(srt_grps(index, 2));
    disp(sprintf('%d \t %s', cell2mat(srt_grps(index, 1)), counter_names{1}{cell2mat(srt_grps(index, 1))}));
end
disp(' ');
disp(sprintf('removed counter coverage = %f', (covered / length(destroy))));
disp(' ');

%%
%   calculate and display most independent counters (lowest correlation with
%   other counters)
%
disp('6] ====== extracted unique counters ======');
%some statistics about each column of the covariance matrix
avgabscov_v = mean(abs(cov_m(2:size(cov_m, 1),:))); %mean of the abs of each column
avgcov_v = mean(cov_m(2:size(cov_m, 1),:)); %mean of each column
stdcov_v = std(cov_m(2:size(cov_m, 1),:));  %std dev of each column

%label the lists with the appropriate counter number
avgabscov_v = vertcat(cov_m(1, :), avgabscov_v)';
avgcov_v = vertcat(cov_m(1, :), avgcov_v)';
stdcov_v = vertcat(cov_m(1, :), stdcov_v)';


%pick out unique counters
sort_std = sortrows(stdcov_v, 2);   %sort std dev into ascending order
sort_absavg = sortrows(abs(avgcov_v), 2);   %sort into ascending order

%how many to consider from each of the above lists
cut = min(20, size(sort_std, 1)); %tinkerable

%the "best" counters are given by the intersection of the top N of each
%list
best_ctrs = intersect(sort_absavg(1:cut, 1), sort_std(1:cut, 1));
if ~isrow(best_ctrs)
    best_ctrs = best_ctrs';
end

for c=1:length(best_ctrs)
    disp(sprintf('%d \t %s', best_ctrs(c), counter_names{1}{best_ctrs(c)}));
end

disp('7] ====== unique dump ======');
%disp(sort_std);
%disp(sort_absavg);

%%
%   display final graphs
%
the_best_ctrs = horzcat(chosen, best_ctrs);

cols = [];
for i=1:length(the_best_ctrs)
    cols = horzcat(cols, find(data_norm(1, :) == the_best_ctrs(i))) ;
end

figure
plot(data_norm(2:size(data_norm, 1), cols));
legend(counter_names{1}{the_best_ctrs});
title('all discovered counters');

figure
plot(data_norm(2:size(data_norm, 1), cols(1:length(chosen))));
legend(counter_names{1}{the_best_ctrs(1:length(chosen))});
title('best counter groups');

figure
plot(data_norm(2:size(data_norm, 1), cols(length(chosen)+1:length(cols))));
legend(counter_names{1}{the_best_ctrs(length(chosen)+1:length(cols))});
title('most unique counters');
