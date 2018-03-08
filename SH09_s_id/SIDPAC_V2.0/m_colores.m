function [crb,crbo] = m_colores(dsname,p,u,t,x0,c,z,del)
%
%  M_COLORES  Vectorized version of colores.m.
%
%  Usage: [crb,crbo] = m_colores(dsname,p,u,t,x0,c,z,del);
%
%  Description:
%
%    Computes the Cramer-Rao bounds for maximum likelihood
%    estimation both conventionally and accounting for 
%    the actual frequency content of the residuals.  
%    The dynamic system is specified in the file named dsname.  
%    Input del is optional.  This routine is vectorized
%    for increased execution speed.  Results are the same 
%    as for the slower routine, colores.m.
%
%  Input:
%    
%    dsname = name of the file that computes the model outputs.
%         p = vector of parameter values.
%         u = input vector or matrix.
%         t = time vector.
%        x0 = state vector initial condition.
%         c = constants passed to dsname.
%         z = measured output vector or matrix.
%       del = vector of parameter perturbations in 
%             fraction of nominal value (optional).
%
%  Output:
%
%     crb  = corrected Cramer-Rao bounds accounting for colored residuals.
%     crbo = conventional Cramer-Rao bounds.
%

%
%    Calls:
%      estrr.m
%      senest.m
%      misvd.m
%      xcorrs.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      02 Feb 1998 - Created and debugged, EAM.
%      09 Aug 2006 - Replaced xcorr.m with xcorrs.m, EAM.
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
[npts,no]=size(z);
np=length(p);
if nargin < 8
  del=0.01*ones(np,1);
end
y=eval([dsname,'(p,u,t,x0,c)']);
rr=estrr(y,z);
vv=inv(rr);
ifd=1;
dydp=senest(dsname,p,u,t,x0,c,del,no,ifd);
senmat=zeros(no*npts,np);
sen=zeros(no,np);
infomat=zeros(np,np);
v=z-y;
%
%  Compute an unbiased estimate of the residual autocorrelation.
%  Keep only positive lags, since the autocorrelation is an even function.  
%
rvv=xcorrs(v,'unbiased');
rvv=rvv([npts:2*npts-1],:);
rvvmat=zeros(no,no*(2*npts-1));
rvvk=zeros(no,no);
%
%  Arrange the data as a sequence of matrices and compute the 
%  conventional Cramer-Rao bounds.
%
for i=1:npts,
  io=no*(i-1);
  for j=1:np,
    jo=no*(j-1);
    senmat([io+1:io+no],j)=dydp(i,[jo+1:jo+no])';
  end
  sen=senmat([io+1:io+no],:);
  senmat([io+1:io+no],:)=vv*senmat([io+1:io+no],:);
  infomat=infomat + sen'*vv*sen;
  ipo=no*((npts-1) + (i-1));
  ino=no*((npts-1) - (i-1));
  for j=1:no,
    jo=no*(j-1);
    rvvk(j,:)=rvv(i,[jo+1:jo+no]);
  end
%
%  Keep only diagonal elements, to be consistent with
%  the uncorrelated noise processes assumption.
%
%  rvvk=diag(diag(rvvk));
  rvvmat(:,[ipo+1:ipo+no])=rvvk;
  rvvmat(:,[ino+1:ino+no])=rvvk;
end
crbo=misvd(infomat);
%
%  Corrected Cramer-Rao bound calculation outer loop.
%
crbsum=zeros(np,np);
for i=1:npts,
  io=no*(i-1);
%
%  Inner loop sum.
%
  ijo=no*((npts-1)-(i-1));
  sumat=rvvmat(:,[ijo+1:ijo+no*npts])*senmat;
  crbsum=crbsum + senmat([io+1:io+no],:)'*sumat;
end
crb=crbo'*crbsum*crbo;
return
