%
%  LR_SAVE  Saves results for linear regression modeling.
%
%  Calling GUI: lr_gui.m
%
%  Usage: lr_save;
%
%  Description:
%
%    Saves results for linear regression modeling
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
%       xm = matrix of column vector model terms.  
%     serr = vector of estimated parameter standard errors.  
%   xnames = names of the regressors.
%       p0 = prior parameter vector (optional).
%     crb0 = prior parameter covariance matrix (optional).
%
%  Output:
%
%     fds.lr creation or update
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      03 Aug  2006 - Created and debugged, EAM.
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
if mflg==1
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
  base=['fds.lr.',ostr];
  eval([base,'.Z=Z(:,',num2str(zcol),');']);
  eval([base,'.X=X;']);
  eval([base,'.y=y;']);
  eval([base,'.p=p;']);
  eval([base,'.crb=crb;']);
  eval([base,'.s2=s2;']);
  eval([base,'.xm=xm;']);
  eval([base,'.serr=sqrt(diag(crb));']);
  eval([base,'.xnames=xnames;']);
  if exist('p0','var') & exist('crb0','var')
    eval([base,'.p0=p0;']);
    eval([base,'.crb0=crb0;']);
  end
  fprintf('\n\nLinear Regression modeling results '),
  fprintf(['\nrecorded in ',base,' \n\n']),
end
return
