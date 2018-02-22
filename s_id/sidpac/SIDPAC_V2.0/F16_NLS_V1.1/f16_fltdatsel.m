function [fdata,t] = f16_fltdatsel(y,u,t,c)
%
%  F16_FLTDATSEL  Arranges F-16 nonlinear simulation data in standard SIDPAC data format.
%
%  Usage: [fdata,t] = f16_fltdatsel(y,u,t,c);
%
%  Description:
%
%    Arranges F-16 nonlinear simulation data 
%    in standard format for SIDPAC.
%
%  Input:
%    
%    y = matrix of output vectors.
%    u = matrix of control vectors.
%    t = time vector.
%    c  = vector of mass/inertia constants.
%
%  Output:
%
%    fdata = matrix of column vector data.
%        t = time vector.
%
%

%
%    Calls:
%      atm.m
%      compfc.m
%      compmc.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%     28 Jan 2004 - Created and debugged, EAM.
%     03 Feb 2006 - Converted from a script to a function, EAM.
%     02 Aug 2006 - Added time vector output, EAM.
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
%  Assign constants.
%
npts=length(t);
fdata=zeros(npts,90);
rtd=180/pi;
cbar=11.32;	        % ft
bspan=30.0;	        % ft
sarea=300.0;        % ft2
iyy=1/c(7);         % slug-ft2
ixz=c(6)*iyy;       % slug-ft2
izz=ixz*c(3)/c(4);  % slug-ft2
ixx=ixz*c(9)/c(4);  % slug-ft2
mass=c(10);         % slug
xcg=c(11);          % fraction of cbar
%
%  Assign data channels.
%
fdata(:,1)=t;
t=t-t(1);
fdata(:,2)=y(:,1);
fdata(:,3)=y(:,2)*rtd;
fdata(:,4)=y(:,3)*rtd;
fdata(:,[5:7])=y(:,[4:6])*rtd;
fdata(:,[8:10])=y(:,[7:9])*rtd;
fdata(:,[11:13])=y(:,[14:16]);
fdata(:,[14:16])=u(:,[2:4]);
for j=1:npts,
  [mach,qbar,rho]=atm(y(j,1),y(j,12));
  fdata(j,27)=qbar;
  fdata(j,28)=mach;
  fdata(j,29)=rho;
end
fdata(:,30)=y(:,12);
fdata(:,34)=u(:,1);
fdata(:,35)=y(:,13);
fdata(:,38)=y(:,20);
fdata(:,[42:44])=y(:,[17:19])*rtd;
fdata(:,48)=mass*ones(npts,1);
fdata(:,49)=ixx*ones(npts,1);
fdata(:,50)=iyy*ones(npts,1);
fdata(:,51)=izz*ones(npts,1);
fdata(:,52)=ixz*ones(npts,1);
%
%  Non-dimensional aerodynamic force and moment coefficients.
%
[CX,CY,CZ,CD,CYw,CL,CT,phat,qhat,rhat] = compfc(fdata,cbar,bspan,sarea);
[Cl,Cm,Cn] = compmc(fdata,cbar,bspan,sarea);
fdata(:,[61:66])=[CX,CY,CZ,Cl,Cm,Cn];
fdata(:,[67:70])=[CD,CYw,CL,CT];
%
%  Non-dimensional angular rates.
%
fdata(:,71)=phat;
fdata(:,72)=qhat;
fdata(:,73)=rhat;
%
%  Aircraft geometric properties.
%
fdata(:,77)=sarea*ones(npts,1);
fdata(:,78)=bspan*ones(npts,1);
fdata(:,79)=cbar*ones(npts,1);
return
