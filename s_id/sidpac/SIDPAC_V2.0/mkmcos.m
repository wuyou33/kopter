function [u,t,pf] = mkmcos(amp,fu,ph,pwr,dt,T)
%
%  MKMCOS  Creates multiple component sinusoidal inputs using cosine functions.  
%
%  Usage: [u,t,pf] = mkmcos(amp,fu,ph,pwr,dt,T);
%
%  Description:
%
%    Assembles a multi-component sinusoid using 
%    cosine functions with frequencies fu and 
%    phase shifts ph, as follows:
%
%      u = amp*sum(cos(2*pi*fu(j)*t + ph(j)))
%
%    where t = [0:dt:T]'.  This routine can be 
%    used to assemble multi-sine sweep inputs.  
%    For multiple inputs, the data in fu, 
%    ph, and pwr should be arranged by column, 
%    so the kth column of u is based
%    on the kth column of the input quantities.  
%    The kth element of input vector amp is the 
%    amplitude of the kth column of u.  
%
%
%  Input:
%
%     amp = amplitude(s).
%      fu = frequencies for each cosine component, Hz.  
%      ph = phase angles for each cosine component, rad.
%     pwr = power spectrum for each input (sum(pwr)=1).
%      dt = sampling interval, sec.
%       T = time length, sec.
%
%
%  Output:
%
%       u = composite multiple cosine signal.
%       t = time vector.
%      pf = relative peak factor.
%

%
%    Calls:
%      peakfactor.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      27 May 2004 - Created and debugged, EAM.
%      17 Nov 2004 - Added multiple input capability, EAM.
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
[m,no]=size(fu);
w=2*pi*fu;
u=zeros(npts,no);
if length(amp)~=no
  amp=amp(1)*ones(no,1);
end
%
%  Compute the composite cosine signal.  
%
for k=1:no,
  for j=1:m,
    u(:,k) = u(:,k) + sqrt(pwr(j,k))*cos(w(j,k)*t + ph(j,k));
  end
  u(:,k)=amp(k)*u(:,k);
end
%
%  Compute the peak factor.
%
pf=peakfactor(u);
return
