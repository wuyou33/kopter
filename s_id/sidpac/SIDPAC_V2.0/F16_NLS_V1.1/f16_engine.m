function thrust = f16_engine(pow,alt,mach)
%
%  F16_ENGINE  Computes engine thrust.  
%
%  Usage: thrust = f16_engine(pow,alt,mach);
%
%  Description:
%
%    Computes the engine thrust for 
%    the F-16 nonlinear simulation.
%
%
%  Input:
%    
%     pow = engine power level, percent.
%     alt = altitude, ft.
%    mach = Mach number.
%
%  Output:
%
%   thrust = engine thrust, lbf.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      17 June 1995 - Created and debugged, EAM.
%      17 July 2001 - Added Mach and altitude index limits, EAM.
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
global IDP MLP MXP
%
%  Altitude interpolation.
%
h=0.0001*alt;
i=fix(h);
i=max(0,min(i,4));
dh=h-i;
%
%  Add 1 to the indices because the indexing of IDP 
%  starts at 1, not 0.
%
i=i+1;
rm=5*mach;
m=fix(rm);
m=max(0,min(m,4));
dm=rm-m;
m=m+1;
cdh=1-dh;
s=MLP(i,m)*cdh + MLP(i+1,m)*dh;
t=MLP(i,m+1)*cdh + MLP(i+1,m+1)*dh;
tmil=s+(t-s)*dm;
if pow < 50.0
  s=IDP(i,m)*cdh + IDP(i+1,m)*dh;
  t=IDP(i,m+1)*cdh + IDP(i+1,m+1)*dh;
  tidl=s+(t-s)*dm;
  thrust=tidl + (tmil-tidl)*pow*0.02;
else
  s=MXP(i,m)*cdh + MXP(i+1,m)*dh;
  t=MXP(i,m+1)*cdh + MXP(i+1,m+1)*dh;
  tmax=s+(t-s)*dm;
  thrust=tmil + (tmax-tmil)*(pow-50.)*0.02;
end
return
