function [y,x,num,den] = tlattf(p,u,t,x0,c)
%
%  TLATTF  Time-domain lateral transfer function model file.  
%
%  Usage: [y,x,num,den] = tlattf(p,u,t,x0,c);
%
%  Description:
%
%    Model file for lateral transfer function
%    dynamic model in the time domain. 
%
%  Input:
%
%    p = parameter vector.
%    u = input vector time history.
%    t = time vector.
%   x0 = initial state vector.
%    c = vector of inertia constants.
%
%  Output:
%
%      y = model output vector time history.
%      x = model state vector time history.
%    num = transfer function numerator polynomial coefficients.
%    den = transfer function denominator polynomial coefficients.
%
%

%
%    Calls:
%      tfsim.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      01 Dec 2005 - Created and debugged, EAM.
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

%
%  Lateral roll mode approximation.
%
np=length(p);
num=[p(1)];
den=[1,p(2)];
%ul=ulag(u,t,tau);
[y,x]=tfsim(num,den,0,u,t);
return
