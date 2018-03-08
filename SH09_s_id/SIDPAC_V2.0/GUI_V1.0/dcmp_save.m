%
%  DCMP_SAVE  Saves results for data compatibility analysis.
%
%  Calling GUI: dcmp_gui.m
%
%  Usage: dcmp_save;
%
%  Description:
%
%    Saves results for data compatibility analysis
%    in the fds data structure.
%
%  Input:
%    
%     zc = data compatibility measured output vector time history.
%      t = time vector.
%     yc = data compatibility model output vector time history.
%     pc = estimated instrumentation error parameter vector.
%   crbc = estimated parameter covariance matrix.
%    rrc = discrete noise covariance matrix estimate.  
%     uc = matrix of column vector inputs for data compatibility 
%          = [ax,ay,az,p,q,r,u,v,w,phi,the,psi].
%    x0c = initial state vector for data compatibility.
%     cc = cell structure:
%          cc.p0c = vector of initial parameter values.
%          cc.ipc = index vector to select estimated parameters.
%          cc.ims = index vector to select measured states.
%          cc.imo = index vector to select model outputs.
%
%  Output:
%
%     fds.dca creation or update
%

%
%    Calls:
%      xsmep.m
%      dcmp_psel.m
%      dcmp.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      03 Apr  2006 - Created and debugged, EAM.
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
%  Save the data compatibility results 
%  in the workspace, if they exist.  
%
if evalin('base','exist(''crbc'',''var'')')
  evalin('base','fds.dca.zc=zc;');
  evalin('base','fds.dca.t=t;');
  evalin('base','fds.dca.yc=yc;');
  evalin('base','fds.dca.pc=pc;');
  evalin('base','fds.dca.crbc=crbc;');
  evalin('base','fds.dca.rrc=rrc;');
  evalin('base','fds.dca.uc=uc;');
  evalin('base','fds.dca.x0c=x0c;');
  evalin('base','fds.dca.cc=cc;');
  evalin('base','fds.dca.saved=datestr(now);')
  fprintf('\n Data compatibility analysis results saved in fds.dca \n\n\n')
end
return
