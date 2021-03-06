function [fdata_sid,fds] = harv2sid(fdata)
%
%  HARV2SID  Converts flight data for F-18 HARV to standard SIDPAC format.
%
%  Usage: [fdata_sid,fds] = harv2sid(fdata);
%
%  Description:
%
%    Converts standard fdata array for F-18 HARV
%    flight tests to the standard SIDPAC configuration.
%
%  Input:
%    
%    fdata = flight test data array in F-18 HARV standard configuration.
%
%  Output:
%
%    fdata_sid = flight test data array in SIDPAC standard configuration.
%       varlab = standard variable labels.
%

%
%    Calls:
%      fds_init.m
%      deriv.m
%      smoo.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      15 Oct 2000 - Created and debugged, EAM.
%      27 Jan 2001 - Added channels, added smoothed angular 
%                    accelerations and non-dimensional angular rates, EAM.
%      24 Feb 2001 - Corrected control surface labels, EAM.
%      01 Jan 2006 - Changed output to fds, EAM.
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
g=32.174;
sarea=400.0;
bspan=37.42;
cbar=11.52;
dtr=pi/180.0;
t=fdata(:,1);
dt=1/round(1/(t(2)-t(1)));
[npts,n]=size(fdata);
fdata_sid=zeros(npts,90);
%
%  Aircraft state variables.
%
fdata_sid(:,[1:10])=fdata(:,[1:10]);
%
%  Check for acceleration in ft/sec2. 
%
if abs(mean(fdata([1:10],50))) > 10.0
  fdata_sid(:,[11:13])=fdata(:,[48:50])/g;
else
  fdata_sid(:,[11:13])=fdata(:,[48:50]);
end
%
%  Control surface deflections.
%
fdata_sid(:,[14:24])=fdata(:,[14:24]);
%
%  Dynamic pressure, Mach number, air density and altitude.
%
fdata_sid(:,27)=fdata(:,27);
fdata_sid(:,28)=fdata(:,25);
fdata_sid(:,29)=fdata(:,28);
fdata_sid(:,30)=fdata(:,26);
%
%  Check for later version of fdata.
%
if n>=63
  fdata_sid(:,[31:33])=fdata(:,[61:63]);
end
%
%  Throttle setting and thrust.
%
fdata_sid(:,[34:35])=fdata(:,[32:33]);
fdata_sid(:,[38:39])=fdata(:,[34:35]);
%
%  Angular accelerations.
%
fdata_sid(:,[42:44])=fdata(:,[37:39]);
%
%  c.g. position.
%
fdata_sid(:,[45:47])=fdata(:,[52:54]);
%
%  Mass properties.
%
fdata_sid(:,48)=fdata(:,51)/g;
fdata_sid(:,[49:52])=fdata(:,[55:58]);
%
%  Raw accelerometer measurements.
%
fdata_sid(:,[53:55])=fdata(:,[11:13]);
%
%  Use smoothed numerically differentiated angular 
%  rates for the angular accelerations.  
%
%fprintf('\n\n\nFor the angular acceleration smoothing: \n')
aar=deriv(fdata_sid(:,[5:7]),dt);
%aa=smoo(aar,t,2.0);
fdata_sid(:,[42:44])=aar;
%
%  Alpha and beta time derivatives. 
%
%fprintf('\n\n\nFor the alpha derivative smoothing: \n')
alfdr=deriv(fdata_sid(:,4),dt);
%alfd=smoo(alfdr,t,2.0);
fdata_sid(:,56)=alfdr;
%fprintf('\n\n\nFor the beta derivative smoothing: \n')
betadr=deriv(fdata_sid(:,3),dt);
%betad=smoo(betadr,t,2.0);
fdata_sid(:,57)=betadr;
%
%  Thrust vectoring.
%
fdata_sid(:,[58:60])=fdata(:,[43:45]);
%
%  Non-dimensional angular rates.
%
fdata_sid(:,71)=fdata_sid(:,5)*dtr*bspan./(2*fdata_sid(:,2));
fdata_sid(:,72)=fdata_sid(:,6)*dtr*cbar./(2*fdata_sid(:,2));
fdata_sid(:,73)=fdata_sid(:,7)*dtr*bspan./(2*fdata_sid(:,2));
%
%  Aircraft geometry.
%
fdata_sid(:,77)=sarea*ones(npts,1);
fdata_sid(:,78)=bspan*ones(npts,1);
fdata_sid(:,79)=cbar*ones(npts,1);
%
%  Initialize the flight data structure.
%
fds=fds_init;
%
%  Correct the default elevator control surface label. 
%
fds.varlab{14}='  stab ';
return
