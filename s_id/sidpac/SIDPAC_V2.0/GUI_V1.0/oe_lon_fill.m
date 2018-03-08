%
%  OE_LON_FILL  Fills in initial parameter values for longitudinal output-error.  
%
%  Calling GUI: oe_lon_setup_gui.m
%
%  Usage: oe_lon_fill;
%
%  Description:
%
%    Fills in initial parameter values for longitudinal
%    output-error parameter estimation.  
%
%  Input:
%    
%     coe = cell structure:
%           coe.p0     = p0     = vector of initial parameter values.
%           coe.ip     = ip     = index vector to select estimated parameters.
%           coe.ims    = ims    = index vector to select measured states.
%           coe.imo    = imo    = index vector to select model outputs.
%           coe.x0     = x0     = initial state vector.
%           coe.u0     = u0     = initial control vector.
%                                 coefficients to be modeled.
%           coe.fdata  = fdata  = standard array of measured flight data, 
%                                 geometry, and mass/inertia properties.  
%           coe.plab   = plab   = labels for the parameters.
%           coe.runopt = runopt = dynamic model flag:
%                                 = 1 for longitudinal dynamics
%                                 = 2 for lateral dynamics
%            coe.ndopt = ndopt  = non-dimensional parameters flag:
%                                 = 1 for non-dimensional parameters 
%                                 = 2 for dimensional parameters
%
%  Output:
%
%     Updated values in the longitudinal setup GUI for output-error.
%

%
%    Calls:
%      roundd.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      08 Aug  2006 - Created and debugged, EAM.
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
%  Longitudinal case. 
%
dopt=evalin('base','coe.dopt');
set(handles.dimension_popup,'Value',dopt);
p0=evalin('base','coe.p0');
ip=evalin('base','coe.ip');
ns=4;
nc=3;
no=6;
ndec=3;
%
%  A matrix.
%
for i=1:ns
  for j=1:ns
    eval(['set(handles.a',num2str(i),num2str(j),...
          '_edit,''Value'',p0(',num2str((i-1)*(ns+nc)+j),'));']);
    eval(['set(handles.a',num2str(i),num2str(j),...
          '_edit,''String'',num2str(roundd(p0(',num2str((i-1)*(ns+nc)+j),'),ndec)));']);
    eval(['set(handles.a',num2str(i),num2str(j),...
          '_switch,''Value'',ip(',num2str((i-1)*(ns+nc)+j),'));']);
  end
end
%
%  B matrix.
%
for i=1:ns
  for j=ns+1:ns+nc
    eval(['set(handles.b',num2str(i),num2str(j-ns),...
          '_edit,''Value'',p0(',num2str((i-1)*(ns+nc)+j),'));']);
    eval(['set(handles.b',num2str(i),num2str(j-ns),...
          '_edit,''String'',num2str(roundd(p0(',num2str((i-1)*(ns+nc)+j),'),ndec)));']);
    eval(['set(handles.b',num2str(i),num2str(j-ns),...
          '_switch,''Value'',ip(',num2str((i-1)*(ns+nc)+j),'));']);
  end
end
%
%  D matrix - bias terms only.
%
for i=1:no
  eval(['set(handles.d',num2str(i),num2str(nc),...
        '_edit,''Value'',p0(',num2str(ns*(ns+nc)+i),'));']);
  eval(['set(handles.d',num2str(i),num2str(nc),...
        '_edit,''String'',num2str(roundd(p0(',num2str(ns*(ns+nc)+i),'),ndec)));']);
  eval(['set(handles.d',num2str(i),num2str(nc),...
        '_switch,''Value'',ip(',num2str(ns*(ns+nc)+i),'));']);
end
imo=evalin('base','coe.imo');
set(handles.airspeed_output_switch,'Value',imo(1));
set(handles.alpha_output_switch,'Value',imo(2));
set(handles.q_output_switch,'Value',imo(3));
set(handles.the_output_switch,'Value',imo(4));
set(handles.ax_output_switch,'Value',imo(5));
set(handles.az_output_switch,'Value',imo(6));
return
