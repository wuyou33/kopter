function [Y,f,U] = get_fft(t,y,flag)
%%  function [Y,f,U] = get_fft(t,y)
%   Function to get fast fourier transform of time domain data.
%   Inputs :
%   t - time vector (s)
%   y - data
%   flag - plotting flag ([]=no figure)
%
%   Outputs :
%   Y - Discrete Fourier transform of y
%   f - frequency (Hz)
%   U - Single-sided spectrum of y
%
%   Original code by M.Lone : 20 Jan. 2013
%   Last modified by M.Lone : 24 Jan. 2013

y = y-mean(y); % remove DC component of the signal
Fs = 1/t(2); % get sampling frequency
L = length(y); % get length of the signal

NFFT = 2^nextpow2(L); % Next power of 2 from length of y for zero padding
Yfft = fft(y,NFFT); % get Discrete FFT data
Y = 2*Yfft/L; % ensure FFT amplitude is same as y(t) (conserve signal power)
f = Fs/2*linspace(0,1,NFFT/2+1);
U = abs(Y(1:NFFT/2+1));

% plot time and frequency domain data
if isempty(flag) == 0
    plot_fft(t,y,f,U)
end
return

function plot_fft(t,y,f,U)
%% plotting function
figure
subplot(2,1,1)
plot(t,y)
xlabel('Time (s)'); ylabel('y(t)')
title('Time-domain Signal')
subplot(2,1,2)
semilogx(f*2*pi,U)
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (rad/s)'); ylabel('|Y(f)|')
return