%
%  TOTTER_TF_DEMO  Demonstrates transfer function modeling using Twin Otter data.
%
%  Usage: totter_tf_demo;
%
%  Description:
%
%    Demonstrates flight data analysis and modeling 
%    using a transfer function model for a longitudinal 
%    flight test maneuver on the NASA Twin Otter aircraft.
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
%      zep.m
%      damps.m
%      tfest.m
%      tfsim.m
%      lesq.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%     15 Feb 2006 - Created and debugged, EAM.
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
%  Load the data file.
%
load 'totter_demo_data.mat'
%
%  Set up the figure window.
%
FgH=figure('Units','normalized','Position',[.506 .231 .504 .715],...
           'Name','SIDPAC Demonstration','NumberTitle','off','Toolbar','none');
%
%  Plot the measured inputs and outputs.
%
subplot(4,1,1), plot(t,fdata(:,14),'LineWidth',2), 
title('Twin Otter Flight Test Data','FontWeight','bold'),
grid on, ylabel('elevator  (deg)'),
subplot(4,1,2), plot(t,fdata(:,4),'LineWidth',2), 
grid on, ylabel('alpha  (deg)'), 
subplot(4,1,3), plot(t,fdata(:,6),'LineWidth',2), 
grid on, ylabel('q  (dps)'), 
subplot(4,1,4), plot(t,fdata(:,13),'LineWidth',2), 
grid on, ylabel('az  (g)'), xlabel('time (sec)'), 
fprintf('\n\n The figure shows the measured input and outputs.')
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Estimate the transfer function model q/de.
%
fprintf('\n\n Estimate the transfer function ')
fprintf('\n for pitch rate to elevator deflection ')
fprintf('\n (q/de), using tfest.m:')
fprintf('\n\n [ytf,num,den,ptf,crbtf,s2tf,zr,xr,f] = tfest(u,z,t,1,2,w);')
fprintf('\n\n The frequency vector is w = 2*pi*[0.3:.01:1.3]'' rad/sec.')
w=2*pi*[0.3:.01:1.3]';
%
%  Detrend the time domain data for frequency domain analysis.
%
u=zep(fdata(:,14));
z=zep(fdata(:,6));
subplot(2,1,1),plot(t,u,'LineWidth',2),grid on,
title('Transfer Function Modeling Data','FontWeight','bold'),
ylabel('elevator  (deg)'),
subplot(2,1,2),plot(t,z,'LineWidth',2),grid on,
ylabel('pitch rate  (dps)'),xlabel('time (sec)'),
fprintf('\n\n Press any key to continue ... '),pause,
[ytf,num,den,ptf,crbtf,s2tf,zr,xr,f] = tfest(u,z,t,1,2,w);
serrtf=sqrt(diag(crbtf));
subplot(2,1,1),plot(f,abs(zr),f,abs(xr*ptf),'r:','LineWidth',1.5),grid on,
title('Frequency Domain Transfer Function Modeling','FontWeight','bold'),
ylabel('magnitude'),legend('flight data','transfer function model')
subplot(2,1,2),plot(f,unwrap(angle(zr)),f,unwrap(angle(xr*ptf)),'r:','LineWidth',1.5),grid on,
ylabel('phase'),xlabel('frequency (Hz)'),
fprintf('\n\nTransfer function:'),
fprintf('\n\n (%5.2f s %5.2f) / (s^2 + %5.2f s + %5.2f) \n\n',ptf(1:4)),
fprintf('\n\n The figure shows the frequency domain fit. ')
fprintf('\n\n Identified modes from the transfer function ')
fprintf('\n identification in the frequency domain are: \n')
damps(den);
fprintf('\n\n Press any key to continue ... '),pause,
subplot(2,1,1),plot(t,z,t,ytf,'r:','LineWidth',1.5),grid on,
title('Equation-Error Frequency Domain Transfer Function Modeling','FontWeight','bold'),
ylabel('pitch rate (dps)'),legend('flight data','transfer function model')
subplot(2,1,2),plot(t,z-ytf,'LineWidth',2),grid on,
ylabel('residual'),xlabel('time (sec)'),
fprintf('\n\n The figure now shows the time domain fit. ')
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Check the prediction capability.
%
load 'totter_pred_data.mat'
fprintf('\n\n Now check the prediction capability ')
fprintf('\n using data from a different maneuver ')
fprintf('\n and the identified transfer function ')
fprintf('\n model from before:')
fprintf('\n\nTransfer function:'),
fprintf('\n\n (%5.2f s %5.2f) / (s^2 + %5.2f s + %5.2f) \n\n',ptf(1:4)),
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Plot the measured inputs and outputs.
%
subplot(4,1,1), plot(t,fdata(:,14),'LineWidth',2), 
title('Twin Otter Flight Test Data','FontWeight','bold'),
grid on, ylabel('elevator  (deg)'),
subplot(4,1,2), plot(t,fdata(:,4),'LineWidth',2), 
grid on, ylabel('alpha  (deg)'), 
subplot(4,1,3), plot(t,fdata(:,6),'LineWidth',2), 
grid on, ylabel('q  (dps)'), 
subplot(4,1,4), plot(t,fdata(:,13),'LineWidth',2), 
grid on, ylabel('az  (g)'), xlabel('time (sec)'), 
fprintf('\n\n\n The figure shows the measured input and outputs ')
fprintf('\n for the prediction maneuver. ')
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Compute the predicted output.
%
u=fdata(:,14); u=zep(u);
z=fdata(:,6); z=zep(z);
ytfp=tfsim(num,den,0,u,t);
%
%  Quick estimate of the bias for the prediction 
%  maneuver.  The bias is not included
%  in the frequency domain modeling, so 
%  it must be estimated separately in the 
%  time domain.  
%
zbias=lesq(ones(length(z),1),z-ytfp);
ytfp=ytfp+zbias;
%
%  Plot the transfer function prediction results.
%
subplot(2,1,1),plot(t,z,t,ytfp,'r:','LineWidth',2),grid on,
title('Transfer Function Prediction','FontWeight','bold'),
ylabel('pitch rate (dps)'),legend('flight data','transfer function prediction')
subplot(2,1,2),plot(t,z-ytfp,'LineWidth',2),grid on,
ylabel('residual'),xlabel('time (sec)'),
fprintf('\n\n The figure shows the time domain prediction ')
fprintf('\n using the transfer function model identified ')
fprintf('\n using data from a different maneuver. ')
fprintf('\n\n\nEnd of demonstration \n\n')
return
