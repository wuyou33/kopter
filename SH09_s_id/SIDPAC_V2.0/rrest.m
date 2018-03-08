function rr = rrest(z,zs)
%
%  RREST  Computes a noise covariance matrix estimate based on smoothed time series.
%
%  Usage: rr = rrest(z,zs);
%
%  Description:
%
%    Estimates the discrete noise covariance.  
%
%  Input:
%    
%    z = vector or matrix measured time series.
%    zs = smoothed vector or matrix time series.
%
%  Output:
%
%    rr = scalar or matrix discrete noise covariance estimate. 
%
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      01 Jul 1997 - Created and debugged, EAM.
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
[npts,n]=size(z);
rr=zeros(n,n);
rr=(z-zs)'*(z-zs)/(npts-1);
return
