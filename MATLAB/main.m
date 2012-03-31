clear

%interesting sets
%bodytrack-simlarge
%streamcluster-simlarge
%raytrace-simlarge

filename = 'bodytrack-simlarge';
data_raw = load(sprintf('data/%s', filename));

%[data_norm, m, s] = rm_outliers(data_raw(:, 4), 1);
data_norm = normalize_m(data_raw, 1);

samples = size(data_norm, 1);

f = figure;
plot(data_norm(:, :));
title(sprintf('%s normalized counters', filename));
legend('HW-CACHE-REFERENCES','HW-CACHE-MISSES','HW-CACHE-LL','HW-CPU-CYCLES');

%saveas(f, sprintf('graphs/%s.png', filename), 'png');
%saveas(f, sprintf('graphs/%s.fig', filename), 'fig');
%plot(stream_norm(250:450, :));