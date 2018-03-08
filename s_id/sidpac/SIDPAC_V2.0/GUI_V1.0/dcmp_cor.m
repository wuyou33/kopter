%
%  DCMP_COR  Corrects data for estimated instrumentation errors.  
%
%  Calling GUI: dcmp_gui.m
%
%  Usage: dcmp_cor;
%
%  Description:
%
%    Implements systematic instrumentation error 
%    corrections using the results from data 
%    compatibility analysis.  
%
%  Input:
%
%      pc = vector of estimated instrumentation error parameter values.
%      uc = matrix of column vector inputs = [ax,ay,az,p,q,r].
%     x0c = state vector initial condition for data compatibility analysis.
%      cc = cell structure:
%            cc.p0c = vector of initial parameter values.
%            cc.ipc = index vector to select estimated parameters.
%            cc.ims = index vector to select measured states.
%            cc.imo = index vector to select model outputs.
%      zc = matrix of column vector measured outputs = [vt,beta,alpha,phi,the,psi].
%   fdata = flight test data array in standard configuration.
%
%  Output:
%
%  fdatao = original matrix of measured flight data in standard configuration,
%           without instrumentation error corrections applied.
%   fdata = matrix of measured flight data in standard configuration,
%           with instrumentation error corrections applied.
%    zcor = corrected matrix of column vector outputs = [vt,beta,alpha,phi,the,psi].
%    ucor = corrected matrix of column vector inputs = [ax,ay,az,p,q,r].
%

%
%    Calls:
%      sens_cor.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      03 Feb  2001 - Created and debugged, EAM.
%      30 Dec  2005 - Streamlined and updated code, EAM.
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
%  Only implement the corrections if the 
%  instrumentation error parameters have been
%  defined or estimated.  
%
if exist('pc','var')
  fdatao = fdata;
  [zcor,ucor,fdata] = sens_cor(pc,uc,zc,x0c,cc,fdatao);
  fprintf('\n\n Corrections complete \n\n')
  fprintf('\n Original data in fdatao \n')
  fprintf('\n Corrected data in fdata \n\n')
end
return
