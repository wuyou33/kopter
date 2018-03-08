%
%  SID_PLOT_LINES  Defines standard SIDPAC plot line characteristics.
%
%  Usage: sid_plot_lines;
%
%  Description:
%
%    Implements the standard appearance for SIDPAC plots.
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
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      19 Apr 2004 - Created and debugged, EAM.
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
%  Appearance setup.
%
grid on,
set(get(gca,'Children'),'MarkerSize',8);
set(get(gca,'Children'),'LineWidth',1.5);
if ~isempty(get(gca,'ZTickLabel'))
  set(get(gca,'Children'),'EdgeColor','interp','FaceColor','interp');
end
return
