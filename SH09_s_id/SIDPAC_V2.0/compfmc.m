function fdata = compfmc(fdatao,cbar,bspan,sarea)
%
%  COMPFMC  Computes non-dimensional force and moment coefficients.  
%
%  Usage: fdata = compfmc(fdatao,cbar,bspan,sarea);
%
%  Description:
%
%    Computes the non-dimensional aerodynamic force 
%    and moment coefficients and non-dimensional angular rates 
%    based on measured flight data from input data array fdatao.
%    Outputs are stored in standard data array channels
%    in output fdata.  Inputs cbar, bspan, and sarea can 
%    be omitted if fdatao contains this information.  
%
%  Input:
%    
%   fdatao = flight data array in standard configuration.
%     cbar = wing mean aerodynamic chord, ft.
%    bspan = wing span, ft.
%    sarea = wing area, ft2.
%
%  Output:
%
%   fdata = flight data array in standard configuration.
%

%
%    Calls:
%      compfc.m
%      compmc.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      19 Feb  2001 - Created and debugged, EAM.
%      12 July 2002 - Made geometry inputs optional, EAM.
%      14 Sept 2004 - Removed varlab output and channel marking, EAM.
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
[npts,n]=size(fdatao);
fdata=fdatao;
if nargin < 4
  sarea=fdatao(1,77);
end
if nargin < 3
  bspan=fdatao(1,78);
end
if nargin < 2
  cbar=fdatao(1,79);
end
if ((sarea <=0) | (bspan <= 0) | (cbar <= 0))
  fprintf('\n\n Geometry input error in compfmc.m \n')
  return
end
[CX,CY,CZ,CD,CYw,CL,CT] = compfc(fdatao,cbar,bspan,sarea);
fdata(:,[61:63])=[CX,CY,CZ];
fdata(:,[67:70])=[CD,CYw,CL,CT];
[C1,Cm,Cn,phat,qhat,rhat,aa] = compmc(fdatao,cbar,bspan,sarea);
fdata(:,[64:66])=[C1,Cm,Cn];
fdata(:,[71:73])=[phat,qhat,rhat];
fdata(:,[42:44])=aa*180/pi;
%
%  Aircraft geometry.
%
fdata(:,77)=sarea*ones(npts,1);
fdata(:,78)=bspan*ones(npts,1);
fdata(:,79)=cbar*ones(npts,1);
return
