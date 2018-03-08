function [y,x] = dcmp(p,u,t,x0,c)
%
%  DCMP  Computes reconstructed outputs for data compatibility analysis.
%
%  Usage: [y,x] = dcmp(p,u,t,x0,c);
%
%  Description:
%
%    Model m-file for data compatibility analysis 
%    using output-error parameter estimation.
%
%  Input:
%
%      p = vector of parameter values.
%      u = matrix of column vector inputs 
%          = [ax,ay,az,p,q,r,u,v,w,phi,the,psi].
%      t = time vector.
%     x0 = initial state vector.
%      c = cell structure (defined in dcmp_psel.m):
%          c.p0c = vector of initial parameter values.
%          c.ipc = index vector to select the parameters to be estimated.
%          c.ims = index vector to select measured states.
%          c.imo = index vector to select model outputs.
%
%  Output:
%
%    y = matrix of column vector model outputs 
%        = [V,alpha,beta,phi,the,psi].
%    x = matrix of column vector model states 
%        = [u,v,w,phi,the,psi].
%

%
%    Calls:
%      adamb3.m
%      runk2.m
%      dcmp_eqs.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      22 Oct 2000 - Created and debugged, EAM.
%      28 Oct 2000 - Added general model structure capability, EAM.
%      29 Nov 2000 - Switched numerical integration 
%                    to 3rd order Adams-Bashforth, EAM.
%      24 Mar 2006 - Combined with dcmp_out.m, EAM.
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
p0c=c.p0c;
ipc=c.ipc;
ims=c.ims;
imo=c.imo;
npts=length(t);
n=length(x0);
%
%  Compute state vector time history.  
%
%x=runk2('dcmp_eqs',p,u,t,x0,c);
x=adamb3('dcmp_eqs',p,u,t,x0,c);
%
%  Compute output vector time history. 
%
%
%  Compute output vector time histories 
%  according to imo, and substitute measured 
%  state time histories as indicated by ims.  
%
%  Assign the estimated parameter vector 
%  elements in p to the proper data compatibility 
%  parameter vector elements in pc.  
%
pc=p0c;
pcindx=find(ipc==1);
np=length(pcindx);
if np > 0
  pc(pcindx)=p;
end
%
%  Substitute measured values for states 
%  as indicated by ims.
%
msindx=find(ims==1);
nms=length(msindx);
if nms > 0
  x(:,msindx)=u(:,6+msindx);
end
%
%
%  Output equations.
%
y=zeros(npts,n);
%
%  Longitudinal outputs.
%
%  Airspeed.
%
vt0=sqrt(x(1,1)*x(1,1) + x(1,2)*x(1,2) + x(1,3)*x(1,3));
y(:,1)=(1+pc(7))*(sqrt(x(:,1).^2 + x(:,2).^2 + x(:,3).^2) - vt0*ones(npts,1)) ...
                + (vt0 + pc(10))*ones(npts,1);
%y(:,1)=(1+pc(7))*sqrt(x(:,1).^2 + x(:,2).^2 + x(:,3).^2) + pc(10);
%
%  Angle of attack.
%
alf0=atan2(x(1,3),x(1,1));
y(:,3)=(1.0+pc(9))*(atan2(x(:,3),x(:,1)) - alf0*ones(npts,1)) ...
                  + (alf0 + pc(12))*ones(npts,1);
%y(:,3)=(1.0+pc(9))*atan2(x(:,3),x(:,1)) + pc(12);
%
%  Euler pitch angle.
%
the0=x(1,5);
y(:,5)=(1.0+pc(14))*(x(:,5)-the0*ones(npts,1)) + (the0 + pc(17))*ones(npts,1);
%y(:,5)=(1.0+pc(14))*x(:,5) + pc(17);
%
%
%  Lateral / Directional outputs.
%
%  Sideslip angle.
%
beta0=asin(x(1,2)/sqrt(x(1,1)^2 + x(1,2)^2+ x(1,3)^2));
y(:,2)=(1.0+pc(8))*(asin(x(:,2)./...
                  sqrt(x(:,1).^2 + x(:,2).^2 + x(:,3).^2)) ...
                  - beta0*ones(npts,1)) + (beta0 + pc(11))*ones(npts,1);
%y(:,2)=(1.0+pc(8))*(asin(x(:,2)./...
%                    sqrt(x(:,1).^2 + x(:,2).^2 + x(:,3).^2)) + pc(11);
%
%  Euler roll angle.
%
phi0=x(1,4);
y(:,4)=(1.0+pc(13))*(x(:,4)-phi0*ones(npts,1)) + (phi0 + pc(16))*ones(npts,1);
%y(:,4)=(1.0+pc(13))*x(:,4) + pc(16);
%
%  Euler yaw angle.
%
psi0=x(1,6);
y(:,6)=(1.0+pc(15))*(x(:,6)-psi0*ones(npts,1)) + (psi0 + pc(18))*ones(npts,1);
%  y(:,6)=(1.0+pc(15))*x(:,6) + pc(18);
%
%  Include only the selected model outputs. 
%
y=y(:,find(imo==1));
return
