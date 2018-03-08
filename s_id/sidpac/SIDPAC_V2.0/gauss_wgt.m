function w = gauss_wgt(x,xbar,sig)
%
%  GAUSS_WGT  Computes values of a Gaussian probability density function.  
%
%  Usage: w = gauss_wgt(x,xbar,sig);
%
%
%  Description:
%
%    Computes Gaussian weighting function values w 
%    for the independent variable space defined 
%    by independent variable column vectors in x.
%    Input vectors xbar and sig contain the mean values
%    and standard deviations for each column of x.
%    Output w is a vector of Gaussian weightings 
%    with length size(x,1).
%
%  Input:
%
%       x = matrix of independent variable column vectors.
%    xbar = vector of independent variable mean values.
%     sig = vector of independent variable standard deviations.
%
%  Output:
%
%     w = Gaussian weighting function values.  
%

%
%    Calls:
%      cvec.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      17 Sept 2000 - Created and debugged, EAM.
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
[npts,n]=size(x);
if length(xbar)~=n | length(sig)~=n
  fprintf('\n\n Input dimension mismatch in gauss_wgt.m \n\n'),
  return
end
xbar=cvec(xbar)';
sig=cvec(sig)';
%
%  Compute the Gaussian weighting function.
%
%  Normalized independent variable values.
%
z=(x-ones(npts,1)*xbar)./(ones(npts,1)*sig);
%
%  Sum works differently for vectors 
%  and matrices.  
%
if n>1
  w=exp(-0.5*sum((z.^2)')');
else
  w=exp(-0.5*(z.^2));
end
return
