function [y,x] = lsims(A,B,C,D,u,t,x0,c,uopt)
%
%  LSIMS  Numerically integrates state-space model differential equations.  
%
%  Usage: [y,x] = lsims(A,B,C,D,u,t,x0,c,uopt);
%
%  Description:
%
%    Integrates the differential equations:
%
%      dx/dt = A*x + B*u
%
%    and computes the outputs y from:
%
%      y=C*x + D*u
%
%    using 2nd order Runge-Kutta.  This is a SIDPAC equivalent
%    of the lsim.m function in the MATLAB control systems toolbox.  
%
%  Input:
%    
%    A,B,C,D = system matrices.
%          u = control vector time history.
%          t = time vector, sec.
%         x0 = state vector initial condition (optional, default=0).
%          c = vector of inertia constants (optional, default=0).
%       uopt = input treatment flag (optional):
%              0 for zero order hold input (recommended for square wave inputs)
%              1 for linear interpolation input (default)
%
%  Output:
%
%        y = output vector time history.
%        x = state vector time history.
%
%

%
%    Calls:
%      cvec.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      24 June 1999 - Created and debugged, EAM.
%      27 July 1999 - Corrected error in output vector
%                     calculation, EAM.  
%      16 July 2002 - Vectorized two commands and corrected
%                     an error in the output vector calculation, EAM.
%      14 May  2004 - Added uopt, EAM.
%      03 Oct  2005 = Changed name to lsims.m, EAM.
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
npts=length(t);
dt=1/round(2/(t(3)-t(1)));
n=size(A,1);
if nargin < 9
  uopt=1;
end
if nargin < 8
  c=0;
end
if nargin < 7
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
  ui=u(i-1,:)';
  xd1=A*xi + B*ui;
  xint=xi+dt*xd1/2;
  xd2=A*xint + B*uint(i-1,:)';
  x(i,:)=(xi + dt*xd2)';
end
y=(C*x' + D*u')';
return
