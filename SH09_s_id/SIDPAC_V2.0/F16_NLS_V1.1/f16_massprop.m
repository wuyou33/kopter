function c = f16_massprop;
%
%  F16_MASSPROP  Computes mass properties.  
%
%  Usage: c = f16_massprop;
%
%  Description:
%
%    Computes mass properties for the F-16 nonlinear simulation.
%
%  Inputs:
%    
%    None
%
%  Outputs:
%
%      c  = c(1) through c(9) = inertia constants for aircraft
%           nonlinear equations of motion.
%           c(10) = aircraft mass.
%           c(11) = X c.g. position in fraction of the m.a.c.
%

%
%    Calls:
%      None
%      
%    Author:  Eugene A. Morelli
%
%    History:  
%     12 Mar 1995 - Created and debugged, EAM.
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
g=32.174;
mass=20500.0/g;  % slug
xcg=0.25;        % fraction of cbar
ixx=9496.0;      % slug-ft2
iyy=55814.0;     % slug-ft2
izz=63100.0;     % slug-ft2
ixz=982.0;       % slug-ft2
c=zeros(11,1);
gam=ixx*izz-ixz*ixz;
c(1)=((iyy-izz)*izz-ixz*ixz)/gam;
c(2)=(ixx-iyy+izz)*ixz/gam;
c(3)=izz/gam;
c(4)=ixz/gam;
c(5)=(izz-ixx)/iyy;
c(6)=ixz/iyy;
c(7)=1.0/iyy;
c(8)=(ixx*(ixx-iyy)+ixz*ixz)/gam;
c(9)=ixx/gam;
c(10)=mass;
c(11)=xcg;
return
