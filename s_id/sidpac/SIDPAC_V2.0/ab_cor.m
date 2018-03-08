function [alpha,beta] = ab_cor(alphae,betae,vtrue,p,q,r,xloc,yloc,zloc,xcg,ycg,zcg)
%
%  AB_COR  Corrects angle of attack and sideslip angle measurements to the vehicle c.g. 
%
%  Usage: [alpha,beta] = ab_cor(alphae,betae,vtrue,p,q,r,xloc,yloc,zloc,xcg,ycg,zcg);
%
%  Description:
%
%    Corrects angle of attack and sideslip angle measurements 
%    from sensors located at [xloc,yloc,zloc] to the
%    aircraft center of gravity located at [xcg,ycg,zcg].  
%
%
%  Input:
%    
%    alphae = angle of attack sensor measurement, deg.
%     betae = sideslip angle sensor measurement, deg.
%     vtrue = true airspeed, fps.
%         p = roll rate, dps.
%         q = pitch rate, dps.
%         r = yaw rate, dps.
%      xloc = vector of X FS positions of the alpha and beta sensors, in.
%      yloc = vector of Y BL positions of the alpha and beta sensors, in.
%      zloc = vector of Z WL positions of the alpha and beta sensors, in.
%       xcg = X FS position of the c.g., in.
%       ycg = Y BL position of the c.g., in.
%       zcg = Z WL position of the c.g., in.
%
%
%  Output:
%
%    alpha = angle of attack measurement, corrected to the c.g., deg.
%     beta = sideslip angle measurement, corrected to the c.g., deg.
%

%
%    Calls:
%      cvec.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      07 Mar 2003 - Created and debugged, EAM.
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
dtr=pi/180;
alphae=cvec(alphae)*dtr;
betae=cvec(betae)*dtr;
p=p*dtr;
q=q*dtr;
r=r*dtr;
npts=length(alphae);
aloc=[xloc(1),yloc(1),zloc(1)]';
bloc=[xloc(2),yloc(2),zloc(2)]';
%
%  Implement the position corrections for the
%  angle of attack and sideslip angle measurements
%  due to vehicle rotation.
%
%  Negative signs for the x and z displacements because
%  fuselage station and waterline positive directions
%  are opposite the x and z body axes of the vehicle.  
%
adx=(xcg-aloc(1))/12;
ady=(aloc(2)-ycg)/12;
adz=(zcg-aloc(3))/12;
bdx=(xcg-bloc(1))/12;
bdy=(bloc(2)-ycg)/12;
bdz=(zcg-bloc(3))/12;
%
%  Angle of attack correction for vehicle rotation.
%
alpha=alphae + adx*q./vtrue - ady*p./vtrue;
alpha=alpha/dtr;
%
%  Sideslip angle correction for vehicle rotation.
%
beta=betae - bdx*r./vtrue + bdz*p./vtrue;
beta=beta/dtr;
return
