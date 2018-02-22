function [vt,beta,alfa,u,v,w] = airchk(fdata)
%
%  AIRCHK  Computes reconstructed air data for data compatibility analysis.
%
%  Usage: [vt,beta,alfa,u,v,w] = airchk(fdata);
%
%  Description:
%
%    Integrates body-axis translational kinematic equations
%    to obtain reconstructed air data.  This routine 
%    is used to assess compatibility of the measured data from
%    sensors for rigid-body translational motion.  
%
%  Input:
%    
%    fdata = flight test data array in standard configuration.
%
%  Output:
%
%       vt = reconstructed airspeed, ft/sec.
%     beta = reconstructed sideslip angle, deg.
%     alfa = reconstructed angle of attack, deg.
%        u = reconstructed x body-axis velocity component, ft/sec.
%        v = reconstructed y body-axis velocity component, ft/sec.
%        w = reconstructed z body-axis velocity component, ft/sec.
%

%
%    Calls:
%      rk4.m
%      aireom.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      24 June 2001 - Created and debugged, EAM.
%      17 May  2006 - Corrected flow angle units, EAM.
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
g=32.174;
%
%  Kinematic equation inputs.
%
uf=[fdata(:,[11:13])*g,fdata(:,[5:10])*dtr];
%
%  Initial conditions.
%
beta0=fdata(1,3)*dtr;
alfa0=fdata(1,4)*dtr;
x0=fdata(1,2)*[cos(alfa0)*cos(beta0),sin(beta0),sin(alfa0)*cos(beta0)]';
c=0.0;
%
%  Integrate the kinematic equations.
%
x=rk4('aireom',uf,t,x0,c);
u=x(:,1);
v=x(:,2);
w=x(:,3);
%
%  Compute re-constructed outputs.
%
vt=sqrt(u.^2 + v.^2 + w.^2);
beta=asin(v./vt)/dtr;
alfa=atan(w./u)/dtr;
return
