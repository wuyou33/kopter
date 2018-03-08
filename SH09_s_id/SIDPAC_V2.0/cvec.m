function yc = cvec(y)
%
%  CVEC  Makes any input vector into a column vector.  
%
%  Usage: yc = cvec(y);
%
%  Description:
%
%    Makes y vector into a column vector. 
%
%  Input:
%    
%    y = input vector.
%
%  Output:
%
%    yc = column vector with same elements as y.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      02 Mar 2000 - Created and debugged, EAM.
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
[m,n]=size(y);
if n > m
  yc=y';
else
  yc=y;
end
yc=yc(:,1);
return
