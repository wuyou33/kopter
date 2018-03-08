function [mach,qbar,rho,sos] = atm(vt,alt)
%
%  ATM  Provides properties of the 1976 standard atmosphere.  
%
%  Usage: [mach,qbar,rho,sos] = atm(vt,alt);
%
%  Description:
%
%    Computes properties of the standard atmosphere.
%
%  Input:
%    
%     vt = true airspeed, ft/sec.
%    alt = altitude, ft.
%
%  Output:
%
%    mach = Mach number.
%    qbar = dynamic pressure, psf.
%     rho = air density, slugs/ft^3.
%     sos = speed of sound, ft/sec.
%

%
%    Calls:
%      cvec.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      17 Jun  1995 - Created and debugged, EAM.
%      12 Dec  2003 - Added speed of sound output, EAM.
%      20 Dec  2005 - Modified to accept vector inputs, EAM.
%
%
%  Copyright (C) 2006  Eugene A. Morelli
%
%
%  This program carries no warranty, not even the implied 
%  warranty of merchantability or fitness for a particular purpose.  
%
%  Please email bug reports or suggestions for improvements to:
%
%      e.a.morelli@nasa.gov
%
ro=0.002377;
vt=cvec(vt);
alt=cvec(alt);
npts=length(vt);
tfac=ones(npts,1) - alt*0.703e-5;
temp=390*ones(npts,1);
indx=find(alt < 35000);
if ~isempty(indx)
  temp(indx)=519.*tfac(indx);
end
rho=ro*(tfac.^4.14);
sos=sqrt(1.4*1716.3*temp);
mach=vt./sos;
qbar=0.5*rho.*vt.*vt;
return
