function [y,p,crb,s2,ph,crbh,s2h,seh,kh] = rlesq(x,z,ff,p0,crb0)
%
%  RLESQ  Recursive least squares linear regression.  
%
%  Usage: [y,p,crb,s2,ph,crbh,s2h,seh,kh] = rlesq(x,z,ff,p0,crb0);
%
%  Description:
%
%    Computes recursive least squares estimate of parameter vector p, 
%    where the assumed model structure is y=x*p, ff is the data 
%    forgetting factor, and z is the measured output.
%    Inputs specifying the forgetting factor ff, initial estimated 
%    parameter vector p0, and initial estimated parameter covariance 
%    matrix crb0 are optional.  
%
%  Input:
%    
%     x  = matrix of column regressors.
%     z  = measured output vector.
%     ff = data forgetting factor, usually 0.95 <= ff <= 1.0 (default=1).
%     p0 = initial parameter vector (default=zero vector).
%   crb0 = initial parameter covariance matrix (default=10^6*(identity matrix)).
%
%  Output:
%
%      y = model output using final estimated parameters.
%      p = final estimated parameter vector.
%    crb = final estimated parameter covariance matrix.
%     s2 = final model fit error variance estimate.  
%     ph = estimated parameter vector history.  
%   crbh = estimated parameter covariance matrix history.  
%    s2h = estimated model fit error variance history.
%    seh = estimated parameter standard error history.
%     kh = recursive least squares innovation weighting vector history.  
%

%
%    Calls:
%      cvec.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      18 Mar  1996 - Created and debugged, EAM.
%      20 Sept 2000 - Updated notation, changed history 
%                     arrays for convenient plotting, EAM.
%      21 Sept 2001 - Added data forgetting factor, EAM.
%      05 July 2004 - Changed initial covariance matrix, 
%                     added s2 and s2h outputs, EAM.
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
[npts,np]=size(x);
z=z(:,1);
if nargin < 3 | isempty(ff)
  ff=1;
end
if nargin < 4
  p0=zeros(np,1);
end
if nargin < 5
  crb0=1.0e6*eye(np,np);
end
%
%  Initialization.
%
ph=zeros(npts,np);
seh=zeros(npts,np);
crbh=zeros(npts,np,np);
s2h=zeros(npts,1);
kh=zeros(npts,np);
p0=cvec(p0);
p=p0;
crb=crb0;
ss2=(z(1)-x(1,:)*p0)^2;
ph(1,:)=p0';
seh(1,:)=sqrt(diag(crb0))';
crbh(1,:,:)=crb0;
s2h(1)=ss2;
%
%  Recursive least squares loop.
%
for k=2:npts,
  xk=x(k,:)';
  den=(ff + xk'*crb*xk);
  kk=crb*xk/den;
  p=p + kk*(z(k) - xk'*p);
%
%  Use updated p to compute the sum of 
%  squared residuals. 
%
  ss2=ss2 + (z(k) - xk'*p)^2;
  crb=(1/ff)*(crb - crb*xk*xk'*crb/den);
  kh(k,:)=kk';
  ph(k,:)=p';
  if k <= 5*np
    s2=ss2/k;
  else
    s2=ss2/(k-np);
  end
  seh(k,:)=sqrt(diag(crb))';
  crbh(k,:,:)=crb;
  s2h(k)=s2;
end
%
%  Scale the standard error history 
%  and the final parameter covariance matrix 
%  using the best (final) estimate of 
%  the fit error variance, s2.  
%
seh=sqrt(s2)*seh;
crb=s2*crb;
y=x*p;
return
