function zs = lsmoo(z,k,n)
%
%  LSMOO  Smoothes noisy measured data using a local smoother.  
%
%  Usage: zs = lsmoo(z,k,n);
%
%
%  Description:
%
%    Computes smoothed time series using local 
%    nth order smoothing for k neighboring points on each 
%    side of the locally smoothed point.  Near the 
%    endpoints, interior points are substituted for missing
%    neighboring points.  
%
%  Input:
%
%    z = vector or matrix of measured time series.
%    k = number of neighboring points used on each side (optional, default=10). 
%    n = local polynomial order (optional, default=2).
%
%  Output:
%
%    zs = vector or matrix of smoothed time series.
%
%

%
%    Calls:
%      reggen.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      21 July 2002 - Created and debugged, EAM.
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
[npts,no]=size(z);
zs=z;
if nargin < 3
  n=2;
end
if nargin < 2
  k=10;
end
%
%  There are 2*k+1 data points, and n+1 parameters for the local model.  
%  Need k > n/2 to get an over-determined system of equations 
%  necessary for smoothing.  
%
if k<=n/2
  fprintf('\n Input error - not enough neighboring points for selected n \n\n'),
  return
end
%
%  Local nth order regression matrix 
%  for interior points, with constant term first.  
%
x=reggen([-k:1:k]',n,n,1);
xtx=x'*x;
for i=k+1:npts-k,
  zl=z([i-k:i+k],:);
  a=xtx\(x'*zl);
%
%  Smoothed value is the constant term parameter estimate.  
%
  zs(i,:)=a(1,:);
end
%
%  Initial points.
%
%  Center the regressors k points away from 
%  the boundary, to avoid numerical problems 
%  for high values of n.  
%
x=reggen([-k:1:k]',n,n,1);
xtx=x'*x;
zl=z([1:2*k+1],:);
a=xtx\(x'*zl);
%
%  Smoothed initial points are just the local 
%  identified model points from the regression.  
%
zs([1:k],:)=x([1:k],:)*a;
%
%  Final points.
%
%  Center the regressors k points away from 
%  the boundary, to avoid numerical problems 
%  for high values of n.  
%
x=reggen([-k:k]',n,n,1);
xtx=x'*x;
zl=z([npts-2*k:npts],:);
a=xtx\(x'*zl);
%
%  Smoothed final points are just the local 
%  identified model points from the regression.  
%
zs([npts-k+1:npts],:)=x([k+2:2*k+1],:)*a;
return
