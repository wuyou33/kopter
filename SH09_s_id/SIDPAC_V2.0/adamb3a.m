function [x,accel] = adamb3a(deqname,p,u,t,x0,c)
%
%  ADAMB3A  Version of ab3.m used for parameter estimation, with acceleration outputs.
%
%  Usage: [x,accel] = adamb3a(deqname,p,u,t,x0,c);
%
%  Description:
%
%    Integrates the differential equations specified in the 
%    file named deqname, using third-order Adams-Bashforth 
%    numerical integration.  This routine is the same as 
%    adamb3.m, except that this routine also outputs 
%    linear and rotational accelerations in accel.  The file 
%    named deqname must also produce the acceleration outputs.
%

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
%      24 July 2002 - Created and debugged, EAM.
%
%
%  Copyright (C) 2006  Eugene A. Morelli
%
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
xdp=zeros(n,3);
a=zeros(6,1);
%
%  First two steps are second order Runge-Kutta
%  to start the third order Adams-Bashforth method.  
%
for i=1:2,
  xi=x(i,:)';
  ui=u(i,:)';
  [xd1,a]=eval([deqname,'(p,ui,xi,c)']);
  accel(i,:)=a';
  if i==1
    xdp=xd1*ones(1,3);
  else
    xdp(:,[2:3])=xdp(:,[1:2]);
    xdp(:,1)=xd1;
  end
  xint=xi + dt*xd1/2;
  uint=(u(i,:)' + u(i+1,:)')/2;
  xd2=eval([deqname,'(p,uint,xint,c)']);
  x(i+1,:)=(xi + dt*xd2)';
end
%
%  Now switch to third order Adams-Bashforth.  
%
k=[23/12,-16/12,5/12]';
for i=3:npts-1,
  xi=x(i,:)';
  ui=u(i,:)';
  xdp(:,[2:3])=xdp(:,[1:2]);
  [xdp(:,1),a]=eval([deqname,'(p,ui,xi,c)']);
  accel(i,:)=a';
  x(i+1,:)=(xi + dt*xdp*k)';
end
xi=x(npts,:)';
ui=u(npts,:)';
[xdp(:,1),a]=eval([deqname,'(p,ui,xi,c)']);
accel(npts,:)=a';
return
