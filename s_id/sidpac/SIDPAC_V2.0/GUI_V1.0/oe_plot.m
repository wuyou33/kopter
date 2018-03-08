%
%  OE_PLOT  Makes data compatibility plots.
%
%  Calling GUI: oe_gui.m
%
%  Usage: oe_plot;
%
%  Description:
%
%    Plots measured and model outputs or output residuals 
%    for output-error parameter estimation.
%
%  Input:
%    
%    fdata = matrix of measured flight data in standard configuration.
%        t = time vector.
%        y = model output.
%
%  Output:
%
%    2-D plots
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      06 Aug  2006 - Created and debugged, EAM.
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

rtd=180/pi;
%
%  Dynamic case - longitudinal or lateral.  
%
if exist('coe','var')
  runopt=coe.runopt;
  dopt=coe.dopt;
else
  runopt=get(guiH.lonlat_popup,'Value');
  coe=oe_psel(fdata,runopt);
end
if runopt==1
%
%  Longitudinal plots.
%
%
%  Determine which group of longitudinal plots to show.  
%
  igrp=get(guiH.group_popup,'Value');
%
%  Group 1.
%
  if igrp==1
%
%  First plot - angle of attack.
%
    if get(guiH.plot_popup,'Value')==2
      axes(guiH.axes1),plot(t,fdata(:,4)-y(:,2)*rtd,'LineWidth',1.5),
    else
      axes(guiH.axes1),plot(t,fdata(:,4),t,y(:,2)*rtd,'--','LineWidth',1.5),
    end
    ylabel([char(fds.varlab(4)),char(fds.varunits(4))]),
%
%  Second plot - pitch rate.
%
    if get(guiH.plot_popup,'Value')==2
      axes(guiH.axes2),plot(t,fdata(:,6)-y(:,3)*rtd,'LineWidth',1.5),
    else
      axes(guiH.axes2),plot(t,fdata(:,6),t,y(:,3)*rtd,'--','LineWidth',1.5),
    end
    ylabel([char(fds.varlab(6)),char(fds.varunits(6))]),
%
%  Third plot - az.
%
    if get(guiH.plot_popup,'Value')==2
      axes(guiH.axes3),plot(t,fdata(:,13)-y(:,6),'LineWidth',1.5),
    else
      axes(guiH.axes3),plot(t,fdata(:,13),t,y(:,6),'--','LineWidth',1.5),
    end
    ylabel([char(fds.varlab(13)),char(fds.varunits(13))]),
  end
%
%  Group 2.
%
  if igrp==2
%
%  First plot - airspeed.
%
    if get(guiH.plot_popup,'Value')==2
      axes(guiH.axes1),plot(t,fdata(:,2)-y(:,1),'LineWidth',1.5),
    else
      axes(guiH.axes1),plot(t,fdata(:,2),t,y(:,1),'--','LineWidth',1.5),
    end
    ylabel([char(fds.varlab(2)),char(fds.varunits(2))]),
%
%  Second plot - ax.
%
    if get(guiH.plot_popup,'Value')==2
      axes(guiH.axes2),plot(t,fdata(:,11)-y(:,5),'LineWidth',1.5),
    else
      axes(guiH.axes2),plot(t,fdata(:,11),t,y(:,5),'--','LineWidth',1.5),
    end
    ylabel([char(fds.varlab(11)),char(fds.varunits(11))]),
%
%  Third plot - pitch angle.
%
    if get(guiH.plot_popup,'Value')==2
      axes(guiH.axes3),plot(t,fdata(:,9)-y(:,4)*rtd,'LineWidth',1.5),
    else
      axes(guiH.axes3),plot(t,fdata(:,9),t,y(:,4)*rtd,'--','LineWidth',1.5),
    end
    ylabel([char(fds.varlab(9)),char(fds.varunits(9))]),
  end
else
%
%  Lateral plots.
%
%
%  Determine which group of longitudinal plots to show.  
%
  igrp=get(guiH.group_popup,'Value');
%
%  Group 1.
%
  if igrp==1
%
%  First plot - sideslip angle.
%
    if get(guiH.plot_popup,'Value')==2
      axes(guiH.axes1),plot(t,fdata(:,3)-y(:,1)*rtd,'LineWidth',1.5),
    else
      axes(guiH.axes1),plot(t,fdata(:,3),t,y(:,1)*rtd,'--','LineWidth',1.5),
    end
    ylabel([char(fds.varlab(3)),char(fds.varunits(3))]),
%
%  Second plot - roll rate.
%
    if get(guiH.plot_popup,'Value')==2
      axes(guiH.axes2),plot(t,fdata(:,5)-y(:,2)*rtd,'LineWidth',1.5),
    else
      axes(guiH.axes2),plot(t,fdata(:,5),t,y(:,2)*rtd,'--','LineWidth',1.5),
    end
    ylabel([char(fds.varlab(5)),char(fds.varunits(5))]),
%
%  Third plot - yaw rate.
%
    if get(guiH.plot_popup,'Value')==2
      axes(guiH.axes3),plot(t,fdata(:,7)-y(:,3)*rtd,'LineWidth',1.5),
    else
      axes(guiH.axes3),plot(t,fdata(:,7),t,y(:,3)*rtd,'--','LineWidth',1.5),
    end
    ylabel([char(fds.varlab(7)),char(fds.varunits(7))]),
  end
%
%  Group 2.
%
  if igrp==2
%
%  First plot - phi.
%
    if get(guiH.plot_popup,'Value')==2
      axes(guiH.axes1),plot(t,fdata(:,8)-y(:,4)*rtd,'LineWidth',1.5),
    else
      axes(guiH.axes1),plot(t,fdata(:,8),t,y(:,4)*rtd,'--','LineWidth',1.5),
    end
    ylabel([char(fds.varlab(8)),char(fds.varunits(8))]),
%
%  Second plot - ay.
%
    if get(guiH.plot_popup,'Value')==2
      axes(guiH.axes2),plot(t,fdata(:,12)-y(:,5),'LineWidth',1.5),
    else
      axes(guiH.axes2),plot(t,fdata(:,12),t,y(:,5),'--','LineWidth',1.5),
    end
    ylabel([char(fds.varlab(12)),char(fds.varunits(12))]),
%
%  Third plot - yaw rate.
%
    if get(guiH.plot_popup,'Value')==2
      axes(guiH.axes3),plot(t,fdata(:,7)-y(:,3)*rtd,'LineWidth',1.5),
    else
      axes(guiH.axes3),plot(t,fdata(:,7),t,y(:,3)*rtd,'--','LineWidth',1.5),
    end
    ylabel([char(fds.varlab(7)),char(fds.varunits(7))]),
  end
end
%
%  Abscissa label.
%
xlabel([char(fds.varlab(1)),char(fds.varunits(1))]),
%
%  Grids on or off according to the grid radio button value.
%
if (get(guiH.grid_radiobutton,'Value')==1)
  axes(guiH.axes3),grid on,
  axes(guiH.axes2),grid on,
  axes(guiH.axes1),grid on,
else
  axes(guiH.axes3),grid off,
  axes(guiH.axes2),grid off,
  axes(guiH.axes1),grid off,
end
%
%  Add the legend to the first plot.
%
if get(guiH.plot_popup,'Value')==2
  legend('Residuals',0);
else
  legend('Data','Model',0);
end
%
%  Plot title shows the maneuver length.
%
title(['Maneuver length = ',num2str(max(t)-min(t)),char(fds.varunits(1))]);
return
