function y = roundd(x,ndec)
%
%  ROUNDD  Rounds to ndec decimal places.  
%
%  Usage: y = roundd(x,ndec);
%
%  Description:
%
%    Rounds x to ndec decimal places.  
%
%  Input:
%    
%    x = input scalar, vector, or matrix.
%
%  Output:
%
%    y = x rounded to ndec decimal places.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      08 Aug 2006 - Created and debugged, EAM.
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
ndec=round(max(0,ndec));
k=10^ndec;
y=round(k*x)/k;
return
