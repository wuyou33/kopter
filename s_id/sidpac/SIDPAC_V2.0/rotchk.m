function [phi,the,psi] = rotchk(fdata)
%
%  ROTCHK  Computes reconstructed Euler angles for data compatibiliy analysis.
%
%  Usage: [phi,the,psi] = rotchk(fdata);
%
%  Description:
%
%    Integrates body-axis rotational kinematic equations
%    to obtain reconstructed Euler angle time histories.  
%    This routine is used to assess compatibility of the
%    measured data from sensors for rigid-body rotational motion.  
%
%  Input:
%    
%    fdata = flight data array in standard configuration.
%
%  Output:
%
%    phi = reconstructed Euler roll angle, deg.
%    the = reconstructed Euler pitch angle, deg.
%    psi = reconstructed Euler yaw angle, deg.
%

%
%    Calls:
%      rk4.m
%      roteom.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      24 Nov 1996 - Created and debugged, EAM.
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
[npts,n]=size(fdata);
t=fdata(:,1);
t=t-t(1)*ones(npts,1);
dt=t(2)-t(1);
dtr=pi/180;
u=fdata(:,[5:7])*dtr;
x0=fdata(1,[8:10])'*dtr;
c=0.0;
x=rk4('roteom',u,t,x0,c);
phi=x(:,1)/dtr;
the=x(:,2)/dtr;
psi=x(:,3)/dtr;
return
