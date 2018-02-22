function coe = nldyn_psel(fdata,runopt,p0oe,ipoe,ims,imo,imc,x0,u0,poelab)
%
%  NLDYN_PSEL  Implements settings in nldyn.m for output-error parameter estimation.  
%
%  Usage: coe = nldyn_psel(fdata,runopt,p0oe,ipoe,ims,imo,imc,x0,u0,poelab);
%
%  Description:
%
%    Initializes and selects the states, outputs,
%    and dynamic model parameters to be estimated  
%    for output-error parameter estimation using nldyn.m. 
%
%  Input:
%    
%   fdata = flight data array in standard configuration.
%  runopt = dynamic model flag (optional):
%           = 1 for longitudinal dynamics (default)
%           = 2 for lateral dynamics
%           = 3 for combined longitudinal and lateral dynamics
%    p0oe = initial values for the estimated 
%           parameter vector poe (optional).  
%    ipoe = index vector indicating which parameters 
%           are to be estimated (optional).  
%     ims = index vector indicating which states 
%           will use measured values (optional).
%     imo = index vector indicating which model outputs
%           will be calculated (optional).
%     imc = index vector indicating which non-dimensional 
%           coefficients will be modeled (optional).
%      x0 = initial state vector.
%      u0 = initial control vector.
%  poelab = labels for the model parameters.
%
%  Output:
%
%     coe = cell structure:
%           coe.p0oe   = p0oe   = vector of initial parameter values.
%           coe.ipoe   = ipoe   = index vector to select estimated parameters.
%           coe.ims    = ims    = index vector to select measured states.
%           coe.imo    = imo    = index vector to select model outputs.
%           coe.imc    = imc    = index vector to select non-dimensional 
%                                 coefficients to be modeled.
%           coe.x0     = x0     = initial state vector.
%           coe.u0     = u0     = initial control vector.
%                                 coefficients to be modeled.
%           coe.fdata  = fdata  = standard array of measured flight data, 
%                                 geometry, and mass/inertia properties.  
%           coe.poelab = poelab = labels for the parameters.
%           coe.ti     = ti     = time index.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      07 Oct  2001 - Created and debugged, EAM.
%      04 Nov  2001 - Removed checks for prior variable definitions, EAM.
%      23 July 2002 - Added acceleration outputs, EAM.
%      18 Aug  2004 - Updated notation and added imc, EAM.
%      14 Feb  2006 - Converted the script to a function, 
%                     added lat, lon, and combined options, EAM.
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
%  Default values are longitudinal.
%
if nargin < 2
  runopt=1;
end
%
%  Initial values for the parameters.
%
%    p0oe(1:10)  =  CX parameters
%    p0oe(11:20) =  CY parameters
%    p0oe(21:30) =  CZ parameters
%    p0oe(31:40) =  C1 parameters
%    p0oe(41:50) =  Cm parameters
%    p0oe(51:60) =  Cn parameters
%    p0oe(61:70) =  bias parameters
%
if nargin < 3
%        1  2  3  4  5  6  7  8  9  10
  p0oe=[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...  % CX
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...  % CY
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...  % CZ
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...  % Cl
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...  % Cm
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...  % Cn
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0]';   % bias
end
%
%  The number of parameters is np.
%
np=length(p0oe);
%
%
%  ipoe element = 1 to estimate the corresponding parameter.
%               = 0 to exclude the corresponding parameter from the estimation.
%
%  runopt = 1 for longitudinal dynamics
%         = 2 for lateral dynamics
%         = 3 for combined longitudinal and lateral dynamics
%
if nargin < 4
  if runopt==1
%          1  2  3  4  5  6  7  8  9  10
    ipoe=[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...  % CX
           0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...  % CY
           0, 1, 0, 1, 0, 0, 0, 0, 1, 0,...  % CZ
           0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...  % Cl
           0, 1, 1, 1, 0, 0, 0, 0, 1, 0,...  % Cm
           0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...  % Cn
           0, 0, 0, 0, 0, 1, 0, 0, 0, 0]';   % bias
  elseif runopt==2
%          1  2  3  4  5  6  7  8  9  10
    ipoe=[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...  % CX
           1, 0, 0, 0, 1, 0, 0, 0, 1, 0,...  % CY
           0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...  % CZ
           1, 1, 1, 1, 1, 0, 0, 0, 1, 0,...  % Cl
           0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...  % Cm
           1, 1, 1, 1, 1, 0, 0, 0, 1, 0,...  % Cn
           0, 0, 0, 0, 1, 0, 0, 0, 0, 0]';   % bias
  else
%          1  2  3  4  5  6  7  8  9  10
    ipoe=[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...  % CX
           1, 0, 0, 0, 1, 0, 0, 0, 1, 0,...  % CY
           0, 1, 0, 1, 0, 0, 0, 0, 1, 0,...  % CZ
           1, 1, 1, 1, 1, 0, 0, 0, 1, 0,...  % Cl
           0, 1, 1, 1, 0, 0, 0, 0, 1, 0,...  % Cm
           1, 1, 1, 1, 1, 0, 0, 0, 1, 0,...  % Cn
           0, 0, 0, 0, 1, 1, 0, 0, 0, 0]';   % bias
  end
end
%
%  Labels for the model parameters.
%
if nargin < 10
  poelab=[ 'CX1 ';'CX2 ';'CX3 ';'CX4 ';'CX5 ';'CX6 ';'CX7 ';'CX8 ';'CX9 ';'CX10';...
           'CY1 ';'CY2 ';'CY3 ';'CY4 ';'CY5 ';'CY6 ';'CY7 ';'CY8 ';'CY9 ';'CY10';...
           'CZ1 ';'CZ2 ';'CZ3 ';'CZ4 ';'CZ5 ';'CZ6 ';'CZ7 ';'CZ8 ';'CZ9 ';'CZ10';...
           'C11 ';'C12 ';'C13 ';'C14 ';'C15 ';'C16 ';'C17 ';'C18 ';'C19 ';'C110';...
           'Cm1 ';'Cm2 ';'Cm3 ';'Cm4 ';'Cm5 ';'Cm6 ';'Cm7 ';'Cm8 ';'Cm9 ';'Cm10';...
           'Cn1 ';'Cn2 ';'Cn3 ';'Cn4 ';'Cn5 ';'Cn6 ';'Cn7 ';'Cn8 ';'Cn9 ';'Cn10';...
           'phib';'theb';'psib';'axb ';'ayb ';'azb ';'pdb ';'qdb ';'rdb ';'    '];
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
%      x = [   vt, beta, alfa,    p,    q,    r,  phi,  the,  psi]
    ims=[       1,    1,    0,    1,    0,    1,    1,    1,    1];
  elseif runopt==2
    ims=[       1,    0,    1,    0,    1,    0,    1,    1,    1];
  else
    ims=[       1,    0,    0,    0,    0,    0,    1,    1,    1];
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
%    y = [   vt, beta, alfa,    p,    q,    r,  phi,  the,  psi,   ax,   ay,   az, pdot, qdot, rdot]
    imo=[     0,    0,    1,    0,    1,    0,    0,    0,    0,    0,    0,    1,    0,    0,    0];
  elseif runopt==2
    imo=[     0,    1,    0,    1,    0,    1,    0,    0,    0,    0,    1,    0,    0,    0,    0];
  else
    imo=[     0,    1,    1,    1,    1,    1,    0,    0,    0,    0,    1,    1,    0,    0,    0];
  end
end
%
%   imc = 1 to use model equations for the
%           corresponding non-dimensional 
%           aerodynamic coefficient.
%       = 0 to use measured values for the
%           corresponding non-dimensional 
%           aerodynamic coefficient.
%
if nargin < 7
  if runopt==1
%      [ CX or CD,   CY,   CZ or CL,   C1,   Cm,   Cn]
    imc=[       0,    0,          1,    0,    1,    0];
  elseif runopt==2
    imc=[       0,    1,          0,    1,    0,    1];
  else
    imc=[       0,    1,          1,    1,    1,    1];
  end
end
%
%   x0 = initial state vector.  
%
%    x = [vt,beta,alfa,p,q,r,phi,the,psi]'
%
if nargin < 8
  x0=[fdata(1,2),fdata(1,[3:10])*pi/180]';
end
%
%   u0 = initial control vector.  
%
%    u = [el,ail,rdr]'
%
if nargin < 9
  u0=[fdata(1,[14:16])*pi/180]';
end
%
%     coe = cell structure:
%           coe.p0oe   = p0oe   = vector of initial parameter values.
%           coe.ipoe   = ipoe   = index vector to select estimated parameters.
%           coe.ims    = ims    = index vector to select measured states.
%           coe.imo    = imo    = index vector to select model outputs.
%           coe.imc    = imc    = index vector to select non-dimensional 
%                                 coefficients to be modeled.
%           coe.x0     = x0     = initial state vector.
%           coe.u0     = u0     = initial control vector.
%                                 coefficients to be modeled.
%           coe.fdata  = fdata  = standard array of measured flight data, 
%                                 geometry, and mass/inertia properties.  
%           coe.poelab = poelab = labels for the parameters.
%           coe.ti     = ti     = time index.
%
coe.p0oe=p0oe;
coe.ipoe=ipoe;
coe.ims=ims;
coe.imo=imo;
coe.imc=imc;
coe.x0=x0;
coe.u0=u0;
coe.fdata=fdata;
coe.poelab=poelab;
coe.ti=1;
return
