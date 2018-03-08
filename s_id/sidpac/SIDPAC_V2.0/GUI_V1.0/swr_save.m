%
%  SWR_SAVE  Saves results for stepwise regression modeling.
%
%  Calling GUI: swr_gui.m
%
%  Usage: swr_save;
%
%  Description:
%
%    Saves results for stepwise regression modeling
%    in the fds data structure.
%
%  Input:
%    
%        Z = measured output vector.
%        X = matrix of column regressors.
%        y = model output vector.
%        p = vector of parameter estimates.
%      crb = estimated parameter covariance matrix.
%       s2 = model fit error variance estimate.
%       xm = matrix of column regressors retained in the model.
%    pindx = vector of parameter vector indices for 
%            retained regressors, indicating the columns
%            of [x,ones(npts,1)] retained in the model.  
%     serr = vector of estimated parameter standard errors.  
%   xnames = names of the regressors.
%
%  Output:
%
%     fds.swr creation or update
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      05 Aug  2006 - Created and debugged, EAM.
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
%  Only implement the save if the modeling
%  method flag is non-zero, which means that
%  the modeling method in the GUI
%  has been selected and implemented.  
%
if mflg==2
%
%  Get the string for the modeled output.
%
  ovars=get(guiH.output_popup,'String');
  zcol=get(guiH.output_popup,'Value');
  ostr=ovars{zcol};
%
%  Strip off all the blanks.
%
  ostr=ostr(find(ostr~=' '));
%
%  Save results in fds.
%
  base=['fds.swr.',ostr];
  eval([base,'.Z=Z(:,',num2str(zcol),');']);
  eval([base,'.X=X;']);
  eval([base,'.y=y;']);
  eval([base,'.p=p;']);
  eval([base,'.crb=crb;']);
  eval([base,'.s2=s2;']);
  eval([base,'.xm=xm;']);
  eval([base,'.pindx=pindx;']);
  eval([base,'.serr=sqrt(diag(crb));']);
  eval([base,'.xnames=xnames;']);
  fprintf('\n\nStepwise Regression modeling results '),
  fprintf(['\nrecorded in ',base,' \n\n']),
end
return
