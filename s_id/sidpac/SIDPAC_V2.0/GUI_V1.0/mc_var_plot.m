%
%  MC_VAR_PLOT  Plots a specified column of the fdata matrix.
%
%  Calling GUI: mc_gui.m
%
%  Usage: mc_var_plot;
%
%  Description:
%
%    Plots variables in the standard fdata array 
%    according to user input.  
%
%  Input:
%    
%    None
%
%  Output:
%
%    2-D plot
%
%

%
%    Calls:
%      mc_plot.m
%      cmpsigs.m
%      sid_leglab.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%     28 Dec  2005 - Created and debugged, EAM.
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
%  Get the listbox value.
%
iy=get(handles.sidpac_var_listbox,'Value');
%
%  Plot the data specified in the listbox.
%
%  Correlate listbox value with fds field name, 
%  then assign the data, label, and units.
%  Hold and compare signals options are implemented here.  
%
if get(handles.hold_popup,'Value')==2
  handles.data.yp=[handles.data.yp,evalin('base',['fdata(:,',num2str(iy),')'])];
  handles.label.yp=evalin('base',['fds.varlab{',num2str(iy),'}']);
  handles.units.yp=evalin('base',['fds.varunits{',num2str(iy),'}']);
elseif get(handles.hold_popup,'Value')==3
  handles.data.yp=[handles.data.yp,evalin('base',['fdata(:,',num2str(iy),')'])];
  handles.label.yp=evalin('base',['fds.varlab{',num2str(iy),'}']);
  handles.units.yp=evalin('base',['fds.varunits{',num2str(iy),'}']);
  handles.data.yp=cmpsigs(handles.data.xp,handles.data.yp,0);
else
  handles.data.yp=evalin('base',['fdata(:,',num2str(iy),')']);
  handles.label.yp=evalin('base',['fds.varlab{',num2str(iy),'}']);
  handles.units.yp=evalin('base',['fds.varunits{',num2str(iy),'}']);
end
%
%  Get abscissa data for plotting.
%
handles.data.xp=evalin('base','t');
handles.label.xp=evalin('base','fds.varlab{1}');
handles.units.xp=evalin('base','fds.varunits{1}');
%
%  Assemble the legend labels, if necessary.
%
sid_leglab
%
%  Save data in the handles structure.
%
guidata(hObject, handles);
%
%  Plot the data.
%
mc_plot
return
