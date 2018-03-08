function [yd,yctf] = cubic_dtrend(y,t)
%
%  CUBIC_DTREND  Computes a cubic detrend function for a noisy time series.  
%
%  Usage: [yd,yctf] = cubic_dtrend(y,t);
%
%  Description:
%
%    Computes a cubic trend function of time based on y,
%    then subtracts that trend from y and puts the result in yd. 
%
%  Input:
%    
%    y = vector or matrix of column vector time series.
%    t = time vector.
%
%  Output:
%
%     yd = y with best fit cubic trend function of time removed.
%   yctf = cubic trend function of time based on y.
%

%
%    Calls:
%      lesq.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      18 Jan 2000 - Created and debugged, EAM.
%      17 Mar 2005 - Modified to handle matrices of column vectors, EAM.
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
[npts,nc]=size(y);
yd=zeros(npts,nc);
yctf=zeros(npts,nc);
%
%  Use least squares regression for y as
%  a function of polynomial terms in t to
%  find the cubic detrend function of time.
%
x=[ones(npts,1),t,t.*t,t.*t.*t];
for j=1:nc,
  [yctf(:,j),p,cvar,s2]=lesq(x,y(:,j));
  yd(:,j)=y(:,j)-yctf(:,j);
end
return
