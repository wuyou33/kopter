function [x,accel] = runk4a(deqname,p,u,t,x0,c)
%
%  RUNK4A  Version of rk4.m used for parameter estimation, with acceleration outputs. 
%
%  Usage: [x,accel] = runk4a(deqname,p,u,t,x0,c);
%
%  Description:
%
%    Integrates the differential equations specified in the 
%    file named deqname, using fourth-order Runge-Kutta integration 
%    with input interpolation.  This routine is the same as
%    runk4.m, except that this routine also outputs
%    linear and rotational accelerations in accel.  The file named
%    deqname must also produce the accel outputs.
%
%  Input:
%    
%    deqname = name of the file that computes the state derivatives.
%          p = parameter vector.
%          u = control vector time history.
%          t = time vector.
%         x0 = state vector initial condition.
%          c = vector or data structure of constants.
%
%  Output:
%
%          x = state vector time history.
%      accel = acceleration time history = [ax,ay,az,pdot,qdot,rdot].
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      16 Feb 2006 - Created and debugged, EAM.
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
dt=t(2)-t(1);
n=length(x0);
x=zeros(npts,n);
accel=zeros(npts,6);
x(1,:)=x0';
xd1=zeros(n,1);
xd2=zeros(n,1);
xd3=zeros(n,1);
xd4=zeros(n,1);
a=zeros(6,1);
for i=1:npts-1,
  xi=x(i,:)';
  ui=u(i,:)';
  [xd1,a]=eval([deqname,'(p,ui,xi,c)']);
  accel(i,:)=a';
  xint=xi + dt*xd1/2;
  uint=(u(i,:)' + u(i+1,:)')/2;
  xd2=eval([deqname,'(p,uint,xint,c)']);
  xint=xi + dt*xd2/2;
  xd3=eval([deqname,'(p,uint,xint,c)']);
  xint=xi + dt*xd3;
  uint=u(i+1,:)';
  xd4=eval([deqname,'(p,uint,xint,c)']);
  x(i+1,:)=(xi + dt*(xd1+2*xd2+2*xd3+xd4)/6)';
end
xi=x(npts,:)';
ui=u(npts,:)';
[xd4,a]=eval([deqname,'(p,ui,xi,c)']);
accel(npts,:)=a';
return
