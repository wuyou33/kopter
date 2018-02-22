%
%  TOTTER_DEMO  Demonstrates SIDPAC codes using Twin Otter data.
%
%  Usage: totter_demo;
%
%  Description:
%
%    Demonstrates flight data analysis and modeling 
%    using SIDPAC for a longitudinal flight test maneuver 
%    on the NASA Twin Otter aircraft.
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
%      compfc.m
%      compmc.m
%      xsmep.m
%      lesq.m
%      r_colores.m
%      model_disp.m
%      swr.m
%      nldyn_psel.m
%      oe.m
%      nldyn.m
%      m_colores.m
%      plotpest.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%     11 Jul 2002 - Created and debugged, EAM.
%     15 Feb 2006 - Split off transfer function demo to totter_tf_demo.m, EAM.
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
%  Calculate aerodynamic force and moment coefficients.
%
fprintf('\n\n Calculate the non-dimensional ')
fprintf('\n aerodynamic force and moment ')
fprintf('\n coefficients using compfc.m and compmc.m:')
fprintf('\n\n [CX,CY,CZ,CD,CYw,CL]=compfc(fdata);')
fprintf('\n\n [Cl,Cm,Cn]=compmc(fdata);')
fprintf('\n\n Press any key to continue ... '),pause,
[CX,CY,CZ,CD,CYw,CL]=compfc(fdata);
[Cl,Cm,Cn,pv,qv,rv]=compmc(fdata);
subplot(2,1,1),plot(t,CZ,'LineWidth',2),grid on,ylabel('Z force coefficient'),
title('Non-Dimensional Coefficients from Flight Test Data','FontWeight','bold'),
subplot(2,1,2),plot(t,Cm,'LineWidth',2),grid on,ylabel('pitching moment coefficient'),xlabel('time (sec)'), 
%
%  Assemble the regressor matrix.
%
fprintf('\n\n Assemble the matrix of regressors ')
fprintf('\n for equation-error parameter estimation: ')
fprintf('\n\n alpha  (rad)'),
fprintf('\n qhat '),
fprintf('\n elevator  (rad)'),
fprintf('\n\n Press any key to continue ... '),pause,
X=[fdata(:,4)*pi/180,fdata(:,72),fdata(:,14)*pi/180];
%
%  Plot the regressors.
%
subplot(3,1,1),plot(t,X(:,1),'LineWidth',2),grid on,ylabel('alpha  (rad)'),
title('Equation-Error Regressors','FontWeight','bold'),
subplot(3,1,2),plot(t,X(:,2),'LineWidth',2),grid on,ylabel('qhat '),
subplot(3,1,3),plot(t,X(:,3),'LineWidth',2),grid on,ylabel('elevator  (rad)'),
xlabel('time (sec)'),
%
%  Find smoothed trim values. 
%
fprintf('\n\n Find the smoothed trim values ')
fprintf('\n from the regressors using xsmep.m:')
fprintf('\n\n X0=xsmep(X,1.0,dt);')
fprintf('\n\n Then remove the smoothed trim values ')
fprintf('\n from the regressors using :')
fprintf('\n\n X=X-ones(size(X,1),1)*X0(1,:);')
fprintf('\n\n Press any key to continue ... '),pause,
X0=xsmep(X,1,dt);
%
%  Plot the regressors and the smoothed trim values.
%
subplot(3,1,1),plot(t,X(:,1),'LineWidth',2),hold on,
title('Equation-Error Regressors','FontWeight','bold'),
plot(t(1),X0(1,1),'r.','MarkerSize',14,'LineWidth',2), hold off,
grid on,ylabel('alpha  (rad)'),
subplot(3,1,2),plot(t,X(:,2),'LineWidth',2), hold on,
plot(t(1),X0(1,2),'r.','MarkerSize',14,'LineWidth',2), hold off,
grid on,ylabel('qhat '),
subplot(3,1,3),plot(t,X(:,3),'LineWidth',2), hold on,
plot(t(1),X0(1,3),'r.','MarkerSize',14,'LineWidth',2), hold off,
grid on,ylabel('elevator  (deg)'),xlabel('time (sec)'),
%
%  Remove the smoothed trim values.
%
X=X-ones(size(X,1),1)*X0(1,:);
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Program lesq.m requires a constant regressor for the bias term.
%
X=[X,ones(size(X,1),1)];
%
%  Linear regression for the Z force coefficient.
%
fprintf('\n\n Z force coefficient:')
fprintf('\n\n Estimate stability and control ')
fprintf('\n derivatives using equation-error ')
fprintf('\n linear regression program lesq.m: ')
fprintf('\n\n [yZ,pZ,crbZ,s2Z]=lesq(X,CZ);')
fprintf('\n\n Omit the CZq term at this low alpha')
fprintf('\n flight condition.  ')
fprintf('\n\n Press any key to continue ... '),pause,
[yZ,pZ,crbZ,s2Z]=lesq(X(:,[1,3,4]),CZ);
%
%  Plot the results.
%
subplot(2,1,1),plot(t,CZ,t,yZ,'r:','LineWidth',2),grid on,
title('Equation-Error Parameter Estimation','FontWeight','bold'),
ylabel('CZ'),legend('flight data','regression model'),
subplot(2,1,2),plot(t,CZ-yZ,'LineWidth',1.5),grid on,
ylabel('residual'),xlabel('time (sec)'),
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Compute and display the error bounds.  
%
fprintf('\n\n Compute the estimated parameter ')
fprintf('\n error bounds using r_colores.m: ')
fprintf('\n\n [crbZ,crboZ]=r_colores(X,CZ); ')
[crbZ,crboZ]=r_colores(X(:,[1,3,4]),CZ);
serroZ=sqrt(diag(crboZ));
serrZ=sqrt(diag(crbZ));
perrZ=100*serrZ./abs(pZ);
fprintf('\n\n Display the parameter estimation ')
fprintf('\n results using model_disp.m:')
Xlab=['alpha  (rad)   ';'qhat           ';'elevator  (rad)'];
model_disp(pZ,serrZ,[],Xlab([1,3],:),pZnames([1,3,4],:));
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Stepwise regression for the pitching moment coefficient.
%
fprintf('\n\n Pitching moment coefficient: ')
fprintf('\n\n Add a nonlinear cross term alpha*elevator ,')
fprintf('\n regressor and use stepwise regression program swr.m:')
fprintf('\n\n [ym,pm,crbm,s2m]=swr(X,Cm);')
fprintf('\n\n Study the effect of adding and deleting ')
fprintf('\n regressors by typing 1 3 2 4 4 0 in succession, ')
fprintf('\n each followed by the enter key. ')
%
%  Program swr.m adds the bias term automatically, 
%  so the constant regressor is not necessary.  Add 
%  the nonlinear cross term to the regressor matrix X.  
%
X=[X(:,[1:3]),X(:,1).*X(:,3)];
[ym,pm,crbm,s2m,Xm,pindxm]=swr(X,Cm,1);
%
%  Include only parameters for selected regressors.
%
pm=pm(pindxm);
%
%  Plot the results.
%
subplot(2,1,1),plot(t,Cm,t,ym,'r:','LineWidth',2),grid on,
title('Pitching Moment Coefficient','FontWeight','bold'),
ylabel('Cm'),legend('flight data','equation-error model')
subplot(2,1,2),plot(t,Cm-ym,'LineWidth',2),grid on,
ylabel('residual'),xlabel('time (sec)'),
%
%  Compute and display the error bounds.
%
fprintf('\n\n Compute the estimated parameter ')
fprintf('\n error bounds using r_colores.m: ')
fprintf('\n\n [crbm,crbom]=r_colores(X,Cm); ')
[crbm,crbom]=r_colores(Xm,Cm);
serrom=sqrt(diag(crbom));
serrm=sqrt(diag(crbm));
perrm=100*serrm./abs(pm);
fprintf('\n\n Display the parameter estimation ')
fprintf('\n results using model_disp.m:')
model_disp(pm,serrm,[],Xlab,pmnames);
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Estimate the dimensional stability and control derivatives 
%  using time-domain output-error parameter estimation.  
%
fprintf('\n\n\n Now estimate the non-dimensional stability ')
fprintf('\n and control derivatives using output-error ')
fprintf('\n parameter estimation in the time domain.')
fprintf('\n\n Input:   elevator (rad)')
fprintf('\n Outputs: alpha (rad), q (rad/sec), az (g)')
dtr=pi/180;
u=fdata(:,[14:16])*dtr;
z=[fdata(:,[4,6])*dtr,fdata(:,13)];
%
%  Plot the measured inputs and outputs.
%
subplot(4,1,1), plot(t,u(:,1),'LineWidth',2), 
title('Output-Error Time Domain Modeling','FontWeight','bold'),
grid on, ylabel('elevator  (rad)'), 
subplot(4,1,2), plot(t,z(:,1),'LineWidth',2), 
grid on, ylabel('alpha  (rad)'), 
subplot(4,1,3), plot(t,z(:,2),'LineWidth',2), 
grid on, ylabel('q  (rps)'), 
subplot(4,1,4), plot(t,z(:,3),'LineWidth',2), 
grid on, ylabel('az  (g)'), xlabel('time (sec)'), 
fprintf('\n\n The figure shows the measured input and outputs.')
%
%  Set up for the output-error parameter estimation 
%  using nldyn.m.
%
coe=nldyn_psel(fdata);
zsmep=xsmep(fdata(:,[2:10]),2,dt);
x0=[zsmep(1,1),zsmep(1,[2:9])*dtr]';
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Find initial parameter values for the 
%  output-error parameter estimation.
%
fprintf('\n\n Initial values of the parameters in ')
fprintf('\n vector p0 are obtained from the ')
fprintf('\n equation-error solution:\n')
%
%  Omit the CZq term in the output-error formulation, 
%  because of low sensitivity at low angles of attack.
%
p0=[pZ;pm;0],
serr0=[serrZ;serrm;0];
fprintf('\n\n Estimate the model parameters ')
fprintf('\n using output-error parameter estimation ')
fprintf('\n program oe.m and dynamic model file nldyn.m:  ')
fprintf('\n\n [y,p,crb,rr]=oe(''nldyn'',p0,u,t,x0,coe,z);')
fprintf('\n\n Press any key to continue ... '),pause,
fprintf('\n\n Starting oe.m ...')
tic,[y,p,crb,rr]=oe('nldyn',p0,u,t,x0,coe,z);toc,
%
%  Plot the results.
%
clf, title('Output-Error Parameter Estimation','FontWeight','bold'),
subplot(3,1,1),plot(t,z(:,1),t,y(:,1),'r:','LineWidth',2),grid on,ylabel('alpha  (rad)'),
legend('flight data','output-error model'),
subplot(3,1,2),plot(t,z(:,2),t,y(:,2),'r:','LineWidth',2),grid on,ylabel('q  (rps)'),
subplot(3,1,3),plot(t,z(:,3),t,y(:,3),'r:','LineWidth',2),grid on,ylabel('az  (g)'),xlabel('time (sec)'),
fprintf('\n The plots show the measured output data ')
fprintf('\n and the identified model fit. ')
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Examine the residuals.
%
clf, subplot(3,1,1),plot(t,z(:,1)-y(:,1),'LineWidth',2),grid on;ylabel('alpha residuals (rad)'),
title('Residuals','FontSize',12,'FontWeight','bold'),
subplot(3,1,2),plot(t,z(:,2)-y(:,2),'LineWidth',2),grid on;ylabel('q residuals (rps)'),
subplot(3,1,3),plot(t,z(:,3)-y(:,3),'LineWidth',2),grid on;ylabel('az residuals (g)'),xlabel('time (sec)'),
%
%  Correct the estimated parameter error bounds.
%
fprintf('\n\n The output residuals are colored ')
fprintf('\n (due to modeling error), so the ')
fprintf('\n Cramer-Rao bounds calculated by oe.m must ')
fprintf('\n be corrected for colored residuals using ')
fprintf('\n program m_colores.m:')
fprintf('\n\n [crb,crbo] = m_colores(''nldyn'',p,u,t,x0,c,z);')
fprintf('\n\n Press any key to continue ... '),pause,
fprintf('\n\n Starting m_colores.m ...\n\n')
tic,[crb,crbo] = m_colores('nldyn',p,u,t,x0,coe,z);toc,
serr=sqrt(diag(crb));
%
%  Display the parameter estimation results.
%
pnames=[pZnames([1,3,4],:);pmnames;'   azo '];
model_disp(p,serr,[],Xlab,pnames);
leglab=['Equation-Error';'Output-Error  '];
%
%  Stability derivatives.
%
indx=[1,4,5]';
plotpest([p0(indx),p(indx)],[serr0(indx),serr(indx)],[],[],cellstr(pnames(indx,:)),leglab);
title('Parameter Estimation Results','FontWeight','bold')
fprintf('\n\n The figure shows that the equation-error ')
fprintf('\n and output-error parameter estimates ')
fprintf('\n for the stability derivatives are ')
fprintf('\n in statistical agreement. ')
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Control derivatives.
%
indx=[2,6]';
plotpest([p0(indx),p(indx)],[serr0(indx),serr(indx)],[],[],pnames(indx,:),leglab);
title('Parameter Estimation Results','FontWeight','bold')
fprintf('\n\n The figure shows that the equation-error ')
fprintf('\n and output-error parameter estimates ')
fprintf('\n for Cmde are in statistical agreement, but there ')
fprintf('\n is a mismatch in the estimates of CZde. ')
fprintf('\n\n Press any key to continue ... '),pause,
save -v6 'totter_results.mat' p serr p0 serr0 pZ serrZ pm serrm coe;
%
%  Check the prediction capability.
%
load 'totter_pred_data.mat'
fprintf('\n\n Now check the prediction capability ')
fprintf('\n using data from a different maneuver ')
fprintf('\n and the identified output-error model ')
fprintf('\n from before.')
fprintf('\n\n Press any key to continue ... '),pause,
u=fdata(:,[14:16])*dtr;
z=[fdata(:,[4,6])*dtr,fdata(:,13)];
coe=nldyn_psel(fdata);
yp=nldyn(p,u,t,x0,coe);
%
%  Plot the measured inputs and outputs.
%
subplot(4,1,1), plot(t,u(:,1),'LineWidth',2), 
title('Twin Otter Flight Test Data','FontWeight','bold'),
grid on, ylabel('elevator  (rad)'), 
subplot(4,1,2), plot(t,z(:,1),'LineWidth',2), 
grid on, ylabel('alpha  (rad)'), 
subplot(4,1,3), plot(t,z(:,2),'LineWidth',2), 
grid on, ylabel('q  (rps)'), 
subplot(4,1,4), plot(t,z(:,3),'LineWidth',2), 
grid on, ylabel('az  (g)'), xlabel('time (sec)'), 
fprintf('\n\n\n The figure shows the measured input and outputs ')
fprintf('\n for the prediction maneuver. ')
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Plot the output-error prediction results.
%
title('Output-Error Prediction','FontWeight','bold'),
%
%  Correct for measurement biases.
%
bias=ones(length(t),1)\(z-yp);
yp=yp+ones(length(t),1)*bias;
subplot(3,1,1),plot(t,z(:,1)/dtr,t,yp(:,1)/dtr,'r:','LineWidth',2),grid on,ylabel('alpha  (rad)'),
legend('flight data','output-error prediction'),
title('Output-Error Model Prediction','FontWeight','bold'),
subplot(3,1,2),plot(t,z(:,2)/dtr,t,yp(:,2)/dtr,'r:','LineWidth',2),grid on,ylabel('q  (rps)'),
subplot(3,1,3),plot(t,z(:,3),t,yp(:,3),'r:','LineWidth',2),grid on,ylabel('az  (g)'),xlabel('time (sec)'),
fprintf('\n\n The plots show the measured data and the ')
fprintf('\n prediction using the output-error model ')
fprintf('\n identified using data from a different maneuver. ')
fprintf('\n The output-error model is a good predictor. ')
fprintf('\n\n\nEnd of demonstration \n\n')
return
