function [xd,accel] = nldyn_eqs(p,u,x,c)
%
%  NLDYN_EQS  Implements nonlinear aircraft equations of motion for output-error parameter estimation.  
%
%  Usage: [xd,accel] = nldyn_eqs(p,u,x,c);
%
%  Description:
%
%    Computes the state vector derivatives 
%    and acceleration outputs, using  
%    full nonlinear aircraft dynamics.  
%
%  Input:
%    
%      p = vector of parameter values.
%      u = control vector.
%      x = state vector = [vt,beta,alpha,prad,qrad,rrad,phi,the,psi]'.
%      c = cell structure:
%          c.p0oe   = p0oe   = vector of initial parameter values.
%          c.ipoe   = ipoe   = index vector to select estimated parameters.
%          c.ims    = ims    = index vector to select measured states.
%          c.imo    = imo    = index vector to select model outputs.
%          c.imc    = imc    = index vector to select non-dimensional 
%                              coefficients to be modeled.
%          c.x0     = x0     = initial state vector.
%          c.u0     = u0     = initial control vector.
%                              coefficients to be modeled.
%          c.fdata  = fdata  = standard array of measured flight data, 
%                              geometry, and mass/inertia properties.  
%
%  Output:
%
%       xd = time derivative of the state vector.
%    accel = vector of acceleration outputs = [ax,ay,az,pdot,qdot,rdot]'.
%

%
%    Calls:
%      massprop.m
%
%    Author:  Eugene A. Morelli
%
%    History:
%      07 Oct  2001 - Created and debugged, EAM.
%      14 Oct  2001 - Modified to use numerical integration routines, EAM.
%      23 July 2002 - Added acceleration outputs, EAM.
%      19 Aug  2004 - Added imc, EAM.
%      15 Feb  2006 - Modified for SIDPAC 2.0, EAM.
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
%  Initialization.
%
xd=zeros(length(x),1);
accel=zeros(6,1);
p0oe=c.p0oe;
ipoe=c.ipoe;
ims=c.ims;
imc=c.imc;
x0=c.x0;
u0=c.u0;
ni=length(u0);
dtr=pi/180;
%
%  The fdata information was appended to u, to 
%  accommodate the numerical integration.
%  Use transpose to make fdata a row vector.  
%
fdata=u([ni+1:length(u)])';
%
%  State vector indices in fdata.
%
xindx=[2:10]';
%
%  Assign the estimated parameter vector 
%  elements in p to the proper dynamic model 
%  parameter vector elements in poe.  
%
poe=p0oe;
pindx=find(ipoe==1);
np=length(pindx);
if np > 0
  poe(pindx)=p;
end
%
%  Substitute measured values for states 
%  as indicated by ims.
%
msindx=find(ims==1);
nms=length(msindx);
if nms > 0
%
%  Convert all states to radians, except airspeed.
%
  for j=1:nms
    x(msindx(j))=fdata(xindx(msindx(j)));
    if msindx(j)~=1
      x(msindx(j))=x(msindx(j))*dtr;
    end
  end
end
%
%  Nonlinear aircraft dynamics differential equations 
%  for output-error parameter estimation.
%
%  Assign constants.
%
sarea=fdata(77);
bspan=fdata(78);
cbar=fdata(79);
xcg=fdata(45)/12;
heng=0.0;
g=32.174;
%
%  Mass property calculations work even when 
%  the input fdata matrix has only one row, 
%  as in this case.  
%
[ci,mass,ixx,iyy,izz,ixz,xcg,ycg,zcg]=massprop(fdata);
%
%  Assign state and control variables.
%
vt=x(1);
beta=x(2);
alpha=x(3);
prad=x(4);
qrad=x(5);
rrad=x(6);
% phat=prad*bspan/(2*vt);
% qhat=qrad*cbar/(2*vt);
% rhat=rrad*bspan/(2*vt);
phat=fdata(71);
qhat=fdata(72);
rhat=fdata(73);
phi=x(7);
the=x(8);
psi=x(9);
el=u(1);
ail=u(2);
rdr=u(3);
%
%  Air data.
%
mach=fdata(28);
qbar=fdata(27);
%
%  Engine thrust.
%
thrust=sum(fdata(38:41));
%
%  Aerodynamic force and moment coefficient models.
%
%  CX
%
if imc(1)==0
  CX=fdata(61);
else
  CX=poe(1)*(vt-x0(1))/x0(1) + poe(2)*(alpha-x0(3)) + poe(3)*qhat ...
     + poe(4)*(el-u0(1)) + poe(9);
%  CX=poe(1)*vt/x0(1) + poe(2)*alpha + poe(3)*qhat ...
%     + poe(4)*el + poe(9);
end
%
%  CY
%
if imc(2)==0
  CY=fdata(62);
else
%  CY=poe(11)*(beta-x0(2)) + poe(12)*phat + poe(13)*rhat ...
%     + poe(14)*(ail-u0(2)) + poe(15)*(rdr-u0(3)) + poe(19);
  CY=poe(11)*beta + poe(12)*phat + poe(13)*rhat ...
     + poe(14)*ail + poe(15)*rdr + poe(19);
end
%
%  CZ
%
if imc(3)==0
  CZ=fdata(63);
else
  CZ=poe(21)*(vt-x0(1))/x0(1) + poe(22)*(alpha-x0(3)) + poe(23)*qhat ...
     + poe(24)*(el-u0(1)) + poe(29);
%  CZ=poe(21)*vt/x0(1) + poe(22)*alpha + poe(23)*qhat ...
%     + poe(24)*el + poe(29);
end
%
%  C1
%
if imc(4)==0
  C1=fdata(64);
else
%  C1=poe(31)*(beta-x0(2)) + poe(32)*phat + poe(33)*rhat ...
%     + poe(34)*(ail-u0(2)) + poe(35)*(rdr-u0(3)) + poe(39);
  C1=poe(31)*beta + poe(32)*phat + poe(33)*rhat ...
     + poe(34)*ail + poe(35)*rdr + poe(39);
end
%
%  Cm
%
if imc(5)==0
  Cm=fdata(65);
else
  Cm=poe(41)*(vt-x0(1))/x0(1) + poe(42)*(alpha-x0(3)) + poe(43)*qhat ...
     + poe(44)*(el-u0(1)) + poe(49);
%  Cm=poe(41)*vt/x0(1) + poe(42)*alpha + poe(43)*qhat ...
%     + poe(44)*el + poe(49);
end
%
%  Cn
%
if imc(6)==0
  Cn=fdata(66);
else
%  Cn=poe(51)*(beta-x0(2)) + poe(52)*phat + poe(53)*rhat ...
%     + poe(54)*(ail-u0(2)) + poe(55)*(rdr-u0(3)) + poe(59);
  Cn=poe(51)*beta + poe(52)*phat + poe(53)*rhat ...
     + poe(54)*ail + poe(55)*rdr + poe(59);
end
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
%  Translational acceleration, ft/sec2.
%
accel(1)=(qs*CX + thrust)/ci(10);
accel(2)=qs*CY/ci(10);
accel(3)=qs*CZ/ci(10);
%
%  Force equations.
%
udot=rrad*vb-qrad*wb-g*sth + accel(1);
vdot=prad*wb-rrad*ub+g*cth*sph + accel(2);
wdot=qrad*ub-prad*vb+g*cth*cph + accel(3);
%
%  vt equation.
%
xd(1)=(ub*udot + vb*vdot + wb*wdot)/vt + poe(10);
%
%  beta equation.
%
xd(2)=(vt*vdot - vb*xd(1))/(cb*vt*vt) + poe(20);
%
%  alpha equation.
%
xd(3)=(wdot*ub - wb*udot)/(ub*ub + wb*wb) + poe(30);
%
%  Moment equations.
%
%  p equation.
%
xd(4)=(ci(2)*prad + ci(1)*rrad - ci(4)*heng)*qrad + qsb*(ci(3)*C1 + ci(4)*Cn) + poe(40);
%
%  q equation.
%
xd(5)=(ci(5)*prad + ci(7)*heng)*rrad + ci(6)*(rrad*rrad - prad*prad) + qs*cbar*ci(7)*Cm + poe(50);
%
%  r equation.
%
xd(6)=(ci(8)*prad - ci(2)*rrad - ci(9)*heng)*qrad + qsb*(ci(4)*C1 + ci(9)*Cn) + poe(60);
%
%  Kinematic equations.
%
%  psi equation.
%
xd(9)=(qrad*sph + rrad*cph)/cth + poe(63);
%
%  phi equation.
%
xd(7)=prad + sth*xd(9) + poe(61);
%
%  the equation.
%
xd(8)=qrad*cph-rrad*sph + poe(62);
%
%  Translational acceleration, g.
%
accel(1)=accel(1)/g + poe(64);
accel(2)=accel(2)/g + poe(65);
accel(3)=accel(3)/g + poe(66);
%
%  Angular acceleration.
%
accel(4)=xd(4) + poe(67);
accel(5)=xd(5) + poe(68);
accel(6)=xd(6) + poe(69);
%
return
