function [sy,yl] = confin(x,z,p,s2,opt,lplt)
%
%  CONFIN  Computes 95 percent confidence intervals for linear regression model outputs.
%
%  Usage: [sy,yl] = confin(x,z,p,s2,opt,lplt);
%
%  Description:
%
%    Computes the 95 percent confidence interval for an
%    estimated or predicted output, computed from a 
%    matrix of regressors x, estimated parameter 
%    vector p, and the associated fit error variance 
%    estimate s2.  Measured x and z are from the
%    modeling data for the estimated output calculation, 
%    or from the prediction data for the predicted 
%    output calculation.  The estimated or predicted 
%    output is plotted with confidence intervals.   
%
%  Input:
%
%      x = matrix of column regressors.
%      z = measured output vector.
%      p = estimated parameter vector.
%     s2 = fit error variance estimate.
%    opt = estimated or predicted output flag (optional):
%          = 0 for estimated output limits (default)
%          = 1 for predicted output limits 
%   lplt = plot flag (optional):
%          = 0 for no plots (default)
%          = 1 for plots
%
%  Output:
%
%     sy = vector of standard errors for the estimated 
%          or predicted output.
%     yl = model output vector lower and upper limits.
%

%
%    Calls:
%      misvd.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%     04 Dec  2003 - Created and debugged, EAM.
%     27 Apr  2004 = Added plot option, EAM.
%     27 Mar  2006 - Changed name to avoid variable conflict, EAM.
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

%
%  Initialization.
%
[npts,np]=size(x);
if nargin<5 | isempty(opt)
  opt=0;
end
if nargin<6 | isempty(lplt)
  lplt=0;
end
%
%  K matrix maps measured outputs to 
%  model outputs.
%
xtx=real(x'*x);
%xtxi=inv(xtx);
svlim=eps*npts;
[xtxi,sv]=misvd(xtx,svlim);
K=x*xtxi*x';
%
%  Compute model output.
%
y=x*p;
%
%  Compute the estimated or predicted output variances.
%
smat=s2*x*xtxi;
s2y=zeros(npts,1);
for i=1:npts,
  s2y(i)=smat(i,:)*x(i,:)';
end
if opt~=0
  s2y=s2y+s2*ones(npts,1);
end
sy=sqrt(s2y);
%
%  Compute the upper and lower bounds 
%  of the 95 percent confidence interval.  
%
yl=zeros(npts,2);
yl(:,1)=y-2*sy;
yl(:,2)=y+2*sy;
%
%  Plot the results.
%
if lplt==1
  plot([1:npts]',z-y,'b.'),grid on,hold on,
  plot([1:npts]',yl(:,1)-y,'r:'),
  plot([1:npts]',yl(:,2)-y,'r:'),
  hold off;
end
return
