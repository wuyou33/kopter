function [xd,accel,thrust,qbar,mach,forces] = f16_deq_mod(u,x,c,LUTvalues)
%
%  F16_DEQ  Computes state derivatives for the nonlinear equations of motion.  
%
%  Usage: [xd,accel,thrust,qbar,mach] = f16_deq(u,x,c);
%
%
%  Description:
%
%    Computes the state derivatives for the 
%    F-16 nonlinear equations of motion, 
%    based on NASA TP-1538, December 1979.
%
%  Input:
%    
%    u = input vector = [ thtl  (0 <= thtl <= 1.0)
%                         stab  (deg)
%                          ail  (deg)
%                          rdr  (deg) ];
%
%    x = state vector = [   vt  (ft/sec)
%                          beta (rad)
%                         alpha (rad)
%                          prad (rad/sec)
%                          qrad (rad/sec)
%                          rrad (rad/sec)
%                           phi (rad)
%                           the (rad)
%                           psi (rad)
%                           xe  (ft)
%                           ye  (ft)
%                            h  (ft)  
%                           pow (percent, 0 <= pow <= 100) ];
%
%    c = vector of constants:  c(1) through c(9) = inertia constants.
%                              c(10) = aircraft mass, slugs.
%                              c(11) = xcg, longitudinal c.g. location,
%                                      distance normalized by the m.a.c.
%
%  Output:
%
%      xd = state vector time derivative.
%   accel = vector of acceleration outputs = [ax (g), ay (g), az (g), 
%                                             pdot (rps2), qdot (rps2), rdot (rps2)]'.
%  thrust = thrust (lbf).
%    qbar = dynamic pressure (psf).
%    mach = Mach number.
%  forces = vector of force and moments coefficients, Alejandro
%

%
%    Calls:
%      atm.m
%      f16_engine.m
%      f16_aero.m
%      tgear.m
%      pdot.m
%      
%    Author:  Eugene A. Morelli
%
%    History:  
%     18 May  1995 - Created and debugged, EAM.
%     17 July 2001 - Added independent variable limits, EAM.
%     18 July 2001 - Added accelerometer, Mach, and qbar outputs, EAM.
%     21 July 2001 - Added correction for theta singularity in kinematic equation, FRG.
%     28 Jan  2004 - Added thrust output, re-ordered outputs, EAM.
%     17 Nov  2005 - Corrected heng term sign, EAM. 
%     16 Feb  2006 - Updated for F-16 NLS version 1.1, EAM.
%     02 Aug  2006 - Changed elevator to stabilator, EAM.
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
global CXO CZO CMO CLO CNO DDER
global DLDA DLDR DNDA DNDR
global IDP MLP MXP
xd=zeros(length(x),1);
accel=zeros(6,1);
forces = zeros(6,1); %Added, Alejandro
%
%  Assign constants.
%
sarea=300.;
bspan=30.;
cbar=11.32;
xcg=c(11);
heng=160.0;
rtd=180./pi;
g=32.174;
%
%  Assign state and control variables.
%
vt=x(1);
beta=x(2);
betad=x(2)*rtd;
alpha=x(3);
alphad=x(3)*rtd;
prad=x(4);
qrad=x(5);
rrad=x(6);
phi=x(7);
the=x(8);
psi=x(9);
alt=x(12);
pow=x(13);
thtl=u(1);
stab=u(2);
ail=u(3);
rdr=u(4);
%
%  Limits for table look-ups.  Add some space for 
%  extrapolation in alpha and beta.  
%
%alphad=max([-10,min([alphad,45])]);
%betad=max([-30,min([betad,30])]);
alphad=max([-45,min([alphad,80])]);
betad=max([-45,min([betad,45])]);
alt=max([0,min([alt,50000])]);
pow=max([0,min([pow,100])]);
thtl=max([0,min([thtl,1])]);
stab=max([-25,min([stab,25])]);
ail=max([-21.5,min([ail,21.5])]);
rdr=max([-30,min([rdr,30])]);
%
%  Compute air data.
%
[mach,qbar]=atm(vt,alt);
%
%  Compute engine thrust.
%
thrust=f16_engine_mod(pow,alt,mach,LUTvalues);
%
%  Compute aerodynamic force and moment coefficients.
%
[CX,CY,CZ,C1,Cm,Cn]=f16_aero_mod(vt,alphad,betad,prad,qrad,rrad,stab,ail,rdr,xcg,LUTvalues);
%
forces = [CX,CY,CZ,C1,Cm,Cn];
%
%  Compute quantities used often in the state equations. 
%
cb=cos(beta);
ub=vt*cos(alpha)*cb;
vb=vt*sin(beta);
wb=vt*sin(alpha)*cb;
sth=sin(the);  cth=cos(the);
sph=sin(phi);  cph=cos(phi);
sps=sin(psi);  cps=cos(psi);
qs=qbar*sarea; qsb=qs*bspan;
%
%  Translational acceleration.
%
accel(1)=(qs*CX + thrust)/(c(10)*g);
accel(2)=qs*CY/(c(10)*g);
accel(3)=qs*CZ/(c(10)*g);
%
%  Force equations.
%
udot=rrad*vb-qrad*wb-g*sth + (qs*CX + thrust)/c(10);
vdot=prad*wb-rrad*ub+g*cth*sph + qs*CY/c(10);
wdot=qrad*ub-prad*vb+g*cth*cph + qs*CZ/c(10);
%
%  vt equation.
%
xd(1)=(ub*udot + vb*vdot + wb*wdot)/vt;
%
%  beta equation.
%
xd(2)=(vt*vdot - vb*xd(1))/(cb*vt*vt);
%
%  alpha equation.
%
xd(3)=(wdot*ub - wb*udot)/(ub*ub + wb*wb);
%
%  Moment equations.
%
%  p equation.
%
xd(4)=(c(2)*prad + c(1)*rrad - c(4)*heng)*qrad + qsb*(c(3)*C1 + c(4)*Cn);
%
%  q equation.
%
xd(5)=(c(5)*prad + c(7)*heng)*rrad + c(6)*(rrad*rrad - prad*prad) + qs*cbar*c(7)*Cm;
%
%  r equation.
%
xd(6)=(c(8)*prad - c(2)*rrad - c(9)*heng)*qrad + qsb*(c(4)*C1 + c(9)*Cn);
%
%  Kinematic equations.
%
%
%  phi equation.
%
xd(7)=prad + sth*xd(9);
%
%  the equation.
%
xd(8)=qrad*cph-rrad*sph;
%
%  psi equation.
%
% Corrects for singularity at theta = +/- 90 deg
%
if the >= 1.57062 & the <= pi/2.0 
  xd(9)=5730*(qrad*sph + rrad*cph);
  the=1.571;
elseif  the >= -pi/2.0 & the <= -1.57062
  xd(9)=5730*(qrad*sph + rrad*cph);
  the=-1.571;
elseif the >= pi/2.0 & the <= 1.57097
  xd(9)=-5730*(qrad*sph + rrad*cph);
  the=1.57;
elseif the >= -1.57097 & the <= -pi/2.0 
  xd(9)=-5730*(qrad*sph + rrad*cph);
  the=-1.57;
else 
  xd(9)=(qrad*sph + rrad*cph)/cth;
end
%
%  Navigation equations.
%
bte=[cth*cps,sph*cps*sth-cph*sps,cph*sth*cps+sph*sps;...
     cth*sps,sph*sps*sth+cph*cps,cph*sth*sps-sph*cps;...
     sth,-sph*cth,-cph*cth];
xd(10:12)=bte*[ub,vb,wb]';
%
%  Power level equation.
%
cpow=tgear(thtl);
xd(13)=pdot(pow,cpow);
%
%  Angular acceleration.
%
accel(4)=xd(4);
accel(5)=xd(5);
accel(6)=xd(6);
return
