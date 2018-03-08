function cc = dcmp_psel(fdata,runopt,p0c,ipc,ims,imo,x0c,pclab)
%
%  DCMP_PSEL  Implements settings in dcmp.m for data compatibility analysis.  
%
%  Usage: cc = dcmp_psel(fdata,runopt,p0c,ipc,ims,imo,x0c,pclab);
%
%  Description:
%
%    Initializes and selects the states, outputs, 
%    and instrumentation error parameters to be estimated 
%    for data compatibility analysis using dcmp.m.  
%
%  Input:
%    
%   fdata = flight data array in standard configuration.
%  runopt = kinematics flag (optional):
%           = 1 for longitudinal kinematics (default)
%           = 2 for lateral kinematics
%           = 3 for combined longitudinal and lateral kinematics
%     p0c = initial values for the estimated instrumentation 
%           error parameter vector pc (optional).  
%     ipc = index vector indicating which parameters 
%           are to be estimated (optional).  
%     ims = index vector indicating which states 
%           will use measured values (optional).
%     imo = index vector indicating which model outputs
%           will be calculated (optional).
%     x0c = initial state vector.
%   pclab = labels for the model parameters.
%
%  Output:
%
%     cc = cell structure:
%          cc.p0c    = p0c    = vector of initial parameter values.
%          cc.ipc    = ipc    = index vector to select estimated parameters.
%          cc.ims    = ims    = index vector to select measured states.
%          cc.imo    = imo    = index vector to select model outputs.
%          cc.x0c    = x0c    = initial state vector.
%          cc.fdata  = fdata  = standard array of measured flight data, 
%                               geometry, and mass/inertia properties.  
%          cc.pclab  = pclab  = labels for the parameters.
%

%
%    Calls:
%      xsmep.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      28 Oct  2000 - Created and debugged, EAM.
%      30 Dec  2005 - Converted the script to a function,
%                     added lat, lon, and combined options, EAM.
%      21 Mar  2006 - Updated for consistency with nldyn_psel.m, EAM. 
%      03 Apr  2006 - Added output biases, EAM.
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
%  Default values.
%
if nargin < 2
  runopt=1;
end
%
%  Initial values for the parameters.
%
%  p0c = [ax_bias,  ay_bias,   az_bias,  
%         p_bias,   q_bias,    r_bias, 
%         V_scf,    beta_scf,  alpha_scf, 
%         V_bias,   beta_bias, alpha_bias, 
%         phi_scf,  the_scf,   psi_scf,
%         phi_bias, the_bias,  psi_bias]
%
if nargin < 3
  p0c=[0,  0,  0,...
       0,  0,  0,...
       0,  0,  0,...
       0,  0,  0,...
       0,  0,  0,...
       0,  0,  0];
end
%
%  The number of parameters is np.
%
np=length(p0c);
%
%
%  ipc element = 1 to estimate the corresponding parameter.
%              = 0 to exclude the corresponding parameter from the estimation.
%
%  runopt = 1 for longitudinal kinematics
%         = 2 for lateral kinematics
%         = 3 for combined longitudinal and lateral kinematics
%
if nargin < 4
  if runopt==1
    ipc=[1,  0,  1,...
         0,  1,  0,...
         0,  0,  1,...
         0,  0,  0,...
         0,  1,  0,...
         0,  0,  0];
  elseif runopt==2
    ipc=[0,  1,  0,...
         1,  0,  1,...
         0,  1,  0,...
         0,  0,  0,...
         1,  0,  1,...
         0,  0,  0];
  else
    ipc=ones(1,np);
  end
end
%
%  Labels for the instrumentation error parameters.
%
if nargin < 8
  pclab=[' ax bias  (fps2)  ';...
         ' ay bias  (fps2)  ';...
         ' az bias  (fps2)  ';...
         '  p bias  (rps)   ';...
         '  q bias  (rps)   ';...
         '  r bias  (rps)   ';...
         '  V scf           ';...
         '  beta scf        ';...
         '  alpha scf       ';...
         '  V  bias (fps)   ';...
         '  beta bias (rad) ';...
         '  alpha bias (rad)';...
         '  phi scf         ';...
         '  the scf         ';...
         '  psi scf         ';...
         '  phi bias (rad)  ';...
         '  the bias (rad)  ';...
         '  psi bias (rad)  '];
end
%
%
%  ims = 1 to use measured values 
%          for the corresponding state.
%      = 0 to use computed model values 
%          for the corresponding state.  
%
if nargin < 5
  if runopt==1
%    x = [ u,  v,  w, phi, the, psi]
    ims=[  0,  1,  0,   1,   0,   1];
  elseif runopt==2
    ims=[  1,  0,  1,   0,   1,   0];
  else
    ims=[  0,  0,  0,   0,   0,   0];
  end
end
%
%
%  imo = 1 to select the corresponding output
%          to be included in the model output.
%      = 0 to omit the corresponding output 
%          from the model output. 
%
if nargin < 6
  if runopt==1
%    y = [ vt, beta, alpha, phi, the, psi]
    imo=[   1,    0,     1,   0,   1,   0];
  elseif runopt==2
    imo=[   0,    1,     0,   1,   0,   1];
  else
    imo=[   1,    1,     1,   1,   1,   1];
  end
end
%
%
%   x0c = initial state vector.  
%
%    x = [ u,  v,  w, phi, the, psi]
%
if nargin < 7
  dtr=pi/180;
  if norm(fdata(:,74))==0
    ca=cos(fdata(:,4)*dtr);
    cb=cos(fdata(:,3)*dtr);
    sa=sin(fdata(:,4)*dtr);
    sb=sin(fdata(:,3)*dtr);
    fdata(:,74)=fdata(:,2).*ca.*cb;
    fdata(:,75)=fdata(:,2).*sb;
    fdata(:,76)=fdata(:,2).*sa.*cb;
  end
  dt=1/round(1/(fdata(2,1)-fdata(1,1)));
  xs=xsmep([fdata(:,[74:76]),fdata(:,[8:10])*dtr],2,dt);
  x0c=xs(1,:)';
end
%
%     cc = cell structure:
%          cc.p0c    = p0c    = vector of initial parameter values.
%          cc.ipc    = ipc    = index vector to select estimated parameters.
%          cc.ims    = ims    = index vector to select measured states.
%          cc.imo    = imo    = index vector to select model outputs.
%          cc.x0c    = x0c    = initial state vector.
%          cc.fdata  = fdata  = standard array of measured flight data, 
%                               geometry, and mass/inertia properties.  
%          cc.pclab  = pclab  = labels for the parameters.
%
cc.p0c=p0c;
cc.ipc=ipc;
cc.ims=ims;
cc.imo=imo;
cc.x0c=x0c;
cc.fdata=fdata;
cc.pclab=pclab;
return
