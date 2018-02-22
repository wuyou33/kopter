%
%  F16_DEMO  Demonstrates the F-16 nonlinear simulation.
%
%  Usage: f16_demo;
%
%  Description:
%
%    Demonstrates the F-16 nonlinear simulation.
%
%
%  Input:
%
%    None
%
%  Output:
%
%    2-D graphics
%
%

%
%    Calls:
%      gen_f16_model.m
%      f16.m
%      mksqw.m
%      damps.m
%      lsims.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      26 Jun 2005 - Created and debugged, EAM.
%      23 Feb 2006 - Updated for F-16 NLS version 1.1, EAM.
%      02 Aug 2006 - Changed elevator to stabilator, EAM.
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
fprintf('\n\n F-16 Simulation Demo ')
fprintf('\n\n First, trim the F-16 and find a linear longitudinal ')
fprintf('\n model using finite differences.  ')
fprintf('\n\n Press any key to continue ... '),pause,
clear ix iu;
gen_f16_model
format short e,
x0,
u0,
format,
A,
B,
damps(A);
%
%  Figure setup.
%
set(gcf,'Units','normalized');
set(gcf,'Position',[0.49 0.35 0.50 0.50]);
%
%  Axes setup.
%
set(get(gca,'Children'),'MarkerSize',9);
if ~isempty(get(gca,'ZTickLabel'))
  set(get(gca,'Children'),'EdgeColor','interp','FaceColor','interp');
end
%
%  Axis labels.
%
set(get(gca,'Xlabel'),'FontSize',9,'FontWeight','bold');
set(get(gca,'Ylabel'),'FontSize',9,'FontWeight','bold');
if ~isempty(get(gca,'ZTickLabel'))
  set(get(gca,'Zlabel'),'FontSize',9,'FontWeight','bold');
end
%
%  Create the doublet input.
%
[usw,t]=mksqw(-1,1,[1 1],1,.025,10);
npts=length(t);
ulin=zeros(npts,2);
ulin(:,2)=usw;
fprintf('\n\n The figure shows the perturbation doublet input ')
fprintf('\n applied to the stabilator.  Throttle is held constant. ')
subplot(2,1,1),plot(t,ulin(:,2),'LineWidth',2),ylabel('stabilator (deg) '),grid on,
axis([0 10 -2 2]),
subplot(2,1,2),plot(t,ulin(:,1),'LineWidth',2),ylabel('throttle '),xlabel('time (sec)'),grid on,
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Linear model.
%
x0lin=zeros(5,1);
rtd=180/pi;
fprintf('\n\n Now integrate the linearized equations of motion, and')
fprintf('\n plot the responses, which are perturbation quantities. ')
fprintf('\n\n Press any key to continue ... '),pause,
ylin=lsims(A,B,C,D,ulin,t,x0lin);
set(gcf,'Position',[0.49 0.11 0.50 0.80]);
subplot(4,1,1),plot(t,ylin(:,1),'LineWidth',2),ylabel('airspeed (fps)'),grid on,
title('F-16 Stabilator Doublet Simulation')
subplot(4,1,2),plot(t,ylin(:,2)*rtd,'LineWidth',2),ylabel('alpha (deg)'),grid on,
subplot(4,1,3),plot(t,ylin(:,3)*rtd,'LineWidth',2),ylabel('pitch rate (dps)'),grid on,
subplot(4,1,4),plot(t,ylin(:,4)*rtd,'LineWidth',2),ylabel('pitch angle (deg)'),xlabel('time (sec)'),grid on,
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Nonlinear model.
%
fprintf('\n\n Use the same stabilator doublet input ')
fprintf('\n for the nonlinear simulation.  In this case, ')
fprintf('\n the perturbation doublet is added to the trim ')
fprintf('\n stabilator deflection. ')
%
%  Input plots.
%
u=ones(npts,1)*u0';
u(:,2)=u(:,2)+usw;
set(gcf,'Position',[0.49 0.35 0.50 0.50]);
subplot(2,1,1),plot(t,[u(:,2),ulin(:,2)],'LineWidth',2),ylabel('stabilator (deg) '),grid on,
legend('Nonlinear','Linear'),title('F-16 Stabilator Doublet Simulation')
subplot(2,1,2),plot(t,[u(:,1),ulin(:,1)],'LineWidth',2),ylabel('Throttle '),xlabel('time (sec)'),grid on,
fprintf('\n\n Press any key to continue ... '),pause,
[y,x]=f16(u,t,x0,c);
fprintf('\n\n The figure shows the responses from the linear model ')
fprintf('\n and the nonlinear simulation, plotted on the same axes. ')
%
%  Response plots.
%
set(gcf,'Position',[0.49 0.11 0.50 0.80]);
subplot(4,1,1),plot(t,[y(:,1),ylin(:,1)+y(1,1)],'LineWidth',2),ylabel('airspeed (fps)'),
grid on,legend('Nonlinear','Linear'),title('F-16 Stabilator Doublet Simulation')
subplot(4,1,2),plot(t,[y(:,3),(ylin(:,2)+y(1,3))]*rtd,'LineWidth',2),ylabel('alpha (deg)'),grid on,
subplot(4,1,3),plot(t,[y(:,5),(ylin(:,3)+y(1,5))]*rtd,'LineWidth',2),ylabel('pitch rate (dps)'),grid on,
subplot(4,1,4),plot(t,[y(:,8),(ylin(:,4)+y(1,8))]*rtd,'LineWidth',2),ylabel('pitch angle (deg)'),xlabel('time (sec)'),grid on,
fprintf('\n\n The linear model is an excellent representation ')
fprintf('\n of the aircraft longitudinal dynamics for this small ')
fprintf('\n perturbation stabilator input.  ')
fprintf('\n\n\n End of demonstration \n\n'),
return
