function [CX,CY,CZ,CD,CYw,CL,CT,phat,qhat,rhat] = compfc(fdata,cbar,bspan,sarea)
%
%  COMPFC  Computes non-dimensional force coefficients.
%
%  Usage: [CX,CY,CZ,CD,CYw,CL,CT,phat,qhat,rhat] = compfc(fdata,cbar,bspan,sarea);
%
%  Description:
%
%    Computes the non-dimensional force coefficients 
%    and non-dimensional angular rates based
%    on measured flight data from input data array fdata.
%    Inputs cbar, bspan, and sarea can be omitted if
%    fdata contains this information.  
%
%  Input:
%    
%    fdata = flight data array in standard configuration.
%     cbar = wing mean aerodynamic chord, ft.
%    bspan = wing span, ft.
%    sarea = wing area, ft2.
%
%  Output:
%
%      CX = non-dimensional body-axis X coefficient.
%      CY = non-dimensional body-axis Y coefficient.
%      CZ = non-dimensional body-axis Z coefficient.
%      CD = non-dimensional stability-axis drag coefficient.
%     CYw = non-dimensional wind-axis side force coefficient.
%      CL = non-dimensional stability-axis lift coefficient.
%      CT = non-dimensional thrust coefficient.
%    phat = non-dimensional roll rate.
%    qhat = non-dimensional pitch rate.
%    rhat = non-dimensional yaw rate.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      13 Jan  2000 - Created and debugged, EAM.
%      07 Sept 2001 - Modified to include time-varying mass, EAM.
%      12 July 2002 - Made geometry inputs optional, EAM.
%      15 Sept 2004 - Added error checks for airspeed and qbar, EAM.
%      30 May  2006 - Corrected CD and CL descriptive comments, EAM.
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
dtr=pi/180;
g=32.174;
if nargin < 4
  sarea=fdata(1,77);
end
if nargin < 3
  bspan=fdata(1,78);
end
if nargin < 2
  cbar=fdata(1,79);
end
if ((sarea <=0) | (bspan <= 0) | (cbar <= 0))
  fprintf('\n\n Geometry input error in compfc.m \n\n')
  return
end
if (norm(fdata(:,2))==0)
  fprintf('\n\n Zero airspeed error in compfc.m \n\n')
  return
end
if (norm(fdata(:,27))==0)
  fprintf('\n\n Zero qbar error in compfc.m \n\n')
  return
end
qbars=sarea*fdata(:,27);
mass=fdata(:,48);
CT=sum(fdata(:,[38:41])')'./qbars;
CX=g*mass.*fdata(:,11)./qbars - CT;
CY=g*mass.*fdata(:,12)./qbars;
CZ=g*mass.*fdata(:,13)./qbars;
alfa=fdata(:,4)*dtr;
beta=fdata(:,3)*dtr;
CD=-CX.*cos(alfa) - CZ.*sin(alfa);
CL=CX.*sin(alfa) - CZ.*cos(alfa);
% CDw=CD.*cos(beta) - CY.*sin(beta);
CYw=CY.*cos(beta) + CD.*sin(beta);
phat=fdata(:,5)*dtr*bspan./(2*fdata(:,2));
qhat=fdata(:,6)*dtr*cbar./(2*fdata(:,2));
rhat=fdata(:,7)*dtr*bspan./(2*fdata(:,2));
% phat=fdata(:,5)*dtr*bspan./(2*mean(fdata(:,2)));
% qhat=fdata(:,6)*dtr*cbar./(2*mean(fdata(:,2)));
% rhat=fdata(:,7)*dtr*bspan./(2*mean(fdata(:,2)));
return
