function [zs,H,f,h,t] = fdfilt(z,fc,dt,type)
%
%  FDFILT  Implements filtering in the frequency domain.  
%
%  Usage: [zs,H,f,h,t] = fdfilt(z,fc,dt,type);
%
%  Description:
%
%    Applies a filter to the input data z in the frequency domain.  
%    Filtering can be low-pass (default) or high-pass, with cut-off frequency fc.  
%    This approach introduces no phase shift in the filtered output. 
%
%  Input:
%    
%      z = vector or matrix of measured time series.
%     fc = filter cut-off frequency, Hz.
%     dt = sampling interval, sec.
%   type = filter type:
%          = 0 for low-pass filter (default).
%          = 1 for high-pass filter.
%
%  Output:
%
%    zs = filtered vector or matrix of measured time series.
%     H = gain of the filter in the frequency domain.
%     f = frequency vector for H, Hz.
%     h = impulse response vector associated with H.
%     t = time vector for h, sec.
%
%

%
%    Calls:
%      xsmep.m
%      zep.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      08 Feb  2006 - Created and debugged, EAM.
%
%  Copyright (C) 2006  Eugene A. Morelli
%
%  This program carries no warranty, not even the implied 
%  warranty of merchantability or fitness for a particular purpose.  
%
%  Please email bug reports or suggestions for improvements to:
%
%      e.a.morelli@nasa.gov
%
if nargin < 4
  type=0;
end
[N,nc]=size(z);
%
%  Compute the filter in the frequency domain.
%
%  Set the termination frequency for the roll-off, 
%  using a frequency factor of pi for less than 
%  0.5 percent gain error in the pass band.  
%
%  Use a sharp cut-off in the frequency domain, 
%  which is equivalent to a large data length ns
%  in the time domain.  
%
ns=round(N/2-0.1);
ffac=pi;
ft=fc + ffac/(ns*dt);
wc=2*pi*fc;
wt=2*pi*ft;
dw=wt-wc;
%
%  Compute the frequency-domain filter, 
%  which is real and symmetric about w=0.
%
fn=1/(2*dt);
f=[0:N-1]'/(N*dt);
w=2*pi*f;
nh=floor(N/2)+1;
H=zeros(nh,1);
ip=find(w<=wc);
H(ip)=ones(length(ip),1);
it=find((w>wc)&(w<=wt));
if ~isempty(it)
  nt=length(it);
  for i=it(1):it(nt),
    H(i)=0.5*(cos((w(i)-wc)*pi/dw) + 1);
  end
end
%
%  Reflect the frequency-domain filter
%  to account for negative frequencies 
%  and wrap-around.  The reflection is 
%  different, depending on whether the 
%  number of data points is odd or even.
%
if mod(N,2)
  H=[H;H([nh:-1:2],:)];
else
  H=[H;H([nh-1:-1:2],:)];  
end
%
%  High-pass filter = 1 - low-pass filter.
%
if type==1
  H=ones(size(H,1),1)-H;
end
%
%  Smooth the endpoints first, then 
%  detrend the time-domain data.
%
zsmep=xsmep(z,fc,dt);
[zz,trend]=zep(zsmep);
%
%  Apply the filter in the frequency domain.
%
Z=fft(zz);
ZS=Z.*H(:,ones(1,nc));
%
%  Return the filtered data to the time domain.  
%
zs=ifft(ZS);
%
%  Restore the trend, but only for low-pass filtering.
%
if type==0
  zs=zs+trend;
end
%
%  Find the impulse response.
%
h=ifft(H);
h=fftshift(h);
t=[0:dt:dt*(N-1)]';
return
