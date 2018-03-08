%
%  TFEST_DEMO  Demonstrates transfer function parameter estimation.  
%
%  Usage: tfest_demo;
%
%  Description:
%
%    Demonstrates transfer function estimation 
%    program tfest.m using noisy data from the 
%    F-16 nonlinear simulation.  
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
%      tfest.m
%      model_disp.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      15 Mar 2001 - Created and debugged, EAM.
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
fprintf('\n\n Transfer Function Estimation Demo ')
fprintf('\n\n Loading example data...\n')
load 'tfest_demo_data.mat'
fprintf('\n\n For roll mode transfer function estimation, the input ')
fprintf('\n is aileron deflection in deg, and the output is roll rate ')
fprintf('\n in rad/sec.')
%
%  Set up figure window.
%
FgH=figure('Units','normalized',...
           'Position',[.516 .273 .481 .633],...
           'Color',[0.8 0.8 0.8],...
           'Name','Transfer Function Identification',...
           'NumberTitle','off');
%
%  Axes for plotting.
%
AxH=axes('Box','on',...
         'Units','normalized',...
         'Position',[.15 .15 .75 .8],...
         'XGrid','on', 'YGrid','on',...
         'Tag','Axes1');
u=fdata(:,15);
z=fdata(:,5)*pi/180;
fprintf('\n\n The plots show the input and output time histories from ')
fprintf('\n the nonlinear F-16 simulation using a Schroeder sweep ')
fprintf('\n input. The roll rate response has 10 percent Gaussian ')
fprintf('\n noise added to the values from the nonlinear simulation.')
subplot(2,1,2),plot(t,z),grid on,xlabel('time (sec)'),ylabel('roll rate (rps)'),
subplot(2,1,1),plot(t,u),grid on,ylabel('aileron (deg)'),
title('\itSimulated Measured Data','FontSize',12,'FontWeight','bold'),
fprintf('\n\n Press any key to continue ... '),pause,
fprintf('\n\n For the frequency domain analysis, use ')
fprintf('\n the frequency vector w = 2*pi*[0.1:0.05:1.5] (rad/sec). ')
w=2*pi*[0.1:0.05:1.5]';
fprintf('\n\n Identify a 0/1 transfer function for')
fprintf('\n the roll rate response to aileron input,')
fprintf('\n using equation-error in the frequency domain.')
fprintf('\n\n Press any key to continue ... '),pause,
fprintf('\n\n Working...')
[y,num,den,p,crb,s2,zr,xr,f]=tfest(u,z,t,0,1,w);
clf,
subplot(2,1,1),plot(t,z,t,y,':','LineWidth',1.5),
grid on,legend('Data','Model'),xlabel('time (sec)'),ylabel('roll rate (rps)'),
subplot(2,1,2),plot(t,z-y,'LineWidth',1),
grid on,xlabel('time (sec)'),ylabel('residual (rps)'),
fprintf('\n\n The plot shows the model match to the simulated ')
fprintf('\n measured data.  ')
fprintf('\n\n Press any key to continue ... '),pause,
fprintf('\n\n\n The identified transfer function is: \n')
fprintf('\n\n %7.3f / ( s  + %7.3f) \n',p(1),p(2)),
fprintf('\n\n Press any key to continue ... '),pause,
fprintf('\n\n The estimated parameters and 95 percent ')
fprintf('\n confidence bounds are:')
serr=sqrt(diag(crb));
model_disp(p,serr,[],[],pnames);
fprintf('\n\n Corresponding values from a linear model ')
fprintf('\n generated using central finite differences ')
fprintf('\n on the nonlinear simulation are:')
fprintf('\n\n Lda = %7.3f ',B(2,1))
fprintf('\n Lp  = %7.3f ',A(2,2))
fprintf('\n\n Program tfest.m uses equation-error in the frequency')
fprintf('\n domain.  Even better accuracy can be obtained using')
fprintf('\n output-error in the frequency domain (fdoe.m), at the cost ')
fprintf('\n of more computation.  Note that the finite difference ')
fprintf('\n values were computed from smaller perturbations than those ')
fprintf('\n appearing in the simulated data.  Also, the finite ')
fprintf('\n difference perturbations were done one at a time, whereas ')
fprintf('\n for the simulated data, variables changed simultaneously ')
fprintf('\n in a manner dictated by the aircraft dynamics. These ')
fprintf('\n considerations can be sources of mismatch between the ')
fprintf('\n estimated model parameters and the finite difference ')
fprintf('\n model parameters. ')
clear *H;
fprintf('\n\n\n End of demonstration \n\n')
return
