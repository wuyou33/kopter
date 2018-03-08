function [y,x] = f16(u,t,x0,c)
%
%  F16  F-16 nonlinear simulation. 
%
%  Usage: [y,x] = f16(u,t,x0,c);
%
%
%  Description:
%
%    Computes the state and output vector time histories for the 
%    F-16 nonlinear simulation based on NASA TP-1538, December 1979.
%
%  Input:
%    
%    u = input vector = [ thtl  (0 <= thtl <= 1.0)
%                         stab  (deg)
%                          ail  (deg)
%                          rdr  (deg) ];
%    t = time vector. 
%   x0 = state vector initial condition.
%    c = vector of constants:  c(1) through c(9) = inertia constants.
%                              c(10) = aircraft mass, slugs.
%                              c(11) = xcg, longitudinal c.g. location,
%                                      distance normalized by the m.a.c.
%
%  Output:
%
%     y = output vector time history = [x, ax (g), ay (g), az (g), 
%                                       pdot (rps2), qdot (rps2), rdot (rps2), thrust (lbf)].
%     x = state vector = [   vt  (ft/sec)
%                           beta (rad)
%                          alpha (rad)
%                           prad (rad/sec)
%                           qrad (rad/sec)
%                           rrad (rad/sec)
%                            phi (rad)
%                            the (rad)
%                            psi (rad)
%                            xe  (ft)
%                            ye  (ft)
%                             h  (ft)  
%                            pow (percent, 0 <= pow <= 100) ];
%

%
%    Calls:
%      f16_aero_setup.m
%      f16_engine_setup.m
%      cvec.m
%      f16_deq.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      17 June 1995 - Created and debugged, EAM.
%      03 Feb  2006 - Added acceleration and thrust outputs, EAM.
%      23 Feb  2006 - Updated for F-16 NLS version 1.1, EAM.
%      02 Aug  2006 - Changed elevator to stabilator, EAM.
%
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
%  Check input dimensions.
%
[npts,ni]=size(u);
if ni~=4
  fprintf('\n Error:  missing input channel(s) \n\n')
  return
end
if npts~=length(t)
  fprintf('\n Error:  length of u and t not compatible \n\n')
  return
end
if length(x0) < 13
  fprintf('\n Error:  missing x0 vector elements \n\n')
  return
end
if length(c) < 11
  fprintf('\n Error:  missing c vector elements \n\n')
  return
end
%
%  Aerodynamic data.
%
f16_aero_setup;
%
%  Engine data.
%
f16_engine_setup;
%
%  Integration must be done here if 
%  accelerations and thrust are to be outputs.
%
accel=zeros(npts,6);
thrust=zeros(npts,1);
dt=t(2)-t(1);
n=length(x0);
x=zeros(npts,n);
x(1,:)=cvec(x0)';
%
%  Integration time decreases by approximately
%  a factor of two from rk4 to rk2, and ab3 is 
%  faster than rk2 by another factor of 2.  
%  However, the integration accuracy degrades
%  significantly using ab3 in many cases.  
%
%  linteg = integration method flag:
%           = 0 for rk2
%           = 1 for ab3
%           = 2 for rk4
%
linteg=1;
if linteg==0
%
%   x=rk2('f16_deq',u,t,x0,c);
%
%  Numerical integration - 2nd order Runge-Kutta.
%
  xd1=zeros(n,1);
  xd2=zeros(n,1);
  for i=1:npts-1,
    xi=x(i,:)';
    ui=u(i,:)';
    [xd1,acceli,thrusti]=f16_deq(ui,xi,c);
    accel(i,:)=acceli';
    thrust(i)=thrusti;
    xint=xi + dt*xd1/2;
    uint=(u(i,:)' + u(i+1,:)')/2;
    [xd2,acceli,thrusti]=f16_deq(uint,xint,c);
    x(i+1,:)=(xi + dt*xd2)';
  end
  [xd1,acceln,thrustn]=f16_deq(u(npts,:)',x(npts,:)',c);
  accel(npts,:)=acceln';
  thrust(npts)=thrustn;
elseif linteg==1
%
%   x=ab3('f16_deq',u,t,x0,c);
%
%  Numerical integration - 3rd order Adams-Bashforth.
%
%  First two steps are second order Runge-Kutta
%  to start the third order Adams-Bashforth method.  
%
  xd1=zeros(n,1);
  xd2=zeros(n,1);
  xdp=zeros(n,3);
  for i=1:2,
    xi=x(i,:)';
    ui=u(i,:)';
    [xd1,acceli,thrusti]=f16_deq(ui,xi,c);
    accel(i,:)=acceli';
    thrust(i)=thrusti;
    if i==1
      xdp=xd1*ones(1,3);
    else
      xdp(:,[2:3])=xdp(:,[1:2]);
      xdp(:,1)=xd1;
    end
    xint=xi + dt*xd1/2;
    uint=(u(i,:)' + u(i+1,:)')/2;
    xd2=f16_deq(uint,xint,c);
    x(i+1,:)=(xi + dt*xd2)';
  end
%
%  Now switch to third order Adams-Bashforth.  
%
  k=[23/12,-16/12,5/12]';
  for i=3:npts-1,
    xint=x(i,:)';
    uint=u(i,:)';
    xdp(:,[2:3])=xdp(:,[1:2]);
    [xdp(:,1),acceli,thrusti]=f16_deq(uint,xint,c);
    accel(i,:)=acceli';
    thrust(i)=thrusti;
    x(i+1,:)=(xint + dt*xdp*k)';
  end
  [xd1,acceln,thrustn]=f16_deq(u(npts,:)',x(npts,:)',c);
  accel(npts,:)=acceln';
  thrust(npts)=thrustn;
else
%
% x=rk4('f16_deq',u,t,x0,c);
%
%  Numerical integration - 4th order Runge-Kutta.
%
  xd1=zeros(n,1);
  xd2=zeros(n,1);
  xd3=zeros(n,1);
  xd4=zeros(n,1);
  for i=1:npts-1,
    xi=x(i,:)';
    ui=u(i,:)';
    [xd1,acceli,thrusti]=f16_deq(ui,xi,c);
    accel(i,:)=acceli';
    thrust(i)=thrusti;
    xint=xi + dt*xd1/2;
    uint=(u(i,:)' + u(i+1,:)')/2;
    xd2=f16_deq(uint,xint,c);
    xint=xi + dt*xd2/2;
    xd3=f16_deq(uint,xint,c);
    xint=xi + dt*xd3;
    uint=u(i+1,:)';
    xd4=f16_deq(uint,xint,c);
    x(i+1,:)=(xi + dt*(xd1+2*xd2+2*xd3+xd4)/6)';
  end
  [xd1,acceln,thrustn]=f16_deq(u(npts,:)',x(npts,:)',c);
  accel(npts,:)=acceln';
  thrust(npts)=thrustn;
end
%
%  Assemble the outputs.
%
y=[x,accel,thrust];
return
