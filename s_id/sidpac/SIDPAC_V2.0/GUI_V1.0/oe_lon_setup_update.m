%
%  OE_LON_SETUP_UPDATE  Updates settings for longitudinal output-error.  
%
%  Calling GUI: oe_lon_setup_gui.m
%
%  Usage: oe_lon_setup_update;
%
%  Description:
%
%    Implements the run settings for longitudinal output-error,
%
%  Input:
%    
%    None
%
%  Output:
%
%      coe = cell structure:
%            coe.p0     = p0     = vector of initial parameter values.
%            coe.ip     = ip     = index vector to select estimated parameters.
%            coe.ims    = ims    = index vector to select measured states.
%            coe.imo    = imo    = index vector to select model outputs.
%            coe.x0     = x0     = initial state vector.
%            coe.u0     = u0     = initial control vector.
%                                  coefficients to be modeled.
%            coe.fdata  = fdata  = standard array of measured flight data, 
%                                  geometry, and mass/inertia properties.  
%            coe.plab   = plab   = labels for the parameters.
%            coe.runopt = runopt = dynamic model flag:
%                                  = 1 for longitudinal dynamics
%                                  = 2 for lateral dynamics
%            coe.dopt   = dopt   = dimensional parameters flag:
%                                  = 1 for non-dimensional parameters 
%                                  = 2 for dimensional parameters
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      06 Aug  2006 - Created and debugged, EAM.
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
ns=4;
nc=3;
no=6;
p0=zeros(ns*(ns+nc)+no,1);
np=length(p0);
ip=zeros(np,1);
%
%  Update the parameter estimate information.  
%
%  p0 = vector of parameter initial values.
%  ip elements = 1 to estimate the corresponding parameter.
%              = 0 to exclude the corresponding parameter from the estimation.
%
%  A matrix.
%
for i=1:ns
  for j=1:ns
    eval(['p0(',num2str((i-1)*(ns+nc)+j),')=get(handles.a',...
         num2str(i),num2str(j),'_edit,''Value'');']);
    eval(['ip(',num2str((i-1)*(ns+nc)+j),')=get(handles.a',...
          num2str(i),num2str(j),'_switch,''Value'');']);
  end
end
%
%  B matrix.
%
for i=1:ns
  for j=ns+1:ns+nc
    eval(['p0(',num2str((i-1)*(ns+nc)+j),')=get(handles.b',...
          num2str(i),num2str(j-ns),'_edit,''Value'');']);
    eval(['ip(',num2str((i-1)*(ns+nc)+j),')=get(handles.b',...
          num2str(i),num2str(j-ns),'_switch,''Value'');']);
  end
end
%
%  D matrix - bias terms only.
%
for i=1:no
  eval(['p0(',num2str(ns*(ns+nc)+i),')=get(handles.d',...
        num2str(i),num2str(nc),'_edit,''Value'');']);
  eval(['ip(',num2str(ns*(ns+nc)+i),')=get(handles.d',...
        num2str(i),num2str(nc),'_switch,''Value'');']);
end
%
%  imo = 1 to select the corresponding output
%          to be included in the model output.
%      = 0 to omit the corresponding output 
%          from the model output. 
%
%    y = [V,alpha,q,the,ax,az]
%
imo=zeros(1,6);
imo(1)=get(handles.airspeed_output_switch,'Value');
imo(2)=get(handles.alpha_output_switch,'Value');
imo(3)=get(handles.q_output_switch,'Value');
imo(4)=get(handles.the_output_switch,'Value');
imo(5)=get(handles.ax_output_switch,'Value');
imo(6)=get(handles.az_output_switch,'Value');
%
%
%    coe = cell structure:
%          coe.p0  = vector of initial parameter values.
%          coe.ip  = index vector to select estimated parameters.
%          coe.imo = index vector to select model outputs.
%
coe=evalin('base','coe');
coe.p0=p0;
coe.ip=ip;
coe.imo=imo;
%
%  Update coe in the workspace.
%
assignin('base','coe',coe);
return
