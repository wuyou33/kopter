%
%  OE_LAT_DEMO  Demonstrates lateral output-error parameter estimation in the time domain. 
%
%  Usage: oe_lat_demo;
%
%  Description:
%
%    Demonstrates output-error maximum likelihood 
%    parameter estimation for linearized  
%    lateral dynamics using flight test data
%    from the NASA F-18 High Alpha Research Vehicle (HARV).  
%
%  Input:
%
%    None
%
%  Output:
%
%    graphics:
%      2D plots
%

%
%    Calls:
%      xsmep.m
%      oe.m
%      tlatssd.m
%      model_disp.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      19 Jan 2001 - Created and debugged, EAM.
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
fprintf('\n\n Output Error Maximum Likelihood\n')
fprintf(' Parameter Estimation Demo ')
fprintf('\n\n Loading lateral example data...\n\n\n')
load 'oe_lat_demo_data.mat'
disp('For lateral dynamics output-error parameter ')
fprintf('estimation, the state variables are : \n')
states,
fprintf('\n\nThe outputs are: \n')
outputs,
%
%  Set up figure window.
%
FgH=figure('Units','normalized',...
           'Position',[.43 .14 .56 .75],...
           'Color',[0.8 0.8 0.8],...
           'Name','Output-Error Parameter Estimation',...
           'NumberTitle','off',...
           'Tag','Fig1');
%
%  Axes for plotting.
%
AxH=axes('Box','on',...
         'Units','normalized',...
         'Position',[.15 .15 .9 .8],...
         'XGrid','on', 'YGrid','on',...
         'Tag','Axes1');
subplot(5,1,1),plot(t,z(:,1)),grid on;ylabel('beta (rad)'),
set(gca,'XTickLabel','','Position',[.15 .8 .81 .15]);
title('\itMeasured Outputs','FontSize',12,'FontWeight','bold'),
subplot(5,1,2),plot(t,z(:,2)),grid on;ylabel('p (rps)'),
set(gca,'XTickLabel','','Position',[.15 .62 .81 .15]);
subplot(5,1,3),plot(t,z(:,3)),grid on;ylabel('r (rps)'),
set(gca,'XTickLabel','','Position',[.15 .44 .81 .15]);
subplot(5,1,4),plot(t,z(:,4)),grid on;ylabel('phi (rad)')
set(gca,'XTickLabel','','Position',[.15 .26 .81 .15]);
subplot(5,1,5),plot(t,z(:,5)),grid on;ylabel('ay (fps2)'),xlabel('time (sec)'),
set(gca,'Position',[.15 .08 .81 .15]);
fprintf('\n\n Press any key to continue ... '),pause,
fprintf('\n\nThe input variables are: \n')
inputs,
subplot(2,1,1),plot(t,u(:,1)),grid on;ylabel('rudder (rad)'),
title('\itMeasured Inputs','FontSize',12,'FontWeight','bold'),
subplot(2,1,2),plot(t,u(:,2)),grid on;ylabel('aileron (rad)'),xlabel('time (sec)'),
fprintf('\n\n Press any key to continue ... '),pause,
fprintf('\n\nThe dynamic model and parameterization is defined \n')
fprintf('in the user-defined file tlatssd.m for this example. ')
fprintf('\n\nThe model and parameterization are such that \n')
fprintf('the first parameter is Ybeta, the fifth parameter \n')
fprintf('is Lp, and so on.  The input constant vector c \n')
fprintf('provides constant values such as the sine of \n')
fprintf('the nominal angle of attack, and other constants \n')
fprintf('needed for the linear dynamic model. \n')
fprintf('\n\n Press any key to continue ... '),pause,
fprintf('\n\nInitial values of the parameters in vector p0 are selected \n')
fprintf('as rough values for a typical aircraft:\n')
p0,
disp('Initial conditions are determined from smoothed ')
disp('measured values, using program xsmep.m. ')
xs=xsmep(z(:,[1:4]),2.0,dt);
x0=xs(1,:)',
fprintf('\n\n Press any key to continue ... '),pause,
fprintf('\n\nNow estimate the model parameters \n')
disp('using program oe.m.  ')
fprintf('\n\n Press any key to continue ... '),pause,
[y,p,crb,rr]=oe('tlatssd',p0,u,t,x0,c,z);
serr=sqrt(diag(crb));
%
%  Plot the results.
%
subplot(5,1,1),plot(t,z(:,1),t,y(:,1),'LineWidth',1.5),
grid on;ylabel('beta (rad)'),
set(gca,'XTickLabel','','Position',[.15 .8 .81 .15]);
title('\itMeasured Outputs','FontSize',12,'FontWeight','bold'),
subplot(5,1,2),plot(t,z(:,2),t,y(:,2),'LineWidth',1.5),
grid on;ylabel('p (rps)'),
set(gca,'XTickLabel','','Position',[.15 .62 .81 .15]);
subplot(5,1,3),plot(t,z(:,3),t,y(:,3),'LineWidth',1.5),
grid on;ylabel('r (rps)'),
set(gca,'XTickLabel','','Position',[.15 .44 .81 .15]);
subplot(5,1,4),plot(t,z(:,4),t,y(:,4),'LineWidth',1.5),
grid on;ylabel('phi (rad)')
set(gca,'XTickLabel','','Position',[.15 .26 .81 .15]);
subplot(5,1,5),plot(t,z(:,5),t,y(:,5),'LineWidth',1.5),
grid on;ylabel('ay (fps2)'),xlabel('time (sec)'),
set(gca,'Position',[.15 .08 .81 .15]);
%
%  Show modeling results, omitting 
%  the bias parameters.
%
indx=[1,2,4,5,6,7,8,10,11,12,13]';
model_disp(p(indx),serr(indx),[],[],pnames);
fprintf('\n\nThe parameter estimation results are shown above. ')
fprintf('\nEstimates of the bias parameters have been omitted, ')
fprintf('\nbecause they are not of primary interest.  ')
fprintf('\nThe figure shows a slight mismatch in the ')
fprintf('\nmodel fit to yaw rate near 15 sec, which is ')
fprintf('\nlikely from unmodeled nonlinear effects.')
fprintf('\nNote that other variables have large values ')
fprintf('\nor are changing rapidly around this time. ')
fprintf('\n\n\nEnd of demonstration \n\n')
return
