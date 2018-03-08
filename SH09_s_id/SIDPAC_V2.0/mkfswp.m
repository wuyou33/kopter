function [u,t,w] = mkfswp(amp,tdelay,wmin,wmax,dt,T,type)
%
%  MKFSWP  Creates linear or log frequency sweep inputs.
%
%  Usage: [u,t,w] = mkfswp(amp,tdelay,wmin,wmax,dt,T,type);
%
%  Description:
%
%    Creates a frequency sweep with amplitude amp 
%    covering the frequency range between wmin and wmax inclusive.
%
%  Input:
%    
%     amp = amplitude.
%  tdelay = time delay before the frequency sweep starts, sec.
%    wmin = minimum frequency, rad/sec.
%    wmax = maximum frequency, rad/sec.
%      dt = sampling time, sec.
%       T = time length, sec.
%    type = frequency sweep type
%           = 0 for logarithmic frequency sweep (default).
%           = 1 for linear frequency sweep.
%
%  Output:
%
%     u = frequency sweep vector with amplitude amp covering 
%         the frequency range from wmin to wmax inclusive.  
%     t = time vector.
%     w = vector of frequencies for each time step.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%     12 Sept 1997 - Created and debugged, EAM.
%     19 Nov  2005 - Changed arguments of the sine functions, EAM.
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
if wmin <= 0
  wmin=0.01;
end
if nargin < 7 
  type=0;
end
%
%  Index for the first point after the time delay.  Create a new
%  time vector tl that starts immediately following the time delay.  
%
n0=floor(tdelay/dt)+1;
tl=t(n0:npts);
tl=tl-tl(1);
m=length(tl);
Tl=(m-1)*dt;
%
%  Compute the phase angle as a function of time
%  to give the desired change in frequency.
%
if type==0,
%
%  Modified log sweep, with frequencies 
%  skewed slightly higher than a log sweep.  
%
  c1=4;
  c2=0.0187;
  w=wmin + c2*(wmax-wmin)*(exp(c1*tl/Tl)-ones(m,1));
  phi=wmin*tl + c2*(wmax-wmin)*((Tl/c1)*exp(c1*tl/Tl)-tl);
%
%  Log sweep.
%
%   w=wmin*((wmax/wmin).^(tl/Tl));
%   phi=(wmin*Tl/log(wmax/wmin))*(wmax/wmin).^(tl/Tl);
%
%  Shift the initial angle so that the sweep starts at zero. 
%
  phi=phi-phi(1);
else
  w=wmin + (wmax-wmin)*tl/Tl;
  phi=wmin*tl + 0.5*(wmax-wmin)*(tl.*tl)/Tl;
end
%
%  Generate frequency sweep.
%
u(n0:npts)=amp*sin(phi);
%
%  Make sure the input ends at zero.
%
if u(npts) < 0,
  i=max(find(u >=0));
else
  i=max(find(u < 0));
end
u(i+1:npts)=zeros(npts-i,1);
return
