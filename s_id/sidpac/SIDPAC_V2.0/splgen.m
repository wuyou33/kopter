function x = splgen(data,kts,n)
%
%  SPLGEN  Generates spline functions.  
%
%  Usage: x = splgen(data,kts,n);
%
%  Description:
%
%    Computes nth order splines of the input data vector, 
%    using the values in input vector kts for the knots.  
%
%  Input:
%    
%    data = input data vector.
%     kts = vector of values for the knots.
%       n = spline order.
%
%  Output:
%
%    x = matrix of spline functions in order of the input knot sequence.
%

%
%    Calls:
%      cvec.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      10 Mar 1996 - Created and debugged, EAM.
%      29 Jan 2004 - Updated and changed name from spl.m to splgen.m, EAM.
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
n=round(n);
kts=cvec(kts);
nk=length(kts);
data=cvec(data);
npts=length(data);
x=zeros(npts,nk);
%
%  Make sure knot locations are legal.
%
chk=0;
for j=1:nk,
  if kts(j) < min(data)
    kts(j) = min(data);
    chk = chk + 1;
  end
  if kts(j) > max(data)
    kts(j) = max(data);
    chk = chk + 1;
  end
end
if chk>0
  fprintf('\n\n %3.0f knot(s) out of range \n\n',chk)
  return
end
%
%  Generate the splines.
%
for j=1:nk,
  indx=find(data>=kts(j));
  x(indx,j)=(data(indx)-kts(j)*ones(length(indx),1)).^n;
end
return
