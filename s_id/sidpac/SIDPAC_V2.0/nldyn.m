function [y,x,accel] = nldyn(p,u,t,x0,c)
%
%  NLDYN  Solves the nonlinear aircraft equations of motion for output-error parameter estimation.  
%
%  Usage: [y,x,accel] = nldyn(p,u,t,x0,c);
%
%  Description:
%
%    Computes the output vector time history 
%    using full nonlinear aircraft dynamics 
%    for output-error parameter estimation.  
%
%  Input:
%
%      p = vector of parameter values.
%      u = control vector time history = [el,ail,rdr].
%      t = time vector.
%     x0 = initial state vector.
%      c = cell structure:
%          c.p0oe   = p0oe   = vector of initial parameter values.
%          c.ipoe   = ipoe   = index vector to select estimated parameters.
%          c.ims    = ims    = index vector to select measured states.
%          c.imo    = imo    = index vector to select model outputs.
%          c.imc    = imc    = index vector to select non-dimensional 
%                              coefficients to be modeled.
%          c.x0     = x0     = initial state vector.
%          c.u0     = u0     = initial control vector.
%                              coefficients to be modeled.
%          c.fdata  = fdata  = standard array of measured flight data, 
%                              geometry, and mass/inertia properties.  
%
%  Output:
%
%       y = model output vector time history 
%           = [vt,beta,alpha,p,q,r,phi,the,psi].
%       x = model state vector time history 
%           = [vt,beta,alpha,p,q,r,phi,the,psi].
%   accel = acceleration output vector time history 
%           = [ax,ay,az,pdot,qdot,rdot].
%

%
%    Calls:
%      nldyn_eqs.m
%      runk2a.m
%      adamb3a.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      07 Sept 2001 - Created and debugged, EAM.
%      14 Oct  2001 - Modified to use numerical integration routines, EAM.
%      23 July 2002 - Incorporated numerical integration and output calculation, EAM.  
%      17 May  2004 - Re-defined input c, EAM.
%
%  Copyright (C) 2006  Eugene A. Morelli
%
%  This program carries no warranty, not even the implied 
%  warranty of merchantability or fitness for a particular purpose.  
%
%  Please email bug reports or suggestions for improvements to:
%
%      e.a.morelli@larc.nasa.gov
%

%
%  Initialization.
%
ims=c.ims;
imo=c.imo;
fdata=c.fdata;
npts=length(t);
n=length(x0);
dtr=pi/180;
g=32.174;
%
%  Compute the state vector time history using 
%  second-order Runge-Kutta or third-order Adams-Bashforth
%  numerical integration.
%
%  The runk2a.m code is a duplication of runk2.m, 
%  except that the acceleration outputs are saved 
%  at each time step.  The same applies to adamb3a.m 
%  and adamb3.m.  
%
%[x,accel] = runk2a('nldyn_eqs',p,[u,fdata],t,x0,c);
[x,accel] = adamb3a('nldyn_eqs',p,[u,fdata],t,x0,c);
%
%  Compute output vector time histories 
%  according to imo, and substitute measured 
%  state time histories as indicated by ims.  
%
%  State vector indices in fdata.
%
xindx=[2:10]';
%
%  Substitute measured values for states 
%  as indicated by ims.
%
msindx=find(ims==1);
nms=length(msindx);
if nms > 0
%
%  Convert all states to radians, except airspeed.
%
  for j=1:nms
    x(:,msindx(j))=fdata(:,xindx(msindx(j)));
    if msindx(j)~=1
      x(:,msindx(j))=x(:,msindx(j))*dtr;
    end
  end
end
%
%
%  Output equations.
%
y=zeros(npts,n+6);
%
%  Airspeed.
%
y(:,1)=x(:,1);
%
%  Sideslip angle.
%
y(:,2)=x(:,2);
%
%  Angle of attack.
%
y(:,3)=x(:,3);
%
%  Angular rates.  
%
y(:,[4:6])=x(:,[4:6]);
%
%  Euler angles.
%
y(:,[7:9])=x(:,[7:9]);
%
%  Translational accelerations.
%
y(:,[10:12])=accel(:,[1:3]);
%
%  Angular accelerations.
%
y(:,[13:15])=accel(:,[4:6]);
%
%  Include only the selected model outputs. 
%
y=y(:,find(imo==1));
return
