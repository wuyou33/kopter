%
%  SID_VAR_LIST  Updates the fdata column description list.  
%
%  Calling GUI: sid_gui.m
%
%  Usage: sid_var_list;
%
%  Description:
%
%    Generates the list for display of the 
%    data channels in the flight data array fdata.  
%    Data channels that have been assigned are 
%    marked with an asterisk.  
%
%  Input:
%    
%    None
%
%  Output:
%
%    graphics
%
%

%
%    Calls:
%      sid_mrk_chnl.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%     12 Jan 2004 - Created and debugged, EAM.
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
%  Get the variable labels and units.
%
vars = evalin('base','fds.varlab');
units = evalin('base','fds.varunits');
%
%  Mark the channels that have been assigned.
%
n=evalin('base','size(fdata,2)');
varlist=cell(n,1);
for i=1:n,
  if evalin('base',['norm(fdata(:,',num2str(i),'))'])~=0
    vars=sid_mrk_chnl(vars,i);
  end
%
%  Include SIDPAC channel numbers, and line up the display.  
%
  if i < 10
    varlist(i)=cellstr([num2str(i),'  ',char(vars(i)),' ',char(units(i))]);
  else
    varlist(i)=cellstr([num2str(i),' ',char(vars(i)),' ',char(units(i))]);
  end
end
%
%  Update the listbox.
%
set(handles.sidpac_var_listbox,'String',varlist);
return

