%
%  OE_EST  Estimate model parameters using output-error.  
%
%  Calling GUI: oe_gui.m
%
%  Usage: oe_est;
%
%  Description:
%
%    Estimates model parameters using output-error, 
%    and computes model outputs.  
%
%  Input:
%    
%    fdata = matrix of measured flight data in standard configuration.
%        t = time vector.
%      coe = cell structure:
%            coe.p0     = p0     = vector of initial parameter values.
%            coe.ip     = ip     = index vector to select estimated parameters.
%            coe.ims    = ims    = index vector to select measured states.
%            coe.imo    = imo    = index vector to select model outputs.
%            coe.x0     = x0     = initial state vector.
%            coe.u0     = u0     = initial control vector.
%                                  coefficients to be modeled.
%            coe.fdata  = fdata  = standard array of measured flight data, 
%                                  geometry, and mass/inertia properties.  
%            coe.plab   = plab   = labels for the parameters.
%            coe.runopt = runopt = dynamic model flag:
%                                  = 1 for longitudinal dynamics
%                                  = 2 for lateral dynamics
%            coe.dopt   = dopt   = dimensional parameters flag:
%                                  = 1 for non-dimensional parameters 
%                                  = 2 for dimensional parameters
%
%  Output:
%
%        y = model output vector or matrix.
%        x = model state vector or matrix.
%  A,B,C,D = system matrices.
%        p = vector of parameter estimates.
%      crb = estimated parameter covariance matrix.
%       rr = discrete measurement noise covariance matrix estimate. 
%   dsname = name of the file that computes the model outputs.
%       p0 = vector of initial parameter values.
%        u = input vector or matrix.
%       x0 = state vector initial condition.
%        z = measured output vector or matrix.
%

%
%    Calls:
%      oe_psel.m
%      xsmep.m
%      oe.m
%      oe_tnlonss.m
%      oe_tlonss.m
%      oe_tnlatss.m
%      oe_tlatss.m
%      model_disp.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      06 Aug  2006 - Created and debugged, EAM.
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
fprintf('\n\n Estimating model parameters ...\n'),
%
%  Initialization.
%
dtr=pi/180.;
g=32.174;
npts=length(t);
dt=1/round(1/(t(2)-t(1)));
%
%  Dynamic case - longitudinal or lateral.  
%
if exist('coe','var')
  runopt=coe.runopt;
else
  runopt=get(guiH.lonlat_popup,'Value');
  coe=oe_psel(fdata,runopt);
end
%
%  runopt = dynamics flag
%           = 1 for longitudinal
%           = 2 for lateral
%
if runopt==1
%
%  dopt = dimensional parameters flag
%         = 1 for non-dimensional parameters
%         = 2 for dimensional parameters
%
  if dopt==1
    dsname='oe_tnlonss';
  else
    dsname='oe_tlonss';
  end
%
%  Assemble the input and output data matrices.  
%
  z=[fdata(:,2),fdata(:,[4,6,9])*dtr,fdata(:,[11,13])];
  u=[fdata(:,[14,17])*dtr,ones(npts,1)];
%
%  Find smoothed initial states 
%  from the measurements.  
%
  xs=xsmep(z(:,[1:4]),1,dt);
  x0=xs(1,:)';
else
%
%  dopt = dimensional parameters flag
%         = 1 for non-dimensional parameters
%         = 2 for dimensional parameters
%
  if dopt==1
    dsname='oe_tnlatss';
  else
    dsname='oe_tlatss';
  end
%
%  Assemble the input and output data matrices.  
%
  z=[fdata(:,[3,5,7,8])*dtr,fdata(:,12)];
  u=[fdata(:,[15,16])*dtr,ones(npts,1)];
%
%  Find smoothed initial states 
%  from the measurements.  
%
  xs=xsmep(z(:,[1:4]),1,dt);
  x0=xs(1,:)';
end
%
%  Assemble the initial estimated parameter vector
%  from the information in data structure coe.
%
pindx=find(coe.ip==1);
np=length(pindx);
if np > 0
  p0=coe.p0(pindx);
  plab=coe.plab;
%
%  Start the output-error parameter estimation.
%
  tic,
  oindx=find(coe.imo==1);
  [y,p,crb,rr]=oe(dsname,p0,u,t,x0,coe,z(:,oindx));
  serr=sqrt(diag(crb));
  toc,
%
%  Use constant measured initial conditions for the 
%  model outputs that are not computed.  
%
  [y,x,A,B,C,D]=eval([dsname,'(p,u,t,x0,coe);']);
  if runopt==1
    yt=ones(npts,1)*[x0',z(1,[5:6])];
  else
    yt=ones(npts,1)*[x0',z(1,5)];
  end
  yt(:,oindx)=y;
  y=yt;
  clear yt;
%
%  Print out the results.
%
  fprintf('\n\n Output-Error Parameter Estimates:\n'),
  fprintf(' ----------------------------------'),
  model_disp(p,serr,[],[],plab(pindx,:));
  mflg=3;
  fprintf('\n Done\n\n');
end
return
