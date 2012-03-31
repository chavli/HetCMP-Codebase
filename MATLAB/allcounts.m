%
%   allcounters.m -- preliminary counter analysis
%   
%   Cha Li
%   CS2002: HetCMP
%   15 March 2012
%
%   this matlab script visualizes data from all perfmon counters for the simple   
%   benchmark phase.c
%
%   the covariance matrix is also calculated for all counters
%

%load all the data
f = fopen('all-counters-data/labels.csv', 'r');
labels = textscan(f, '%s');
data_m = csvread('all-counters-data/phase.csv');
num_bins = 10;

%calculate the average for each column
%ignore the last few data points (5 seconds) which represent the thread
%ending
mu_v = mean(data_m(1:56, :));
[count_v, center_v] = histogram_analysis('mu-distribution-(20 bins)', mu_v, num_bins, 1);

%width of a uniform bin is just 2 * the center of the bin
bin_width = 2*center_v(1);

%find the mu values that fall into the first bin.
%copy the found mu's into a new vector and bin them
first_bin_indices = find((mu_v <= bin_width));
first_bin = mu_v(:, first_bin_indices);

%plot the counters by bin (start from 2 if you dont want to see the 100+
%counters in the first bin

for bin=1:num_bins
    filter_1 = (mu_v > (bin - 1)*bin_width);
    filter_2 = (mu_v <= bin*bin_width);
    
    %element-wise multiplication to see which elements satisfy both filters
    bin_indices = find(filter_1 .* filter_2);
    
    %only plot bin if it contained counters
    if ~isempty(bin_indices)
        fig = figure;
        plot(data_m(:, bin_indices));
        legend(labels{1}{bin_indices});
        title(sprintf('Bin %d Counters', bin));
        
        %save these pretty pictures
        %saveas(fig, sprintf('all-counters-data/bin%d_counters.png', bin) );
    end
end

%make a histogram just out of the first bin
[lol1, foo] = histogram_analysis('Bin1-mu-distribution-(100 bins)', first_bin, 100, 1); 

%plot all the counter values
fig = figure;
plot(data_m(:, :));
title('all counters');
saveas(fig, 'all-counters-data/all_counters.png' );

%convariance matrix
lol = cov(data_m);
data_norm = normalize_m(data_m, 1);
cov_m = cov(data_norm);

%dump the covariance matrix to a file since it's so large
dlmwrite('all-counters-data/allcounts_cov.csv', cov_m, 'delimiter', ',', 'precision','%1.5f', 'newline', 'unix');
save('all-counters-data/allcounts_cov.txt', 'cov_m', '-ascii');

%distributions of each counter

