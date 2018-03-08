%
%  LR_OPLOT  Draws a plot of output data.
%
%  Calling GUI: lr_gui.m
%
%  Usage: lr_oplot;
%
%  Description:
%
%    Draws a labeled plot of output data.
%
%
%  Input:
%
%    Z = matrix of column vector outputs.
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
zcol=get(handles.output_popup,'Value');
Zlist=get(handles.output_popup,'String');
%
%  The popup string is 'Listbox' 
%  when there are no outputs.
%
if ~strcmp(char(Zlist),'Popup')
%
%  Correlate listbox value with the data, label, and units.
%
  yplab=char(Zlist{zcol});
  handles.label.yp=yplab;
  handles.units.yp='';
  yp=evalin('base',['Z(:,',num2str(zcol),')']);
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
