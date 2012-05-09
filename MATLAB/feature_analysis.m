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

coverage = .3;
top_n = 4;
cor_thresh = .75; %

%load the input files
f = fopen('parsec-all-counters/labels.txt', 'r');
counter_names = textscan(f, '%s');

infiles = dir(fullfile('./parsec-all-counters','*.csv'));

for f=1:size(infiles, 1);
    filename = infiles(f).name;
    %filename = 'facesim.csv';
    disp(sprintf('0] ======loading %s======', filename));
    data_raw = csvread(sprintf('parsec-all-counters/%s', filename));

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
    % standardize(normalized) the data 
    %
    data_norm = standardize_m(data_m(2:size(data_m, 1),:), 1);

    %label standardized data
    data_norm = vertcat(data_m(1, :), data_norm);
    
    %plot all counters

    %figure
    %plot(data_norm(2:size(data_norm, 1), :));

    
    disp(' ');

    %calcuate and label the covariance matrix
    cov_m = cov(data_norm(2:size(data_norm, 1), :));
    cov_m = vertcat(data_m(1, :), cov_m);
    
    orig_cov = cov_m;
    
    %group counters such that the correlation between all members of the group
    %is greater than some defined value (.95). then pick a single counter from
    %that group to represent the group
    keep = []; destroy = [];
    groups = {};    
    for col=1:size(cov_m, 2)
        %skip columns marked for destruction
        if ~any(destroy == col)
            count = 0;
            members = [];
            %start from row 2 to skip the labels
            for row=2:size(cov_m, 1)
                %don't compare a counter to itself

                %remove the row since this column represents it
                if (col + 1) ~= row && ~any(keep == (row - 1)) && cov_m(row,col) > cor_thresh && ~any(destroy == (row-1))
                        count = count + 1;
                        members(length(members) + 1) = cov_m(1, row-1);
                        destroy(length(destroy) + 1) = (row-1);
                        %keep this column since it's needed to represent the removed
                        %row
                        if ~any(keep == col)
                            keep(length(keep) + 1) = col;
                        end                
                end
            end
            groups = vertcat(groups, {cov_m(1, col), count, members});
        end
    end

    %%
    % list the counters being removed

    disp('3] ====== redundant counters removed ======');
    disp(cov_m(1, destroy));
    cov_m(destroy + 1, :) = [];
    cov_m(:, destroy) = [];
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
    cut = min(top_n, size(sort_std, 1)); %tinkerable

    %unique counters are chosen by averaging their positions in the sorted
    %mean and std lists
    best_ctrs = [];
    for c=1:length(sort_absavg)
        if any(sort_std(:, 1) ==  sort_absavg(c, 1))
            score = mean([c, find(sort_std(:, 1) ==  sort_absavg(c, 1))]);
            if score <= cut
                best_ctrs = horzcat(best_ctrs, sort_absavg(c, 1));
            end
        end
    end
    
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

    %{
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

    %}

    %%
    % write discovered counters to file

    outfile = sprintf('parsec-all-counters/%s-output', filename);
    
    final_ctrs = [];
    
    converted = uint16(unique(the_best_ctrs));
    final_ctrs = horzcat(final_ctrs, converted);
    
    for k=1:length(chosen)
        converted = uint16(srt_grps{k, 3});
        final_ctrs = horzcat(final_ctrs, converted);
    end
    dlmwrite(outfile, unique(final_ctrs));
    
    disp('8] ====== extracted counters ======');
    disp(unique(final_ctrs));
end