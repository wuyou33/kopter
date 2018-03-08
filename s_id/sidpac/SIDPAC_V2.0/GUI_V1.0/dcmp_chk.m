%
%  DCMP_CHK  Computes model outputs for data compatibility analysis.
%
%  Calling GUI: dcmp_gui.m
%
%  Usage: dcmp_chk;
%
%  Description:
%
%    Computes model outputs for data compatibility analysis.
%
%  Input:
%    
%    fdata = flight data matrix in standard configuration.
%        t = time vector.
%       cc = cell structure:
%            cc.p0c = vector of initial parameter values.
%            cc.ipc = index vector to select estimated parameters.
%            cc.ims = index vector to select measured states.
%            cc.imo = index vector to select model outputs.
%
%  Output:
%
%       yc = data compatibility model output vector time history.
%       pc = estimated instrumentation error parameter vector.
%     crbc = estimated parameter covariance matrix.
%      rrc = discrete noise covariance matrix estimate.  
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
%      22 Oct  2000 - Created and debugged, EAM.
%      28 Oct  2000 - Added general model structure capability, EAM.
%      17 Sept 2004 - Updated code, EAM.
%      29 Dec  2005 - Streamlined and updated code, EAM.
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
dtr=pi/180.;
g=32.174;
%
%  Get data from the MATLAB workspace.
%
t=evalin('base','t');
fdata=evalin('base','fdata');
%
%  Assemble the input and output data matrices.  
%
zc=[fdata(:,2),fdata(:,3)*dtr,fdata(:,4)*dtr,...
    fdata(:,8)*dtr,fdata(:,9)*dtr,fdata(:,10)*dtr];
ca=cos(fdata(:,4)*dtr);
cb=cos(fdata(:,3)*dtr);
sa=sin(fdata(:,4)*dtr);
sb=sin(fdata(:,3)*dtr);
uc=[fdata(:,11)*g,fdata(:,12)*g,fdata(:,13)*g,...
    fdata(:,5)*dtr,fdata(:,6)*dtr,fdata(:,7)*dtr,...
    fdata(:,2).*ca.*cb,fdata(:,2).*sb,fdata(:,2).*sa.*cb,...
    fdata(:,[8:10])*dtr];
%
%  Find smoothed initial states 
%  from the measurements.  
%
dt=1/round(1/(t(2)-t(1)));
xsc=xsmep(uc(:,[7:12]),2,dt);
x0c=xsc(1,:)';
%
%  Initialize the parameter vector and 
%  select the parameters to be estimated.  
%
if evalin('base','exist(''cc'',''var'')')
  cc=evalin('base','cc');
else
  runopt=get(handles.lonlat_popup,'Value');
  cc=dcmp_psel(fdata,runopt);
  assignin('base','runopt',runopt);
end
%
%  Assemble the initial estimated parameter vector
%  from the information in data structure cc.
%
p0c=cc.p0c;
ipc=cc.ipc;
pc=p0c(find(ipc==1));
%
%  Compute all data compatibility outputs,
%  but retain information about which 
%  model outputs should be used in the 
%  parameter estimation.  
%
imo=cc.imo;
cc.imo=ones(1,6);
yc=dcmp(pc,uc,t,x0c,cc);
cc.imo=imo;
%
%  Record results in the MATLAB workspace.
%
assignin('base','yc',yc);
assignin('base','pc',pc);
assignin('base','uc',uc);
assignin('base','x0c',x0c);
assignin('base','cc',cc);
assignin('base','zc',zc);
return
