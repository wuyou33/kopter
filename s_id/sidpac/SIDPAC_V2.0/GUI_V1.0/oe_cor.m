%
%  OE_COR  Corrects output-error standard errors for colored residuals.
%
%  Calling GUI: oe_gui.m
%
%  Usage: oe_cor;
%
%  Description:
%
%    Corrects output-error standard errors for colored residuals. 
%
%  Input:
%    
%    fdata = flight data matrix in standard configuration.
%        t = time vector.
%   dsname = name of the file that computes the model outputs.
%        p = vector of parameter estimates.
%        u = input vector or matrix.
%       x0 = state vector initial condition.
%      coe = cell structure:
%            coe.p0  = vector of initial parameter values.
%            coe.ip  = index vector to select estimated parameters.
%            coe.imo = index vector to select model outputs.
%        z = measured output vector or matrix.
%
%  Output:
%
%      crb = estimated parameter covariance matrix, 
%            corrected for colored residuals.
%     crbo = estimated parameter covariance matrix, 
%            conventional calculation.
%

%
%    Calls:
%      m_colores.m
%      oe_tlonss.m
%      oe_tlatss.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      07 Aug  2006 - Created and debugged, EAM.
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
%  Check to be sure that output-error
%  parameter estimation has been done.  
%
if mflg==3
%
%  Dynamic case - longitudinal or lateral.  
%
  runopt=coe.runopt;
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
  end
%
%  Standard error corrections for colored residuals.
%
  tic,
  fprintf('\n\n Working ... \n\n'),
  [crb,crbo] = m_colores(dsname,p,u,t,x0,coe,z(:,oindx));
  serro=sqrt(diag(crbo));
  serr=sqrt(diag(crb));
  toc,
%
%  Print out the results.
%
  fprintf('\n\n Output-Error Parameter Estimates:\n'),
  fprintf(' ----------------------------------'),
  model_disp(p,serr,[],[],plab(pindx,:));
  fprintf('\n Done\n\n');
end
return
