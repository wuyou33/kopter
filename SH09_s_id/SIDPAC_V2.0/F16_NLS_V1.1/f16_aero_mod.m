function [CX,CY,CZ,C1,Cm,Cn] = f16_aero_mod(vt,alpha,beta,p,q,r,stab,ail,rdr,xcg,LUTvalues)
%
%  F16_AERO  Computes non-dimensional aerodynamic force and moment coefficients.
%
%  Usage: [CX,CY,CZ,C1,Cm,Cn] = f16_aero(vt,alpha,beta,p,q,r,stab,ail,rdr,xcg);
%
%  Description:
%
%    Computes non-dimensional aerodynamic force and moment 
%    coefficients for the F-16 nonlinear simulation.
%
%
%  Input:
%    
%     vt  = airspeed, ft/sec.
%   alpha = angle of attack, deg.
%    beta = sideslip angle, deg.
%     p   = roll rate, rad/sec.
%     q   = pitch rate, rad/sec.
%     r   = yaw rate, rad/sec.
%   stab  = stabilator deflection, deg.
%    ail  = aileron deflection, deg.
%    rdr  = rudder deflection, deg.
%    xcg  = longitudinal c.g. location in fraction of the m.a.c.
%
%  Output:
%
%    CX = body axis x force coefficient.
%    CY = body axis y force coefficient.
%    CZ = body axis z force coefficient.
%    C1 = rolling moment coefficient.
%    Cm = pitching moment coefficient.
%    Cn = yawing moment coefficient.
%

%
%    Calls:
%      cxo.m, czo.m
%      cmo.m, clo.m, cno.m
%      dlda.m, dldr.m
%      dnda.m, dndr.m
%      dampder.m
%      
%    Author:  Eugene A. Morelli
%
%    History:  
%     05 June 1995 - Created and debugged, EAM.
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
% global CXO CZO CMO CLO CNO DDER
% global DLDA DLDR DNDA DNDR
rtd=180/pi;
xcgr=0.35;
cbar=11.32;bspan=30.;
dstab=stab/25.0;dail=ail/20.0;drdr=rdr/30.0;
%
%  Aerodynamic forces.
%
CXt=cxo_mod(alpha,stab,LUTvalues);
CY=-0.02*beta+0.021*dail+0.086*drdr;
CZt=czo_mod(alpha,LUTvalues);
CZ=CZt*(1.-(beta/rtd)^2)-0.19*dstab;
%
%  Aerodynamic moments.
%
C1t=clo_mod(alpha,beta,LUTvalues);
dC1da=dlda_mod(alpha,beta,LUTvalues);
dC1dr=dldr_mod(alpha,beta,LUTvalues);
C1=C1t + dC1da*dail + dC1dr*drdr;
Cmt=cmo_mod(alpha,stab,LUTvalues);
Cnt=cno_mod(alpha,beta,LUTvalues);
dCnda=dnda_mod(alpha,beta,LUTvalues);
dCndr=dndr_mod(alpha,beta,LUTvalues);
Cn=Cnt + dCnda*dail + dCndr*drdr;
%
%  Add damping derivative contributions 
%  and cg position terms.  
%
tvt=2*vt;b2v=bspan/tvt;cq2v=cbar*q/tvt;
d=dampder_mod(alpha,LUTvalues);
CX=CXt + cq2v*d(1);
CY=CY + b2v*(d(3)*p + d(2)*r);
CZ=CZ + cq2v*d(4);
C1=C1 + b2v*(d(6)*p + d(5)*r);
Cm=Cmt + cq2v*d(7) + CZ*(xcgr-xcg);
Cn=Cn + b2v*(d(9)*p + d(8)*r)...
   - CY*(xcgr-xcg)*cbar/bspan;
return
