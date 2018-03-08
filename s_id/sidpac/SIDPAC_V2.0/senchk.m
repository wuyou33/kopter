function [nsen,irow,icol,dydp] = senchk(dsname,p,u,t,x0,c,del,no,ifd)
%
%  SENCHK  Checks output sensitivities for correlation.  
%
%  Usage: [nsen,irow,icol,dydp] = senchk(dsname,p,u,t,x0,c,del,no,ifd);
%
%  Description:
%
%    Computes and ranks the norms of output sensitivities 
%    for output-error parameter estimation, where the output 
%    sensitivities are computed using forward or central 
%    finite differences.  The dynamic system is specified 
%    in an m-file or mex-file named dsname.  
%    Inputs del, no, and ifd are optional.  
%
%  Input:
%
%   dsname = name of the file that computes the model outputs.
%        p = vector of parameter values.
%        u = input vector or matrix.
%        t = time vector.
%       x0 = state vector initial condition.
%        c = constants passed to dsname.
%      del = vector of parameter perturbations 
%            in fraction of nominal value (optional).
%       no = number of outputs (optional).
%      ifd = 1 for central differences (default).
%            0 for forward differences.
%
%  Output:
%
%    nsen = vector containing the norm of the output 
%           sensitivity vectors dy/dp, ranked from 
%           smallest to largest norm.  
%    irow = row in the output sensitivity matrix 
%           for the corresponding element in nsen.  
%    icol = column in the output sensitivity matrix
%           for the corresponding element in nsen.
%    dydp = matrix of output sensitivities: 
%
%           [dy/dp(1),dy/dp(2),...,dy/dp(np)].
%
%    2D plots of output sensitivites with the smallest norms.
%

%
%    Calls:
%      senest.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      24 Aug 2004 - Created and debugged, EAM.
%
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
npts=length(t);
np=length(p);
if nargin < 9 | isempty(ifd)
  ifd=1;
end
if nargin < 8 | isempty(no)
  y0=eval([dsname,'(p,u,t,x0,c)']);
  no=size(y0,2);
end
if nargin < 7 | isempty(del)
  del=0.01*ones(np,1);
end
del=abs(del);
%
%  Compute the output sensitivities.
%
dydp=senest(dsname,p,u,t,x0,c,del,no,ifd);
%
%  Find the norm of each output sensitivity.
%
ns=size(dydp,2);
nsen=zeros(ns,1);
for j=1:ns,
  nsen(j)=norm(dydp(:,j));
end
[nsen,indx]=sort(nsen);
%
%  Determine the output and parameter 
%  for each output sensitivity.
%
irow=zeros(ns,1);
icol=zeros(ns,1);
for j=1:ns,
  irow(j)=mod(indx(j)-1,no) + 1;
  icol(j)=ceil(indx(j)/no);
end
%
%  Print out the sensitivities with 
%  the smallest norms.  
%
nsn=3;
for j=1:nsn,
  fprintf('\n For output %i, parameter %i, the norm is %f \n\n',...
          irow(j),icol(j),nsen(j));
  subplot(nsn,1,j),plot(t,dydp(:,indx(j))),
%
%  No X axis labels for the upper plots.
%
  if j < nsn
    set(gca,'XTickLabel',''),
  end
end
return
