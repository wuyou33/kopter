function [u,t,A,f,phi,dudt] = mkrdmss(n,ampmin,ampmax,fmin,fmax,dt,T)
%
%  MKRDMSS  Creates inputs using a sum of sine functions with random amplitudes and frequencies.  
%
%  Usage: [u,t,A,f,phi,dudt] = mkrdmss(n,ampmin,ampmax,fmin,fmax,dt,T);
%
%  Description:
%
%    Generates a random signal by summing n sine components 
%    with amplitudes selected randomly from [ampmin,ampmax], 
%    and frequency selected randomly from [fmin,fmax].  
%    Duration of the generated random signal is T.  
%
%  Input:
%    
%        n = number of random sine components.  
%   ampmin = lower limit for random amplitudes.
%   ampmax = upper limit for random amplitudes.
%     fmin = lower limit for random frequencies.
%     fmax = upper limit for random frequencies.  
%       dt = sampling interval, sec.
%        T = time length, sec.
%
%
%  Output:
%
%     u = random signal.  
%     t = time vector.
%     A = vector of random amplitudes.
%     f = vector of random frequencies.
%   phi = vector of random phase angles.
%  dudt = analytic time derivative of u.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      07 May  1999 - Created and debugged, EAM.
%      22 July 2004 - Updated input-output list and changed name
%                     from mkrandss.m to mkrdmss.m, EAM.
%
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
t=[0:dt:T]';
npts=length(t);
u=zeros(npts,1);
dudt=zeros(npts,1);
rand('seed',sum(100*clock));
f=rand(n,1)*(fmax-fmin)+fmin;
A=rand(n,1)*(ampmax-ampmin)+ampmin;
phi=rand(n,1)*2*pi-pi;
for j=1:n,
  u=u+A(j)*sin(2*pi*f(j)*t+phi(j));
  dudt=dudt+A(j)*2*pi*f(j)*cos(2*pi*f(j)*t+phi(j));
end
return
