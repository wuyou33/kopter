%
%  SID_WS_VAR_PLOT  Plots a specifed workspace variable. 
%
%  Calling GUI: sid_gui.m
%
%  Usage: sid_ws_var_plot;
%
%  Description:
%
%    Plots workspace variables 
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
%      sid_plot.m
%      cmpsigs.m
%      sid_leglab.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      9 Jan  2004 - Created and debugged, EAM.
%     28 Dec  2005 - Streamlined and updated the code, EAM.
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
%  Clear all text and the array popup.
%
set(handles.scalar_text,'Visible','off');
set(handles.array_text,'Visible','off');
set(handles.array_popup,'Visible','off');
set(handles.vector_text,'Visible','off');
set(handles.vector_popup,'Visible','off');
set(handles.struct_text,'Visible','off');
%
%  Get the listbox value.
%
iy=get(handles.ws_var_listbox,'Value');
%
%  Correlate listbox value with workspace variable name.
%
vars=get(handles.ws_var_listbox,'String');
yplab=vars{iy};
ypunits='   ';
%
%  Get the variables for plotting.
%  Variables xpw and ypw are from the workspace.
%
ypw=evalin('base',yplab);
handles.label.yp=yplab;
handles.units.yp=ypunits;
% 
% if evalin('base','exist(''f'',''var'')') & length(yp)==length(f) & ~isreal(yp)
% handles.data.xp=evalin('base','f');
% handles.label.xp='  frequency ';
% handles.units.xp=' (Hz) ';
% handles.data.yp=cvec(yp);
%
xpw=evalin('base','t');
xp=cvec(xpw);
handles.label.xp=evalin('base','fds.varlab{1}');
handles.units.xp=evalin('base','fds.varunits{1}');
%
%  Clear the axes and return 
%  if the variable is empty.  
%
if isempty(ypw)
  v=axis;
  cla; 
  axis([v(1) v(2) -1 1]);
  xlabel(''); 
  ylabel('');
  return
end
%
%  Clear the axes and return
%  if the workspace variable is a 
%  data structure, cell array, 
%  or character variable.
%
if isstruct(ypw) | iscell(ypw) | ischar(ypw)
  v=axis;
  cla; 
  axis([v(1) v(2) -1 1]);
  xlabel(''); 
  ylabel('');
  set(handles.struct_text,'Visible','on');
  return
end
%
%  If this workspace variable is an array, 
%  plot the first column, unless the channel selection 
%  popup menu is visible.  
%  In that case, plot the channel specified in the 
%  channel selection popup menu.  
%
if ((size(ypw,1)==size(xp,1)) & (size(ypw,2) > 1) & isnumeric(ypw))
  if strcmp(get(handles.array_popup,'Visible'),'on')
    yp=evalin('base',[yplab,'(:,',num2str(get(handles.array_popup,'Value')),');']);
  else
    set(handles.array_text,'Visible','on');
    set(handles.array_popup,'Value',1,'Visible','on',...
                            'String',num2str([1:size(ypw,2)]'));
    yp=evalin('base',[yplab,'(:,',num2str(1),');']);
  end
else
  set(handles.array_text,'Visible','off');
  set(handles.array_popup,'Visible','off');
end
%
%  If this workspace variable is a vector, 
%  plot it if it is the same size as xpw, 
%  otherwise plot each element.
%
if ((size(ypw,1)==1) & (size(ypw,2)~=1)) ...
    | ((size(ypw,1)~=1) & (size(ypw,2)==1)) & isnumeric(ypw)
%
%  If the vector is of the correct length, plot it. 
%
  if (length(ypw)==length(xpw))
    yp=cvec(ypw);
  else
%
%  Otherwise, plot the first element against xp,  
%  unless the channel selection popup menu is visible.  
%  In that case, plot the element specified in the 
%  element selection popup menu.  
%
    if strcmp(get(handles.vector_popup,'Visible'),'on')
      yp=evalin('base',[yplab,'(',num2str(get(handles.vector_popup,'Value')),');']);
    else
      set(handles.vector_popup,'Value',1,'Visible','on',...
                               'String',num2str([1:length(ypw)]'));
      yp=evalin('base',[yplab,'(',num2str(1),');']);
    end
    set(handles.vector_text,'Visible','on','String',['Vector element:  ',num2str(yp)]);
    yp=yp*ones(size(xp,1),1);
  end
else
  set(handles.vector_text,'Visible','off');
  set(handles.vector_popup,'Visible','off');
end
%
%  If this workspace variable is a scalar,
%  plot the scalar.  
%
if (prod(size(ypw))==1 & isnumeric(ypw)) 
  set(handles.scalar_text,'Visible','on','String',['Scalar: ',num2str(ypw)]);
  yp=ypw*ones(size(xp,1),1);  
end
%
%  If the plot variable yp is still not assigned,
%  then the first variable is an array with 
%  dimensions that do not match length(xp).  
%  In this case, clear the axes and return.
%
if ~exist('yp','var')
  v=axis;
  cla; 
  axis([v(1) v(2) -1 1]);
  xlabel(''); 
  ylabel('');
  set(handles.struct_text,'Visible','on');
  return
end
%
%  Save the plot variable data.
%
handles.data.xp=xp;
if get(handles.hold_popup,'Value')==2
  handles.data.yp=[handles.data.yp,yp];
elseif get(handles.hold_popup,'Value')==3
  handles.data.yp=[handles.data.yp,yp];
  handles.data.yp=cmpsigs(handles.data.xp,handles.data.yp,0);
else
  handles.data.yp=yp;
end
%
%  Assemble the legend labels, if necessary.
%
sid_leglab
%
%  Save the plot data.
%
guidata(hObject, handles);
%
%  Plot the data.
%
sid_plot
return
