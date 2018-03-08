%
%  SID_PLOT_SETUP  Standard SIDPAC plot set-up.  
%
%  Usage: sid_plot_setup;
%
%  Description:
%
%    Sets up the standard figure and axes for SIDPAC plots.
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
%      sid_plot_lines.m
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
%  Set up the figure window.
%
clf,
set(gcf,'Units','normalized','Position',[0.492 0.360 0.504 0.556],...
        'NumberTitle','off','Toolbar','none');
%
%  Axes setup.
%
set(gca,'Position',[0.160 0.12 0.775 0.815]);
%
%  Set standard appearance.
%
sid_plot_lines,
return
