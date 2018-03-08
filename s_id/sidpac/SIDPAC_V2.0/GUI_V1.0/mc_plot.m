%
%  MC_PLOT  Draws a plot of GUI plot data.
%
%  Calling GUI: mc_gui.m
%
%  Usage: mc_plot;
%
%  Description:
%
%    Draws a labeled plot of GUI plot data.
%
%
%  Input:
%
%    handles.data.xp = abscissa vector.
%    handles.label.xp = xp axis label.
%    handles.units.xp = xp units.
%
%    handles.data.yp = ordinate vector(s).
%    handles.label.yp = yp axis label. 
%    handles.units.yp = yp units.
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
%      28 Dec  2005 - Created and debugged, EAM.
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
indi=evalin('base','indi');
indf=evalin('base','indf');
xp=handles.data.xp([indi:indf]);
yp=handles.data.yp([indi:indf],:);
%
%  Check for data length mismatch.
%
if length(xp)~=size(yp,1) 
  return
end
%
%  Check the grid status.
%
if strcmp(get(gca,'XGrid'),'on')
  lgrid=1;
else
  lgrid=0;
end
%
%  Plot data, label axes.  Plot modulus 
%  of complex numbers.
%
if isreal(yp)
  plot(xp,yp,'Linewidth',1.0)
else
  plot(xp,abs(yp),'Linewidth',1.0)
end
%
%  Label the plot.
%
xlabel([handles.label.xp,handles.units.xp]);
ylabel([handles.label.yp,handles.units.yp]);
%
%  Restore grid status. 
%
if lgrid==1
  grid on
else
  grid off
end
%
%  Display the legend.
%
if get(handles.hold_popup,'Value') > 1
  ylabel(['          ','          ']);
  legend(handles.leglab);
end
%
%  Plot title shows the maneuver length.
%
title(['Data length = ',num2str(max(xp)-min(xp)),handles.units.xp]);
return
