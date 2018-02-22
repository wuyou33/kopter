%
%  SID_LEGLAB  Assembles legend labels for plots.  
%
%  Calling GUI: sid_gui.m
%
%  Usage: sid_leglab;
%
%  Description:
%
%    Assembles legend labels for plots.  
%
%  Input:
%    
%    None
%
%  Output:
%
%    handles.leglab = legend labels.
%
%

%
%    Author:  Eugene A. Morelli
%
%    Calls:
%      None
%
%    History:  
%      28 Dec  2005 - Created and debugged, EAM.
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
%  If hold is on, assemble text for a legend.
%
if get(handles.hold_popup,'Value') > 1
  handles.leglab={handles.leglab{[1:size(handles.data.yp,2)-1]},...
                  [handles.label.yp,handles.units.yp]};
%
%  If this is a compare, remove the units from the legend labels, 
%  because the compare function alters the scales. 
%
  if get(handles.hold_popup,'Value')==3 & size(handles.data.yp,2) > 1
    nlab=length(handles.leglab);
    for i=1:nlab,
      tmp=handles.leglab{i};
      ilo=find(tmp=='(');
      ihi=find(tmp==')');
      if ~isempty(ilo) & ~isempty(ihi)
        for j=ilo:ihi,
          tmp(j)=' ';
        end
        handles.leglab{i}=tmp;
      end
    end
  end
else
  handles.leglab={[handles.label.yp,handles.units.yp]};
end
return
