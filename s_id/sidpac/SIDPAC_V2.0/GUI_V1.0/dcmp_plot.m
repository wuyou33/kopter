%
%  DCMP_PLOT  Makes data compatibility plots.
%
%  Calling GUI: dcmp_gui.m
%
%  Usage: dcmp_plot;
%
%  Description:
%
%    Plots measured and model outputs or output residuals 
%    for data compatibility analysis.
%
%  Input:
%    
%    fdata = matrix of measured flight data in standard configuration.
%        t = time vector.
%       yc = data compatibility model output.
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
%      21 Oct  2000 - Created and debugged, EAM.
%      29 Dec  2005 - Streamlined and updated code, EAM.
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
%  Plot the corresponding measured and model data
%  according to the kinematics listbox value.
%
if (get(guiH.transrot_popup,'Value')==1)
%
%  Translational kinematics.
%
%  First plot - airspeed.
%
  if get(guiH.plot_popup,'Value')==2
    axes(guiH.axes1),plot(t,fdata(:,2)-yc(:,1),'LineWidth',1.5),
  else
    axes(guiH.axes1),plot(t,fdata(:,2),t,yc(:,1),'--','LineWidth',1.5),
  end
  ylabel([fds.varlab{2},fds.varunits{2}]),
%
%  Second plot - sideslip angle.
%
  if get(guiH.plot_popup,'Value')==2
    axes(guiH.axes2),plot(t,fdata(:,3)-yc(:,2)*180/pi,'LineWidth',1.5),
  else
    axes(guiH.axes2),plot(t,fdata(:,3),t,yc(:,2)*180/pi,'--','LineWidth',1.5),
  end
  ylabel([char(fds.varlab(3)),char(fds.varunits(3))]),
%
%  Third plot - angle of attack.
%
  if get(guiH.plot_popup,'Value')==2
    axes(guiH.axes3),plot(t,fdata(:,4)-yc(:,3)*180/pi,'LineWidth',1.5),
  else
    axes(guiH.axes3),plot(t,fdata(:,4),t,yc(:,3)*180/pi,'--','LineWidth',1.5),
  end
  ylabel([char(fds.varlab(4)),char(fds.varunits(4))]),
else
%
%  Rotational kinematics.
%
%  First plot - roll angle.
%
  if get(guiH.plot_popup,'Value')==2
    axes(guiH.axes1),plot(t,fdata(:,8)-yc(:,4)*180/pi,'LineWidth',1.5),
  else
    axes(guiH.axes1),plot(t,fdata(:,8),t,yc(:,4)*180/pi,'--','LineWidth',1.5),
  end
  ylabel([char(fds.varlab(8)),char(fds.varunits(8))]),
%
%  Second plot - pitch angle.
%
  if get(guiH.plot_popup,'Value')==2
    axes(guiH.axes2),plot(t,fdata(:,9)-yc(:,5)*180/pi,'LineWidth',1.5),
  else
    axes(guiH.axes2),plot(t,fdata(:,9),t,yc(:,5)*180/pi,'--','LineWidth',1.5),
  end
  ylabel([char(fds.varlab(9)),char(fds.varunits(9))]),
%
%  Third plot - yaw angle.
%
  if get(guiH.plot_popup,'Value')==2
    axes(guiH.axes3),plot(t,fdata(:,10)-yc(:,6)*180/pi,'LineWidth',1.5),
  else
    axes(guiH.axes3),plot(t,fdata(:,10),t,yc(:,6)*180/pi,'--','LineWidth',1.5),
  end
  ylabel([char(fds.varlab(10)),char(fds.varunits(10))]),
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
  legend('Measured','Reconstructed',0);
end
%
%  Plot title shows the maneuver length.
%
title(['Maneuver length = ',num2str(max(t)-min(t)),char(fds.varunits(1))]);
return
