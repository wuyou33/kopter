function zd = nderiv(z,dt)
%
%  NDERIV  Generalized version of deriv.m, with selectable neighboring points and model order.  
%
%  Usage: zd = nderiv(z,dt);
%
%  Description:
%
%    Computes smoothed derivatives of measured time series 
%    by differentiating a local least squares fit 
%    to the set of points consisting of each data point 
%    and its nearest neighboring points.  Points near the 
%    end of the time series are handled with a 
%    cubic least squares fit.  
%
%  Input:
%    
%     z = vector or matrix of measured time series.
%    dt = sampling interval, sec.
%
%  Output:
%
%    zd = vector or matrix of smoothed time derivatives.
%

%
%    Calls:
%      lesq.m
%      misvd.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      27 Dec  2001 - Created and debugged, EAM.
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
[m,n]=size(z);
zd=zeros(m,n);
%
%  Put data in column vectors if necessary,
%  and set the number of data points.
%
if m < n
  zd=zd';
  z=z';
  npts=n;
  nc=m;
else
  npts=m;
  nc=n;
end
%
%  Use nep points at the endpoints for a least 
%  squares cubic fit to the data, then 
%  differentiate the cubic fit to get the 
%  derivative.   
%
nep=20;
vec=[0:nep-1]';
x=[ones(nep,1),vec,vec.^2,vec.^3];
%
%  Initial points.
%
yi=zeros(nep,nc);
yid=zeros(nep,nc);
for j=1:nc,
  [yi(:,j),p]=lesq(x,z([1:nep],j));
  yid(:,j)=(x(:,[1:3])*[p(2),2*p(3),3*p(4)]')/dt;
end
zd([1:nep],:)=yid;
%
%  Final points.
%
yf=zeros(nep,nc);
yfd=zeros(nep,nc);
for j=1:nc,
  [yf(:,j),p]=lesq(x,z([npts-nep+1:npts],j));
  yfd(:,j)=x(:,[1:3])*[p(2),2*p(3),3*p(4)]'/dt;
end
zd([npts-nep+1:npts],:)=yfd;
%
%  Integer k is the number of neighboring points 
%  on each side that are used for the smoothed
%  derivative calculation.  Larger values of k 
%  correspond to a lower cut-off frequency 
%  for the smoothed derivative.
%  Integer nord is the order of the local 
%  least squares model fit to the data.  
%  For smoothing, k > nord-1.  
%
nord=3;
k=16;
%
%  Variable order local least squares fit 
%  with variable number of neighboring points k.
%
%  Number of regressors in the local fit equals
%  the fit order plus one for the constant term.
%  Number of points equals k neighbors on both 
%  sides, plus the center point.  
%
%  Assemble the regressor matrix for the local
%  least squares fit.  
%
x=ones(2*k+1,nord+1);
vec=[-k:k]';
for j=1:nord,
  x(:,j+1)=vec.^j;
end
smat=misvd(x'*x)*x';
%
%  Second row of smat multiplies the z data 
%  to compute the linear parameter estimate, 
%  which equals the derivative at the center point.
%  Divide by dt to account for the use of 
%  integers for time steps in the local 
%  least squares fit calculation.  
%
svec=smat(2,:)/dt;
zd(k+1:npts-k,:)=zeros(npts-2*k,nc);
for n=-k:k,
  j=n+k+1;
  zd(k+1:npts-k,:)=zd(k+1:npts-k,:)+svec(j)*z(k+1+n:npts-k+n,:);
end
%
%  Switch data back to original form, if necessary.
%
if m < n
  zd=zd';
  z=z';
end
return
