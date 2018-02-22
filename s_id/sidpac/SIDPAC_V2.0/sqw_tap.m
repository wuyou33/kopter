function [amp,tsw,dt,tmax] = sqw_tap(u,t)
%
%  SQW_TAP  Finds square wave time-amplitude points.  
%
%  Usage: [amp,tsw,dt,tmax] = sqw_tap(u,t);
%
%  Description:
%
%    For an input square wave u associated with time vector t,
%    computes the switching times tsw, amplitudes amp, time step dt, 
%    and maximum time tmax.  No rate limits are assumed.  
%
%  Input:
%
%       u = square wave input vector.  
%       t = time vector, sec.
%
%  Output:
%
%       amp = input amplitudes for each pulse.
%       tsw = initial switching times for each pulse, sec.
%        dt = sampling time, sec.
%      tmax = time length for the input, sec.
%

%
%    Calls:
%      cvec.m
%
%    Author:  Eugene A. Morelli
%
%    History: 
%      11 June 2003 - Created and debugged, EAM.
%      14 Dec  2005 - Changed the function name, EAM.
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
u=cvec(u);
t=cvec(t);
t=t-t(1);
tmax=max(t);
dt=t(2)-t(1);
npts=length(t);
tsw=zeros(npts,1);
amp=zeros(npts,1);
%
%  Initialize the previous amplitude, 
%  used to detect transitions that 
%  define the switching times.
%
pamp=u(1);
nsw=0;
%
%  Find switching times and amplitudes.
%
for i=2:npts,
  if u(i)~=pamp
    nsw=nsw+1;
    amp(nsw)=u(i-1);
    tsw(nsw)=t(i-1);
    pamp=amp(nsw);
  end
end
amp=amp(1:2:nsw);
tsw=tsw(1:2:nsw);
return
