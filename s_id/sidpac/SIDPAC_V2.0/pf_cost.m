function [cost,y] = pf_cost(ph,f,p,t)
%
%  PF_COST  Computes the cost for peak factor minimization of multi-sine inputs.  
%
%  Usage: [cost,y] = pf_cost(ph,f,p,t);
%
%  Description:
%
%    Computes the relative peak factor cost for optimizing
%    multiple-frequency sum of cosines for improvement 
%    of the relative peak factor, compared to the Schroeder 
%    sweep.  This function is used in the optimization 
%    to determine minimum relative peak factor inputs.
%
%  Input:
%    
%    ph = vector of phase angles, rad.
%     f = frequency vector, Hz.
%     p = vector of power for each component, sum(p)=1. 
%     t = time vector.
%
%  Output:
%
%    cost = relative peak factor cost.
%       y = multiple frequency sum of cosines.  
%
%

%
%    Calls:
%      peakfactor.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      24 Nov 2002 - Created and debugged, EAM.
%      25 May 2004 - Included arbitrary power spectrum, EAM.
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
w=2*pi*f;
m=length(f);
npts=length(t);
%
%  Assemble the time domain signal.
%
y=zeros(npts,1);
for j=1:m,
  y=y+sqrt(p(j))*cos(w(j)*t + ph(j)*ones(npts,1));
end
cost=peakfactor(y);
return
