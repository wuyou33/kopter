%
%  SID_ASSIGN  Assigns plotted data to the fdata array.
%
%  Calling GUI: sid_gui.m
%
%  Usage: sid_assign;
%
%  Description:
%
%    Assigns plotted data to the fdata array
%    according to user input.
%
%  Input:
%    
%    handles.data.yp = plotted data.
%
%  Output:
%
%    fdata = flight data array.
%
%

%
%    Author:  Eugene A. Morelli
%
%    Calls:
%      sid_var_list.m
%      sid_var_plot.m
%
%    History:  
%      27 Dec  2005 - Created and debugged, EAM.
%
%  Copyright (C) 2006  Eugene A. Morelli
%
%
%  This program carries no warranty, not even the implied 
%  warranty of merchantability or fitness for a particular purpose.  
%
%  Please email bug reports or suggestions for improvements to:
%
%      e.a.morelli@nasa.gov
%

%
%  Assign the selected column in the fdata matrix 
%  using the current plotted variable.
%
iy=get(handles.assign_popup,'Value');
evalin('base','guiH=guidata(gcf);');
if evalin('base',['size(fdata(:,',num2str(iy),'),1)==size(guiH.data.yp,1)'])
  evalin('base',['fdata(:,',num2str(iy),')=guiH.data.yp(:,1);']);
%
%  Skip the documentation update if the documentation already exists.  
%
  if evalin('base',['isempty(fds.vardesc{',num2str(iy),'})'])
%
%  Get the documentation for the newly added data, and 
%  place the information in the fds flight data structure 
%  located in the MATLAB workspace.
%
    data=inputdlg({'Description: ','Label: ','Units: '},...
                   'Data Assign',...
                  [1,27;1,6;1,10],...
                  {'elevator  (deg)','el','(deg)'});
%
%  Skip the documentation update if the dialog box input is cancelled, 
%  or if the documentation already exists.  
%
    if ~isempty(data)
      evalin('base',['fds.vardesc{',num2str(iy),'}=[''  '',''',data{1},''','' ''];']);
      evalin('base',['fds.varlab{',num2str(iy),'}=[''  '',''',data{2},''','' ''];']);
      evalin('base',['fds.varunits{',num2str(iy),'}=['' '',''',data{3},''','' ''];']);
    end
  end
end
%
%  Update the listbox and plot.
%
sid_var_list
set(handles.sidpac_var_listbox,'Value',iy);
sid_var_plot
return
