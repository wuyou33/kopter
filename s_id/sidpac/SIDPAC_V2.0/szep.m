function zszep = szep(z,t)
%
%  SZEP  Fixes smoothed endpoints of time series to zero.  
%
%  Usage: zszep = szep(z,t);
%
%  Description:
%
%    Removes a linear trend from each column of input matrix z
%    using smoothed endpoint estimates.  The resulting matrix zszep
%    consists of the columns of z with endpoints fixed to zero.
%
%  Input:
%    
%     z = vector or matrix of measured time series.
%     t = time vector.
%
%  Output:
%
%    zszep = vector or matrix of measured time series
%            with smoothed endpoints fixed to zero.  
%
%

%
%    Calls:
%      xsmep.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      28 May 1995 - Created and debugged, EAM.
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
[npts,no]=size(z);
dt=t(2)-t(1);
zsmep=xsmep(z,1.0,dt);
iv=[0:1:npts-1]'/(npts-1);
for j=1:no,
  zszep(:,j)=zsmep(:,j)-ones(npts,1)*zsmep(1,j)-iv*(zsmep(npts,j)-zsmep(1,j));
end
return
