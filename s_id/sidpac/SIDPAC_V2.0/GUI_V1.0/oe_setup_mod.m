%
%  OE_SETUP_MOD  Modifies data in edit boxes for output-error model set-up.
%
%  Calling GUI: dcmp_setup_gui.m, oe_lon_setup_gui.m, oe_lat_setup_gui.m
%
%  Usage: oe_setup_mod;
%
%  Description:
%
%    Modifies data in edit boxes 
%    for output-error model set-up.
%
%  Input:
%
%    None
%
%  Output:
%
%    None
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      30 Dec  2005 - Created and debugged, EAM.
%      05 Aug  2006 - Adapted for multiple GUI use, EAM.
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
%  Get the input string from the calling edit box.
%
str=get(hObject,'String');
%
%  Change the string to a number.
%
num=str2num(char(str));
%
%  Set the edit box value equal to the number 
%  corresponding to the input string.  
%  If something other than a number has been input, 
%  num will be empty, so set the value to zero.  
%
if ~isempty(num)
  set(hObject,'Value',num);
  set(hObject,'String',str);
%
%  Flash the edit box to 
%  give feedback that the
%  change was entered.  
%
  set(hObject,'Visible','off');
  pause(0.05);
  set(hObject,'Visible','on');
else
  set(hObject,'Value',0);
  set(hObject,'String','0.0');
end
return
