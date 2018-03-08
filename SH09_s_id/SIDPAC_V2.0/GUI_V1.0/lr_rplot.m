%
%  LR_RPLOT  Draws a plot of regressor data.
%
%  Calling GUI: lr_gui.m
%
%  Usage: lr_rplot;
%
%  Description:
%
%    Draws a labeled plot of regressor data.
%
%
%  Input:
%
%    X = matrix of column vector regressors.
%
%
%  Output:
%
%    2-D plot
%
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      04 Aug  2006 - Created and debugged, EAM.
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
xcol=get(handles.regressor_listbox,'Value');
Xlist=get(handles.regressor_listbox,'String');
%
%  The listbox string is 'Listbox' 
%  when there are no regressors.
%
if ~strcmp(char(Xlist),'Listbox')
%
%  Turn off the output plot listbox and associated text.
%
  set(handles.output_plot_text,'Visible','off');
  set(handles.output_plot_popup,'Visible','off');
%
%  Correlate listbox value with the data, label, and units.
%
  yplab=char(Xlist{xcol});
  handles.label.yp=yplab;
  handles.units.yp='';
  yp=evalin('base',['X(:,',num2str(xcol),')']);
  handles.data.yp=yp;
%
%  Plot the data.
%
  sid_plot
%
%  Save the plot data.
%
  guidata(hObject, handles);
end
return
