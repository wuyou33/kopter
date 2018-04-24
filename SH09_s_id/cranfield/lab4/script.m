%Script

dt = 0.01;
t = 0:dt:10;
sr = 1/dt;

u(:,1) = [zeros(1, 2*sr); ones(1, sr); -ones(1, sr); zeros(1, 10*sr)];

get_fft(t, u(:, 1),1)