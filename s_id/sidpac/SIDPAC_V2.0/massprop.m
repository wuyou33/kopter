function [c,mass,ixx,iyy,izz,ixz,xcg,ycg,zcg] = massprop(fdata)
%
%  MASSPROP  Assembles aircraft mass and moment of inertia data.  
%
%  Usage: [c,mass,ixx,iyy,izz,ixz,xcg,ycg,zcg] = massprop(fdata);
%
%  Description:
%
%    Computes mass properties based on 
%    measured flight data from standard data array fdata.
%
%  Input:
%    
%    fdata = flight test data array in standard configuration.
%
%  Output:
%
%      c = vector of inertia constants for aircraft
%          nonlinear equations of motion.
%   mass = aircraft mass.
%    ixx = body axis X moment of inertia, slug-ft2.
%    iyy = body axis Y moment of inertia, slug-ft2.
%    izz = body axis Z moment of inertia, slug-ft2.
%    ixz = body axis X-Z moment of inertia, slug-ft2.
%    xcg = X C.G. position, in.
%    ycg = Y C.G. position, in.
%    zcg = Z C.G. position, in.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      18 Jan 2000 - Created and debugged, EAM.
%      17 May 2004 - Re-arranged outputs, EAM.
%      09 Jun 2006 - Used built-in mean function, EAM.
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
xcg=mean(fdata(:,45));
ycg=mean(fdata(:,46));
zcg=mean(fdata(:,47));
mass=mean(fdata(:,48));
ixx=mean(fdata(:,49));
iyy=mean(fdata(:,50));
izz=mean(fdata(:,51));
ixz=mean(fdata(:,52));
c=zeros(13,1);
gam=ixx*izz-ixz^2;
c(1)=((iyy-izz)*izz-ixz^2)/gam;
c(2)=(ixx-iyy+izz)*ixz/gam;
c(3)=izz/gam;
c(4)=ixz/gam;
c(5)=(izz-ixx)/iyy;
c(6)=ixz/iyy;
c(7)=1.0/iyy;
c(8)=(ixx*(ixx-iyy)+ixz^2)/gam;
c(9)=ixx/gam;
c(10)=mass;
c(11)=xcg;
c(12)=ycg;
c(13)=zcg;
return
