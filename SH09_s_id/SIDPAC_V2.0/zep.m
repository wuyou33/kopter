function [zz,trend] = zep(z)
%
%  ZEP  Fixes endpoints of a time series to zero.  
%
%  Usage: [zz,trend] = zep(z);
%
%  Description:
%
%    Removes a linear trend from each column of input matrix z.
%    The resulting matrix zz consists of the columns of z 
%    with endpoints fixed to zero.
%
%  Input:
%
%     z = vector or matrix of measured time series.
%
%  Output:
%
%      zz = vector or matrix of measured time series
%           with endpoints fixed to zero.  
%   trend = linear trend removed = z - zz.
%
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      13 May 1995 - Created and debugged, EAM.
%      08 Feb 2006 - Added trend output, EAM.
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
zz=zeros(npts,no);
trend=zeros(npts,no);
iv=[0:1:npts-1]'/(npts-1);
for j=1:no,
  trend(:,j)=ones(npts,1)*z(1,j) + iv*(z(npts,j)-z(1,j));
  zz(:,j)=z(:,j)-trend(:,j);
end
return
