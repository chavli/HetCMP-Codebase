clc 
clear


infiles = dir(fullfile('./training_prep','*.csv'));

for f=1:size(infiles, 1)
    filename = sprintf('./training_prep/%s', infiles(f).name);
    
    data = csvread(filename);
    norm_data = normalize_m(data, 1);
    
    %1st and 3rd quartile used as initial means for k-means clustering
    
    
    means_0 = quantile(data, [.25, .75]);
    
    [labels, c] = kmeans(data, 2, 'Start', means_0); 
    labels = labels - 1;
    
    figure
    plot(labels, '-o')
    hold on
    plot(norm_data(:, 31), '-or');
    
    
    %p    hold onlot(norm_data);
    %labels = norm_data(:, 35) > 0; %use attribute 35 as basis for judgment
    %labels = norm_data(:, 6) > 0; %use attribute 35 as basis for judgment
    data = horzcat(data, labels);
    dlmwrite(sprintf('./training_data/training-%s', infiles(f).name), data);
end