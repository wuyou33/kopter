%
%  DCMP_EST  Estimate instrumentation error parameters using output-error.  
%
%  Calling GUI: dcmp_gui.m
%
%  Usage: dcmp_est;
%
%  Description:
%
%    Estimates instrumentation error parameters using output-error,
%    and computes model outputs for data compatibility analysis.  
%
%  Input:
%    
%    fdata = matrix of measured flight data in standard configuration.
%        t = time vector.
%
%  Output:
%
%     yc = data compatibility model output vector time history.
%     pc = estimated instrumentation error parameter vector.
%   crbc = estimated parameter covariance matrix.
%    rrc = discrete noise matrix estimate.
%     zc = matrix of measured output vectors for data compatibility analysis.
%     uc = matrix of measured input vectors for data compatibility analysis.
%    x0c = state vector initial condition for data compatibility analysis.
%    p0c = initial values for the estimated instrumentation 
%          error parameter vector pc.  
%    ipc = index vector indicating which instrumentation 
%          error parameters are to be estimated.  
%    ims = index vector indicating which states 
%          will use measured values.
%    imo = index vector indicating which model outputs
%          will be calculated.  
%     cc = cell structure:
%          cc.p0c = vector of initial parameter values.
%          cc.ipc = index vector to select estimated parameters.
%          cc.ims = index vector to select measured states.
%          cc.imo = index vector to select model outputs.
%

%
%    Calls:
%      xsmep.m
%      oe.m
%      dcmp.m
%      correl.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      22 Oct  2000 - Created and debugged, EAM.
%      28 Oct  2000 - Added general model structure capability, EAM.
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
%  Initialization.
%
fprintf('\n\n Estimating instrumentation error parameters ...\n'),
%
%  Initialization.
%
dtr=pi/180.;
g=32.174;
%
%  Get data from the workspace.
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
%  Get run parameters from data structure cc.
%
cc=evalin('base','cc');
p0c=cc.p0c;
ipc=cc.ipc;
ims=cc.ims;
imo=cc.imo;
pclab=cc.pclab;
%
%  Start the output-error parameter estimation.
%
tic,
[yc,pc,crbc,rrc]=oe('dcmp',p0c(find(ipc==1)),uc,t,x0c,cc,zc(:,find(imo==1)));
toc,
corc=correl(crbc);
%
%  Compute all the model outputs, not just 
%  those used for the parameter estimation.
%
cc.imo=ones(1,6);
yc=dcmp(pc,uc,t,x0c,cc);
cc.imo=imo;
%
%  Print out the results.
%
fprintf('\n\n Estimated Instrumentation Error Parameters:\n'),
fprintf(' -------------------------------------------\n'),
pcindx=find(ipc==1);
np=length(pcindx);
for j=1:np,
  fprintf('\n   %s = %7.4f  +/- %7.4f \n',...
          pclab(pcindx(j),:),pc(j),sqrt(diag(crbc(j,j)))),
end
fprintf('\n\n Done\n\n');
%
%  Record results in the MATLAB workspace.
%
assignin('base','yc',yc);
assignin('base','pc',pc);
assignin('base','crbc',crbc);
assignin('base','rrc',rrc);
assignin('base','corc',corc);
assignin('base','uc',uc);
assignin('base','x0c',x0c);
assignin('base','cc',cc);
assignin('base','zc',zc);
return
