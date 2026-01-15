% Setup filter for a 120Hz signal
one_euro = OneEuroFilter(120, 'mincutoff', 1.0, 'beta_', 0.1);
t = 0:1/120:2;
noisy_signal = sin(2*pi*t) + 0.2*randn(size(t));
filtered_signal = arrayfun(@(v, ts) one_euro.filter(v, ts), noisy_signal, t);

figure;
plot(t, noisy_signal, 'r-', t, filtered_signal, 'b-');
legend('Noisy', 'Filtered');


