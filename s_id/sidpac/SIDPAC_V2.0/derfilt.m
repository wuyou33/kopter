function aa = derfilt(av,dt)
%
%  DERFILT  Derivative filter.  
%
%  Usage: aa = derfilt(av,dt);
%
%  Description:
%
%    Computes smoothed derivatives of measured time series 
%    using only past and current values.
%
%  Input:
%    
%    av = matrix of column vector time series.
%    dt = sampling interval, sec.
%
%  Output:
%
%    aa = smoothed time derivative of column vector time series.
%
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      07 Feb 2000 - Created and debugged, EAM.
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
[npts,n]=size(av);
aa=zeros(npts,n);
for j=5:npts,
  aa(j,:)=(54*av(j,:)-13*av(j-1,:)-40*av(j-2,:)...
            -27*av(j-3,:)+26*av(j-4,:))/(70*dt);
end
return
