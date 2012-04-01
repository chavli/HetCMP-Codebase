

infiles = dir(fullfile('./training_data','*.csv'));

for f=1:size(infiles, 1)
    filename = sprintf('./training_data/%s', infiles(f).name);
    data = csvread(filename);
    norm_data = normalize_m(data, 1);
    labels = norm_data(:, 35) > 0;
    data = horzcat(data, labels);
    dlmwrite(sprintf('./training_data/training-%s', infiles(f).name), data);
end