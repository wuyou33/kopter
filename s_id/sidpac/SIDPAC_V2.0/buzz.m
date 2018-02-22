function z = buzz(y,nselev,lnse)
%
%  BUZZ  Adds white noise to time series.
%
%  Usage: z = buzz(y,nselev,lnse);
%
%  Description:
%
%    Corrupts y using Gaussian random noise with 
%    standard deviation equal to nselev times 
%    the root mean square value of each column of y,
%    if lnse=0 or if lnse is omitted.  If lnse=1,
%    the noise level multiplies the root mean square 
%    value of the variation of each column of y about
%    its mean value, so that the noise level applies 
%    only to the variation in the columns of y.  
%
%  Input:
%
%        y = matrix of column vector time series.
%   nselev = noise level in terms of the root mean square values
%            of the columns of y.  For example, if nselev=0.1, 
%            then the signal to noise ratio of z will be 10 to 1.  
%     lnse = noise level flag (optional):
%            = 0 for nselev applied to rms of columns of y (default)
%            = 1 for nselev applied to rms of the variation of columns of y
%
%  Output:
%
%        z = matrix of column vector time series of y with 
%            added Gaussian white noise. 
%

%
%    Calls:
%      cvec.m
%      rms.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      28 Mar 1996 - Created and debugged, EAM.
%      12 Mar 2003 - Modified to allow different noise levels
%                    for each individual column of y, EAM.
%      23 Jun 2006 - Modified to include an option to apply the noise level 
%                    to the rms of the variations in y, excluding the mean value, EAM.
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
[npts,n]=size(y);
if nargin<3 | isempty(lnse)
  lnse=0;
end
nselev=cvec(nselev);
if length(nselev)~=n
  nselev=nselev(1)*ones(n,1);
end
randn('seed',sum(100*clock));
for j=1:n,
  if lnse==0
    nse(:,j)=nselev(j)*rms(y(:,j))*randn(npts,1);
  else
    nse(:,j)=nselev(j)*rms(y(:,j)-mean(y(:,j)))*randn(npts,1);
  end
end
z=y+nse;
return
