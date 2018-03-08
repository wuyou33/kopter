function [C1rp,Cmrp,Cnrp] = compmcrp(fdata,rp,lrfo)
%
%  COMPMCRP  Computes non-dimensional moment coefficients about a specified reference point.
%
%  Usage: [C1rp,Cmrp,Cnrp] = compmcrp(fdata,rp,lrfo);
%
%  Description:
%
%    Computes non-dimensional aerodynamic moment 
%    coefficients about the specified point rp.    
%
%  Input:
%    
%    fdata = flight data array in standard configuration.
%       rp = Cartesian coordinates of the moment reference point, in.
%     lrfo = flag indicating the orientation of the reference frame 
%            used to specify the locations of the cg and the rp:
%            = 0 for  +X = aft,  +Y = right,  +Z = up  (default)
%            = 1 for  +X = fwd,  +Y = right,  +Z = down
%
%  Output:
%
%     C1rp = rolling moment coefficient about the rp
%     Cmrp = pitching moment coefficient about the rp
%     Cnrp = yawing moment coefficient about the rp
%

%
%    Calls:
%      cvec.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      09 Feb 2006 - Created and debugged, EAM.
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
npts=size(fdata,1);
rp=cvec(rp);
%
%  Moment arm from cg to rp, converted to feet. 
%
r=(ones(npts,1)*rp' - fdata(:,[45:47]))/12;
if nargin < 3
  lrfo=0;
end
%
%  Convert to + fwd/right/down if lrfo=0.
%
if lrfo == 0
  r=r*diag([-1 1 -1]);
end
%
%  Force and moment coefficients about the cg.
%
fc=fdata(:,[61:63]);
mc=fdata(:,[64:66]);
%
%  Compute moment coefficients about the rp.
%
invb=1/fdata(1,78);
invc=1/fdata(1,79);
mcrp=mc - cross(r,fc,2) * diag([invb,invc,invb]);
C1rp=mcrp(:,1);
Cmrp=mcrp(:,2);
Cnrp=mcrp(:,3);
return
