%
%  OE_SAVE  Saves results for stepwise regression modeling.
%
%  Calling GUI: oe_gui.m
%
%  Usage: oe_save;
%
%  Description:
%
%    Saves results for output-error modeling
%    in the fds data structure.
%
%  Input:
%    
%        z = measured output vector or matrix.
%        y = model output vector or matrix.
%        p = vector of parameter estimates.
%      crb = estimated parameter covariance matrix.
%       rr = discrete measurement noise covariance matrix estimate. 
%     serr = vector of estimated parameter standard errors.  
%   dsname = name of the file that computes the model outputs.
%       p0 = initial vector of parameter values.
%        u = input vector or matrix.
%       x0 = state vector initial condition.
%        c = constants passed to dsname.
%     crb0 = parameter covariance matrix for p0 (optional).
%
%  Output:
%
%     fds.oe creation or update
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
if mflg==3
%
%  Get the string for the model dynamics.
%
  runopt=get(guiH.lonlat_popup,'Value');
  if runopt==1
    dynstr='lon';
  else
    dynstr='lat';
  end
%
%  Save results in fds.  
%
  base=['fds.oe.',dynstr];
  eval([base,'.z=z(:,oindx);']);
  eval([base,'.y=y(:,oindx);']);
  eval([base,'.p=p;']);
  eval([base,'.crb=crb;']);
  eval([base,'.rr=rr;']);
  eval([base,'.serr=sqrt(diag(crb));']);
  eval([base,'.dsname=dsname;']);
  eval([base,'.p0=p0;']);
  eval([base,'.u=u;']);
  eval([base,'.x0=x0;']);
  eval([base,'.coe=coe;']);
  if exist('crbo','var')
    eval([base,'.crbo=crbo;']);
  end
  if exist('crb0','var')
    eval([base,'.crb0=crb0;']);
  end
  eval([base,'.plab=cellstr(plab(find(coe.ip==1),:));']);
  fprintf('\n\nOutput-Error modeling results '),
  fprintf(['\nrecorded in ',base,' \n\n']),
end
return
