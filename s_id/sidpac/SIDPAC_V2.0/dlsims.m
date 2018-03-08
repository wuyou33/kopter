function [y,x] = dlsims(phi,gam,C,D,u,x0,c,uopt)
%
%  DLSIMS  Numerically solves discrete-time linear difference equations.  
%
%  Usage: [y,x] = dlsims(phi,gam,C,D,u,x0,c,uopt);
%
%  Description:
%
%    Propagates the discrete equations:
%
%      x(i+1) = phi*x(i) + gam*(u(i+1)+u(i))/2
%
%    and computes the outputs y from:
%
%      y(i)=C*x(i) + D*u(i)
%
%
%  Input:
%    
%    phi,gam,C,D = system matrices.
%              u = control vector or matrix.
%             x0 = state vector initial condition (optional, default = 0).
%              c = vector or data structure of constants (optional, default = 0).
%           uopt = input treatment flag (optional):
%                  = 0 for zero order hold input (recommended for square wave inputs)
%                  = 1 for linear interpolation input (default)
%
%  Output:
%
%      y = discrete output vector or matrix.
%      x = discrete state vector or matrix.
%
%

%
%    Calls:
%      cvec.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      14 May  2004 - Created and debugged, EAM.
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
npts=size(u,1);
n=size(phi,1);
if nargin < 8
  uopt=1;
end
if nargin < 7
  c=0;
end
if nargin < 6
  x0=zeros(n,1);
end
x0=cvec(x0);
x=zeros(npts,n);
x(1,:)=x0';
if uopt==1
  uint=(u([1:npts-1],:)+u([2:npts],:))/2;
else
  uint=u;
end
for i=2:npts,
  xi=x(i-1,:)';
  ui=uint(i-1,:)';
  x(i,:)=(phi*xi + gam*ui)';
end
y=(C*x' + D*u')';
return
