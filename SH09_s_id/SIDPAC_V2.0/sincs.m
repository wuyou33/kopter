function y = sincs(x)
%
%  SINCS  Computes the value of sin(x)/x.  
%
%  Usage: y = sincs(x);
%
%
%  Description:
%
%    Computes the value of sin(x)/x, for all 
%    real values of x.
%
%  Input:
%
%    x = real scalar or vector.
%
%  Output:
%
%    y = sin(x)/x.
%
%

%
%    Calls:
%      cvec.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      14 Oct  2003 - Created and debugged, EAM.
%      15 Dec  2005 - Changed the function name, EAM.  
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
x=cvec(x);
indx=find(x==0);
%
%  Prevent divide by zero errors.
%
if ~isempty(indx)
  x(indx)=ones(length(indx),1);
end
y=sin(x)./x;
%
%  Regular computation is fine, except
%  for x=0.  
%
if ~isempty(indx)
  y(indx)=ones(length(indx),1);
end
return
