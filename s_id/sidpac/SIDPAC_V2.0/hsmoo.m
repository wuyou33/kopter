function [zs,H,f,h,t] = hsmoo(z,fc,dt)
%
%  HSMOO  Implements low-pass filtering using fixed-weight smoothing.  
%
%  Usage: [zs,H,f,h,t] = hsmoo(z,fc,dt);
%
%  Description:
%
%    Low pass filters the input data z, passing frequencies
%    in the interval [0,fc] Hz, using fixed weight smoothing.  
%    This approach introduces no phase shift in the filtered output. 
%
%  Input:
%    
%     z = vector or matrix of measured time series.
%    fc = low-pass filter cutoff frequency, Hz.
%    dt = sampling interval, sec.
%
%  Output:
%
%    zs = low pass filtered vector or matrix of measured time series.
%     H = gain of the filter in the frequency domain.  
%     f = frequency vector for H, Hz.  
%     h = vector of fixed smoothing weights.
%     t = time vector for h, sec.
%
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      10 Dec  1995 - Created and debugged, EAM.
%      11 Sept 2003 - Added comments, re-coded the smoothing 
%                     weight computation for more clarity 
%                     and better numerical accuracy, added 
%                     outputs showing filter characteristics 
%                     in the frequency domain, EAM.  
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
[npts,n]=size(z);
%
%  Compute the fixed smoothing weights.
%
%  Use a large data length for the smoothing.  
%
ns=round(npts/2.-0.1);
%
%  Set the termination frequency for the roll-off, 
%  using a frequency factor of pi for less than 
%  0.5 percent gain error in the pass band, and 
%  also to avoid any divide by zero in the 
%  smoothing weight calculations.  
%
ffac=pi;
ft=fc + ffac/(ns*dt);
wc=2.*pi*fc;
wt=2.*pi*ft;
dw=wt-wc;
h=zeros(ns,1);
ho=fc+ft;
hnorm=ho;
for i=1:ns,
  h(i)=(pi/(2*i*dt))*((sin(wt*i*dt)+sin(wc*i*dt))/...
       (pi^2-(dw*i*dt)^2));
  hnorm=hnorm + 2*h(i);
end
%
%  Normalize the smoothing weights.
%
ho=ho/hnorm;
h=h/hnorm;
h=[h(ns:-1:1);ho;h];
%
%  Reflect the time history about both endpoints,
%  then use an inner product with the smoothing 
%  weights on both sides of the current (ith)
%  data point to do the time domain smoothing.
%
zs=zeros(npts,n);
zx=[z([npts:-1:2],:);z;z([npts-1:-1:1],:)];
for i=1:npts,
  ix=i+npts-1;
  for j=1:n,
    zs(i,j)=h'*zx([ix-ns:ix+ns],j);
  end
end
%
%  Compute the implemented filter gain.
%
t=[-ns*dt:dt:ns*dt]';
f=[0:1/(2*ns*dt):1/(2*dt)]';
w=2*pi*f;
nf=length(w);
H=zeros(nf,1);
for k=1:nf,
  H(k)=h'*cos(w(k)*t);
end
return
