function [zcor,ucor,fdatacor] = sens_cor(pc,uc,zc,x0c,cc,fdata)
%
%  SENS_COR  Applies instrumentation error corrections to measured data.  
%
%  Usage: [zcor,ucor,fdatacor] = sens_cor(pc,uc,zc,x0c,cc,fdata);
%
%  Description:
%
%    Applies measured data corrections using the 
%    estimated instrumentation error parameters 
%    from data compatibility analysis.  
%
%  Input:
%
%      pc = vector of estimated instrumentation error parameter values.
%      uc = matrix of column vector inputs = [ax,ay,az,p,q,r].
%     x0c = state vector initial condition for data compatibility analysis.
%      cc = cell structure:
%            cc.p0c = p0c = vector of initial parameter values.
%            cc.ipc = ipc = index vector to select estimated parameters.
%            cc.ims = ims = index vector to select measured states.
%            cc.imo = imo = index vector to select model outputs.
%      zc = matrix of column vector measured outputs = [vt,beta,alpha,phi,the,psi].
%   fdata = flight data array in standard configuration.
%
%  Output:
%
%       zcor = corrected matrix of column vector outputs = [vt,beta,alpha,phi,the,psi].
%       ucor = corrected matrix of column vector inputs = [ax,ay,az,p,q,r].
%   fdatacor = corrected flight data array in standard configuration.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      02 Jan 2001 - Created and debugged, EAM.
%      03 Apr 2006 - Added output biases, EAM.
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
zcor=zc;
fdatacor=fdata;
ucor=uc(:,[1:6]);
dtr=pi/180.;
g=32.174;
pcor=cc.p0c;
ipc=cc.ipc;
%
%  Assign the estimated parameter vector 
%  elements in pc to the proper data compatibility 
%  parameter vector elements.  
%
pcindx=find(ipc==1);
pcor(pcindx)=pc;
%
%  Accelerometer biases.
%
ucor(:,1)=uc(:,1) + pcor(1);
ucor(:,2)=uc(:,2) + pcor(2);
ucor(:,3)=uc(:,3) + pcor(3);
%
%  Rate gyro biases.
%
ucor(:,4)=uc(:,4) + pcor(4);
ucor(:,5)=uc(:,5) + pcor(5);
ucor(:,6)=uc(:,6) + pcor(6);
%
%  Air-relative velocity vector scale factors.
%
vt0=sqrt(x0c(1)*x0c(1) + x0c(2)*x0c(2) + x0c(3)*x0c(3));
zcor(:,1)=(zc(:,1)-vt0-pcor(10))/(1.0 + pcor(7)) + vt0;
%
beta0=asin(x0c(2)/vt0);
zcor(:,2)=(zc(:,2)-beta0-pcor(11))/(1.0 + pcor(8)) + beta0;
%
alpha0=atan(x0c(3)/x0c(1));
zcor(:,3)=(zc(:,3)-alpha0-pcor(12))/(1.0 + pcor(9)) + alpha0;
%
%  Euler angle scale factors.
%
phi0=x0c(4);
zcor(:,4)=(zc(:,4)-phi0-pcor(16))/(1.0 + pcor(13)) + phi0;
%
the0=x0c(5);
zcor(:,5)=(zc(:,5)-the0-pcor(17))/(1.0 + pcor(14)) + the0;
%
psi0=x0c(6);
zcor(:,6)=(zc(:,6)-psi0-pcor(18))/(1.0 + pcor(15)) + psi0;
%
%  Now update the measured flight test data matrix.
%
if nargin > 5
  fdatacor(:,[11:13])=ucor(:,[1:3])/g;
  fdatacor(:,[5:7])=ucor(:,[4:6])/dtr;
  fdatacor(:,2)=zcor(:,1);
  fdatacor(:,[3:4])=zcor(:,[2:3])/dtr;
  fdatacor(:,[8:10])=zcor(:,[4:6])/dtr;
else
  fdatacor=[];
end
return
