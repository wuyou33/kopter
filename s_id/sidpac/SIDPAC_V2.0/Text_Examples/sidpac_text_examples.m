%
%  SIDPAC_TEXT_EXAMPLES  Implements textbook examples using SIDPAC.
%
%  Usage: sidpac_text_examples;
%
%  Description:
%
%    Demonstrates flight data analysis and modeling 
%    using System IDentification Programs for AirCraft (SIDPAC)
%    for the examples in the textbook entitled:
%
%    "Aircraft System Identification - Theory 
%    and Practice," by V. Klein and E.A. Morelli
%
%
%  Input:
%
%    exnum = example number in the text.  
%
%  Output:
%
%    explanatory text
%    2-D plots
%

%
%    Calls:
%      lat_plot.m
%      lon_plot.m
%      flontf.m
%      flonuatf.m
%      sid_plot_setup.m
%      sid_plot_lines.m
%      lesq.m
%      model_disp.m
%      ci.m
%      prob_plot.m
%      xcorrs.m
%      r_colores.m
%      spect.m
%      plotpest.m
%      swr.m
%      splgen.m
%      massprop.m
%      oe.m
%      m_colores.m
%      fint.m
%      zep.m
%      fdoe.m
%      tfsim.m
%      damps.m
%      rlesq.m
%      rtpid.m
%      tnlatss.m
%      compcss.m
%      tnlatss_bias.m
%      fnlatss.m
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
%  Identify which text example is to be demonstrated. 
%
exnum=input('\n Enter the text example number ');
fprintf('\n\n\b Example %2.1f \n',exnum),
if isempty(exnum)
  exnum=0;
end
exlist=[5.1,5.2,5.3,5.4,5.5,...
        6.1,6.2,6.3,...
        7.1,7.2,7.3,...
        8.1,8.2]';
if isempty(find(exlist==exnum))
  fprintf('\n\n Unrecognized example number \n\n Program exit \n\n'),
  return
end
%
%  Figure set-up.
%
sid_plot_setup;
set(gcf,'Name',['SIDPAC Example ',num2str(exnum)]),
%
%  Execute code blocks according to the example number.
%
switch exnum
%
%  Example 5.1
%
  case 5.1,
%
%  Load the data file.
%
    load 'totter_f1_017_data.mat'
%
%  Plot the measured inputs and outputs.
%
    lat_plot;
    fprintf('\n\n The figure shows measured outputs '),
    fprintf('\n and control deflections for a lateral '),
    fprintf('\n maneuver to be used for modeling. \n'),
%
%  Customize the plots.
%
    set(gcf,'Name',['SIDPAC Example ',num2str(exnum)]),
    set(get(gcf,'Children'),'XTick',[0 5 10 15 20]);
    set(gcf,'Position',[0.492 0.360 0.504 0.556]);
    set(get(gcf,'Children'),'FontSize',8);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Assemble the regressor matrix.
%
    fprintf('\n\n Assemble the matrix of regressors ')
    fprintf('\n for equation-error parameter estimation: ')
    fprintf('\n\n beta  (rad)'),
    fprintf('\n phat '),
    fprintf('\n rhat '),
    fprintf('\n ail  (rad)'),
    fprintf('\n rdr  (rad)'),
    dtr=pi/180;
    X=[fdata(:,3)*dtr,fdata(:,71),fdata(:,73),fdata(:,[15:16])*dtr];
%
%  Plot the regressors.
%
    sid_plot_setup;
    plot(t,X),
    sid_plot_lines;
    xlab=[char(fds.varlab(1)),char(fds.varunits(1))];
    xlabel(xlab),
    title('Equation-Error Regressors','FontSize',10,'FontWeight','bold','FontAngle','italic');
    legend('beta  (rad)','phat ','rhat ','ail  (rad)','rdr  (rad)');
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Linear regression for the yawing moment coefficient, Cn.
%
    fprintf('\n\n Estimate stability and control ')
    fprintf('\n derivatives for the yawing moment ')
    fprintf('\n coefficient Cn, using equation-error ')
    fprintf('\n linear regression program lesq.m. ')
%
%  Program lesq.m requires a constant regressor for the bias term.
%
    X=[X,ones(size(X,1),1)];
    CY=fdata(:,62);
    C1=fdata(:,64);
    Cn=fdata(:,66);
    [yn,pn,crbn,s2n]=lesq(X,Cn);
%
%  Plot the Cn results.
%
    plot(t,Cn)
    sid_plot_lines;
    ylabel('Cn','Rotation',0),
    xlabel(xlab),
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Model fit plot.
%
    plot(t,Cn,t,yn,'--'),
    title('Equation-Error Modeling',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
    ylabel('Cn','Rotation',0),legend('data','model'),
    sid_plot_lines,
    xlabel(xlab),
%
%  Display the results.  
%
    fprintf('\n\n Display the parameter estimation ')
    fprintf('\n results using model_disp.m:')
    serrn=sqrt(diag(crbn));
    xnames={fds.varlab(3);fds.varlab(71);fds.varlab(73);...
            fds.varlab(15);fds.varlab(16)};
    model_disp(pn,serrn,[1,10,100,1000,10000,0],xnames);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Residual plots.
%
    fprintf('\n\n The graphs show residuals plotted ')
    fprintf('\n against time (upper plot) and ')
    fprintf('\n against model Cn (lower plot). ')
    fprintf('\n The dotted lines indicate the 95 percent ')
    fprintf('\n confidence interval for prediction.  ')
%
%  Residual plot against time.  
%
    subplot(2,1,1),plot(t,Cn-yn,'b.'),grid on, hold on,
%
%  Prediction interval calculation.
%
    [syn,yln]=confin(X,Cn,pn,s2n,1,0);
%
%  Plot the 95 percent confidence interval
%  for prediction.
%
    plot(t,yln(:,1)-yn,'r--'),
    plot(t,yln(:,2)-yn,'r--'),
    hold off,
    apos=get(gca,'Position');
    apos(1)=apos(1)+0.02;
    set(gca,'Position',apos);
    sid_plot_lines,grid off,
    ylabel('residual'),
    xlabel(xlab),
%
%  Residual plot against Cn.
%
    subplot(2,1,2),plot(yn,Cn-yn,'b.'),grid on, hold on,
    npts=length(yn);
    plot([-0.015:0.03/(npts-1):0.015]',yln(:,1)-yn,'r--'),
    plot([-0.015:0.03/(npts-1):0.015]',yln(:,2)-yn,'r--'),
    hold off,
    apos=get(gca,'Position');
    apos(1)=apos(1)+0.02;
    set(gca,'Position',apos);
    sid_plot_lines,grid off,
    ylabel('residual'),
    xlabel('model Cn'),
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Residual diagnostics.
%
    fprintf('\n\n This plot is the cumulative ')
    fprintf('\n probability diagnostic plot for ')
    fprintf('\n the residuals.  A straight line ')
    fprintf('\n indicates that the residuals are ')
    fprintf('\n normally distributed. ')
%
%  Cumulative probability diagnostic plot.  
%
    clf,
    vn=Cn-yn;
    [zv,vs,cp,vsn,erfz,z] = prob_plot(vn);
    xlabel('ordered residuals'),
    sid_plot_lines,
    v=get(gca,'Position');
    v(2)=v(2)+0.02;
    v(4)=v(4)-0.02;
    set(gca,'Position',v);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Residual autocorrelation plot.
%
    fprintf('\n This graph shows the residual autocorrelation. ')
    fprintf('\n For a white noise sequence, the autocorrelation ')
    fprintf('\n should approximate a delta function at zero lag.  ')
    fprintf('\n The values at non-zero lags should be within ')
    fprintf('\n the 95 percent confidence intervals shown.  ')
    fprintf('\n Since this is not so, the residual sequence ')
    fprintf('\n is colored. ')
    [rvv,lags]=xcorrs(vn,'biased');
    lags=lags';
    srvv=(rvv(npts)/sqrt(npts))*ones(2*npts-1,1);
    plot(lags,rvv,'b.',lags,2*srvv,'r--',lags,-2*srvv,'r--'),grid on, 
    legend('autocorrelation estimates','2-sigma confidence interval'),
    ylabel('Rvv'),
    xlabel('lag index'),
%
%  Compute equation-error results for the other lateral 
%  coefficients, for later comparison with output-error results. 
%
    [yY,pY,crbY,s2Y]=lesq(X(:,[1,3,5,6]),CY);
    [crbY,crboY]=r_colores(X(:,[1,3,5,6]),CY);
    serrY=sqrt(diag(crbY));
    [y1,p1,crb1,s21]=lesq(X,C1);
    [crb1,crbo1]=r_colores(X,C1);
    serr1=sqrt(diag(crb1));
    fprintf('\n\n Press any key to continue ... '),pause,
    save -v6 'example_5p1_results.mat';
%
%  Prediction.
%
%  Load the data file.
%
    load 'totter_f1_014_data.mat'
%
%  Plot the measured inputs and outputs.
%
    lat_plot;
    fprintf('\n\n The figure shows measured outputs'),
    fprintf('\n and control deflections for a '),
    fprintf('\n prediction maneuver.  Note that '),
    fprintf('\n this maneuver has different control '),
    fprintf('\n inputs than the maneuver used for modeling. \n')
%
%  Customize the plots.
%
    set(gcf,'Name',['SIDPAC Example ',num2str(exnum)]),
    set(get(gcf,'Children'),'XTick',[0 5 10 15 20]);
    set(gcf,'Position',[0.492 0.360 0.504 0.556]);
    set(get(gcf,'Children'),'FontSize',8);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Prediction plot.
%
    npts=size(fdata,1);
    Xp=[fdata(:,3)*dtr,fdata(:,71),fdata(:,73),fdata(:,[15:16])*dtr];
%
%  Add the bias term.
%
    Xp=[Xp,ones(npts,1)];
%
%  Measured output to be predicted.  
%
    Cnp=fdata(:,66);
%
%  Compute the predicted output.
%
    ynp=Xp*pn;
%
%  Plot the prediction results.
%
    sid_plot_setup;
    plot(t,Cnp,t,ynp,'--'),
    title('Prediction',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
    ylabel('Cn','Rotation',0),legend('data','model'),
    sid_plot_lines,
    xlabel(xlab),
    fprintf('\n\n The model identified from the first '),
    fprintf('\n maneuver is used to predict the yawing moment '),
    fprintf('\n coefficient for the prediction maneuver.  '),
    fprintf('\n The figure shows that the model is a '),
    fprintf('\n good predictor. '),
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Prediction residual plots.
%
    fprintf('\n\n The graphs show prediction residuals ')
    fprintf('\n plotted against time (upper plot) and ')
    fprintf('\n against model Cn (lower plot). ')
    fprintf('\n The dotted lines indicate the 95 percent ')
    fprintf('\n confidence interval for prediction, ')
    fprintf('\n computed from the modeling data.  ')
%
%  Residual plot against time.
%
    subplot(2,1,1),plot(t,Cnp-ynp,'b.'),grid on, hold on,
%
%  Plot the 95 percent confidence interval
%  for prediction.  Use the mean value of 
%  the prediction intervals computed from
%  the modeling data. 
%
    plot(t,2*mean(syn)*ones(npts,1),'r--'),
    plot(t,-2*mean(syn)*ones(npts,1),'r--'),
    v=axis;v(3)=-0.001;v(4)=0.001;axis(v);
    hold off,
    apos=get(gca,'Position');
    apos(1)=apos(1)+0.02;
    set(gca,'Position',apos);
    sid_plot_lines,grid off,
    ylabel('residual'),
    xlabel(xlab),
%
%  Residual plot against Cn.
%
    subplot(2,1,2),plot(ynp,Cnp-ynp,'b.'),grid on, hold on,
    npts=length(ynp);
    plot([-0.015:0.03/(npts-1):0.015]',2*mean(syn)*ones(npts,1),'r--'),
    plot([-0.015:0.03/(npts-1):0.015]',-2*mean(syn)*ones(npts,1),'r--'),
    v=axis;v(3)=-0.001;v(4)=0.001;axis(v);
    hold off,
    apos=get(gca,'Position');
    apos(1)=apos(1)+0.02;
    set(gca,'Position',apos);
    sid_plot_lines,grid off,
    ylabel('residual'),
    xlabel('model Cn'),
    fprintf('\n\n Press any key to continue ... '),pause,
    save -v6 'example_5p1_prediction_results.mat';
%
%  Compare model residuals with measurement 
%  noise estimate using global Fourier smoothing.
%
    clear;
    load 'example_5p1_results.mat'
    Cns=fds.smoo.Cns; 
%
%  Plot model residuals and estimated random noise.
%
    subplot(2,1,1),plot(t,Cn-yn,'b.'),grid on, 
    apos=get(gca,'Position');
    apos(1)=apos(1)+0.02;
    set(gca,'Position',apos);
    sid_plot_lines,
    ylabel('residual'),
    subplot(2,1,2),plot(t,Cn-Cns,'b.'),grid on, 
    apos=get(gca,'Position');
    apos(1)=apos(1)+0.02;
    set(gca,'Position',apos);
    sid_plot_lines,
    ylabel('noise estimate'),
    xlabel(xlab),
    fprintf('\n\n These plots indicate that the modeling ')
    fprintf('\n residuals have approximately the same ')
    fprintf('\n magnitudes as the noise sequence ')
    fprintf('\n estimated independently using global ')
    fprintf('\n Fourier smoothing.  This suggests that ')
    fprintf('\n any unmodeled deterministic components ')
    fprintf('\n in the residuals have magnitude on the ')
    fprintf('\n order of the noise, and therefore cannot ')
    fprintf('\n be extracted.  This indicates that the ')
    fprintf('\n model is a good representation of the ')
    fprintf('\n significant relationships exhibited ')
    fprintf('\n in the data.  ')
    fprintf('\n\n End of Example 5.1 \n\n')
%
%  Example 5.2
%
  case 5.2,
%
%  Load the data file.
%
    load 'example_5p1_results.mat'
%
%  Reset example number.
%
    exnum=5.2;
%
%  Compute the model residual spectrum.
%
    w=2*pi*[0:.02:25]';
    [P,f] = spect(Cn-yn,t,w);
%
%  Plot the prediction results.
%
    sid_plot_setup;
    plot(f,P),
    title('Residual Spectrum',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
    ylabel('Cn  residual power'),
    sid_plot_lines,
    xlabel('frequency  (Hz)'),
    fprintf('\n The plot shows that most of the residual '),
    fprintf('\n power for the yawing moment coefficient model '),
    fprintf('\n lies below 4 Hz.  The residuals are therefore '),
    fprintf('\n colored, and the estimated parameter covariance '),
    fprintf('\n matrix must be corrected for this.  '),
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Compute the covariance matrix correction.
%
    [crbn,crbon,y,p,sv] = r_colores(X,Cn);
    serrn=sqrt(diag(crbn));
    serron=sqrt(diag(crbon));
    sratio=serrn./serron;
%
%  Make a plot comparing the standard errors.
%
    sid_plot_setup;
    leglab=['Conventional';'Corrected   '];
    plotpest(zeros(6,2),[serron,serrn],'','95% confidence interval',[],leglab);
    apos=get(gca,'Position');
    apos(1)=apos(1)+0.04;
    set(gca,'Position',apos);
%
%  Tick labels for the x axis.
%
    text(0.9,-0.0115,'Cn_\beta'),
    text(1.9,-0.0115,'Cn_p'),
    text(2.9,-0.0115,'Cn_r'),
    text(3.9,-0.0115,'Cn_\delta_a'),
    text(4.9,-0.0115,'Cn_\delta_r'),
    text(5.9,-0.0115,'Cn_o'),
    fprintf('\n\n The 95 percent confidence intervals '),
    fprintf('\n for conventional and corrected calculations ')
    fprintf('\n of the estimated parameter covariance matrix '),
    fprintf('\n are shown in the figure.  The parameter '),
    fprintf('\n estimates have all been set to zero so '),
    fprintf('\n that the relative size of the confidence '),
    fprintf('\n intervals is apparent. '),
    save -v6 'example_5p2_results.mat';
    fprintf('\n\n End of Example 5.2 \n\n')
%
%  Example 5.3
%
  case 5.3,
%
%  Load the data file.
%
    load 'f16_lon_001_data.mat'
%
%  Plot the measured inputs and outputs.
%
    lon_plot;
    fprintf('\n\n The figure shows measured outputs '),
    fprintf('\n and control deflections for a large-amplitude '),
    fprintf('\n longitudinal maneuver to be used for modeling. \n'),
%
%  Customize the plots.
%
    set(gcf,'Name',['SIDPAC Example ',num2str(exnum)]),
    set(gcf,'Position',[0.492 0.360 0.504 0.556]);
    set(get(gcf,'Children'),'FontSize',8);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Assemble the regressor matrix.
%
    fprintf('\n\n Assemble the pool of candidate regressors ')
    fprintf('\n for equation-error parameter estimation.  The ')
    fprintf('\n columns of the regressor matrix X are (in order):')
    fprintf('\n\n mach '),
    fprintf('\n alpha  (rad)'),
    fprintf('\n qhat '),
    fprintf('\n el  (rad)'),
    fprintf('\n alpha2  (rad2)')
    dtr=pi/180;
    X=[fdata(:,28),fdata(:,4)*dtr,fdata(:,72),fdata(:,14)*dtr];
    X=[X,X(:,2).*X(:,2)];
%
%  Plot the regressors.
%
    sid_plot_setup;
    plot(t,X),
    sid_plot_lines;
    xlab=[char(fds.varlab(1)),char(fds.varunits(1))];
    xlabel(xlab),
    title('Equation-Error Regressors','FontSize',10,'FontWeight','bold','FontAngle','italic');
    legend('mach ','alpha  (rad)','qhat ','el  (rad)','alpha2  (rad2)');
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Make the regressors perturbations about trim.
%
    fprintf('\n\n Remove the trim values from all regressors ')
    fprintf('\n to correspond with a Taylor series expansion ')
    fprintf('\n about the initial trim condition.  This also ')
    fprintf('\n de-correlates each regressor from the bias term. ')
    Xo=X;
    for j=1:size(X,2),
      X(:,j)=X(:,j)-X(1,j);
    end
%
%  Plot the perturbation regressors.
%
    sid_plot_setup;
    plot(t,X),
    sid_plot_lines;
    xlabel(xlab),
    title('Equation-Error Regressors','FontSize',10,'FontWeight','bold','FontAngle','italic');
    legend('mach ','alpha  (rad)','qhat ','el  (rad)','alpha2  (rad2)');
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Regressor cross-plots.
%
    fprintf('\n\n Use cross-plots of the explanatory variables ')
    fprintf('\n to see the coverage of the explanatory ')
    fprintf('\n variable space during the maneuver. ')
    sid_plot_setup;
    fpos=get(gcf,'Position');
    fpos(2)=fpos(2)-0.3;
    fpos(4)=fpos(4)+0.3;
    set(gcf,'Position',fpos);
%
%  alpha - qhat plot
%
    subplot(3,1,1),plot(X(:,2),X(:,3),'b.'),
    apos=get(gca,'Position');
    apos(1)=apos(1)+0.02;
    apos(2)=apos(2)+0.03;
    set(gca,'Position',apos);
    xlab=[char(fds.varlab(4)),'(rad) '];
    ylab=[char(fds.varlab(72)),' '];
    xlabel(xlab),
    ylabel(ylab),
    sid_plot_lines;
%
%  alpha - el plot
%
    subplot(3,1,2),plot(X(:,2),X(:,4),'b.'),
    apos=get(gca,'Position');
    apos(1)=apos(1)+0.02;
    set(gca,'Position',apos);
    ylab=[char(fds.varlab(14)),'(rad) '];
    xlabel(xlab),
    ylabel(ylab),
    sid_plot_lines;
%
%  qhat - el plot
%
    subplot(3,1,3),plot(X(:,3),X(:,4),'b.'),
    apos=get(gca,'Position');
    apos(1)=apos(1)+0.02;
    apos(2)=apos(2)-0.03;
    set(gca,'Position',apos);
    xlab=[char(fds.varlab(72)),' '];
    xlabel(xlab),
    ylabel(ylab),
    sid_plot_lines;
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Plot the measured body-axis Z force coefficient. 
%
    CZ=fdata(:,63);
    sid_plot_setup;
    plot(t,CZ)
    xlab=[char(fds.varlab(1)),char(fds.varunits(1))];
    xlabel(xlab),
    ylabel('CZ','Rotation',0),
    sid_plot_lines;
%
%  Stepwise regression for the body-axis Z force coefficient, CZ.
%
    fprintf('\n\n Now identify a model for the Z body-axis ')
    fprintf('\n aerodynamic force coefficient shown, ')
    fprintf('\n using equation-error stepwise regression ')
    fprintf('\n implemented in program swr.m.  In program swr.m, ')
    fprintf('\n regressors are swapped in and out of the ')
    fprintf('\n model manually by typing in the number ')
    fprintf('\n of the regressor to move in or out of ')
    fprintf('\n the model.  The regressor number ')
    fprintf('\n is the same as the column number in the X ')
    fprintf('\n matrix that holds that regressor.  To ')
    fprintf('\n duplicate the results in the text, ')
    fprintf('\n type the following numbers in order, ')
    fprintf('\n each followed by a carriage return: ')
    fprintf('\n\n 2 3 4 5 0 ')
    fprintf('\n\n The stepwise regression program swr.m ')
    fprintf('\n will be run next.  \n')
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Program swr.m operates with manual input 
%  from the analyst, and automatically includes 
%  a constant regressor for the bias term.
%
    [yZ,pZ,crbZ,s2Z,xmZ,pindxZ]=swr(X,CZ,1);
%
%  Discard the zero parameter values 
%  associated with regressors that 
%  were not selected for the model.
%
    pZ=pZ(pindxZ);
%
%  Output the final model results.
%
    fprintf('\n\n Correct the estimated parameter standard ')
    fprintf('\n errors for colored residuals, then display ')
    fprintf('\n the parameter estimation results:')
%
%  Correct the error bounds for colored residuals.
%
    [crbZ,crboZ] = r_colores(xmZ,CZ);
    serrZ=sqrt(diag(crbZ));
%
%  Names need only be given for the explanatory variables,
%  not for their nonlinear combinations.
%
    xnames={fds.varlab(28);fds.varlab(4);fds.varlab(72);fds.varlab(14)};
    if length(pZ)==5
      model_disp(pZ,serrZ,[10,100,1000,20,0],xnames);
    else
      fprintf('\n\n Estimated parameter vector: \n'),pZ,
      fprintf('\n\n Estimated parameter standard errors: \n'),serrZ,
    end
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Use a linear spline term to model the nonlinearity.
%
    fprintf('\n\n Now consider linear spline terms in ')
    fprintf('\n angle of attack to model the nonlinearity, ')
    fprintf('\n instead of the alpha squared term.  ')
    fprintf('\n Include linear spline terms in alpha ')
    fprintf('\n with knot locations at 25, 30, and 35 deg ')
    fprintf('\n in the pool of candidate regressors. ')
    fprintf('\n Stepwise regression can be used to determine ')
    fprintf('\n which (if any) of the candidate spline ')
    fprintf('\n terms would be useful in the model.  ')
    fprintf('\n The plot shows the candidate regressors. ')
    as1=splgen(X(:,2),[25,30,35]*pi/180,1);
    Xas1=[X(:,[1:4]),as1];
%
%  Plot the perturbation regressors.
%
    sid_plot_setup;
    plot(t,Xas1),
    sid_plot_lines;
    xlabel(xlab),
    title('Equation-Error Regressors','FontSize',10,'FontWeight','bold','FontAngle','italic');
    legend('mach ','alpha  (rad)','qhat ','el  (rad)','as1_2_5  (rad)','as1_3_0  (rad)','as1_3_5  (rad)');
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Stepwise regression for the body-axis Z force coefficient, CZ.
%
    fprintf('\n\n Now identify a model for the Z body-axis ')
    fprintf('\n using equation-error stepwise regression ')
    fprintf('\n with linear spline terms in alpha included ')
    fprintf('\n in the pool of the candidate regressors. ')
    fprintf('\n To duplicate the results in the text, ')
    fprintf('\n type the following numbers in order, ')
    fprintf('\n each followed by a carriage return: ')
    fprintf('\n\n 2 3 4 5 0 ')
    fprintf('\n\n The stepwise regression program swr.m ')
    fprintf('\n will be run next.  \n')
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Program swr.m operates with manual input 
%  from the analyst, and automatically includes 
%  a constant regressor for the bias term.
%
    [yZas1,pZas1,crbZas1,s2Zas1,xmZas1,pindxZas1]=swr(Xas1,CZ,1);
%
%  Discard the zero parameter values 
%  associated with regressors that 
%  were not selected for the model.
%
    pZas1=pZas1(pindxZas1);
%
%  Output the final model results.
%
    fprintf('\n\n Correct the estimated parameter standard ')
    fprintf('\n errors for colored residuals, then display ')
    fprintf('\n the parameter estimation results:')
%
%  Correct the error bounds for colored residuals.
%
    [crbZas1,crboZas1] = r_colores(xmZas1,CZ);
    serrZas1=sqrt(diag(crbZas1));
    xnames={fds.varlab(28);fds.varlab(4);fds.varlab(72);fds.varlab(14);...
            'as1_25';'as1_30';'as1_35'};
    if length(pZas1)==5,
      model_disp(pZas1,serrZas1,[10,100,1000,10000,0],xnames);
    else
      fprintf('\n\n Estimated parameter vector: \n'),pZas1,
      fprintf('\n\n Estimated parameter standard errors: \n'),serrZas1,
    end
    fprintf('\n\n The modeling results show that in this case ')
    fprintf('\n the nonlinearity in CZ can be characterized equally ')
    fprintf('\n well with a square term in alpha or a linear ')
    fprintf('\n spline term in alpha with knot located at 25 deg.  ')
    save -v6 'example_5p3_results.mat';
    fprintf('\n\n End of Example 5.3 \n\n')
%
%  Example 5.4
%
  case 5.4,
    fprintf('\n\n The data for this example is not available.')
    fprintf('\n\n End of Example 5.4 \n\n')
%
%  Example 5.5
%
  case 5.5,
    fprintf('\n\n The data for this example is not available.')
    fprintf('\n\n End of Example 5.5 \n\n')
%
%  Example 6.1
%
  case 6.1,
%
%  Load the data file.
%
    load 'example_5p1_results.mat'
%
%  Reset example number.
%
    exnum=6.1;
%
%  Plot the measured inputs and outputs.
%
    lat_plot;
    fprintf('\n\n The figure shows measured outputs '),
    fprintf('\n and control deflections for a lateral '),
    fprintf('\n maneuver to be used for modeling. \n'),
%
%  Customize the plots.
%
    set(gcf,'Name',['SIDPAC Example ',num2str(exnum)]),
    set(get(gcf,'Children'),'XTick',[0 5 10 15 20]);
    set(gcf,'Position',[0.492 0.360 0.504 0.556]);
    set(get(gcf,'Children'),'FontSize',8);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Equation-error parameter estimates are used 
%  as starting values.  
%
    fprintf('\n\n Now use output-error to estimate ')
    fprintf('\n lateral non-dimensional stability and ')
    fprintf('\n control derivatives.  Equation-error ')
    fprintf('\n parameter estimates from Example 5.1 ')
    fprintf('\n are used as starting values.  Note that ')
    fprintf('\n this is not the same as using the equation-error ')
    fprintf('\n parameter estimates as prior information.')
    fprintf('\n Perturbation quantities are used for the ')
    fprintf('\n measured inputs and outputs. ')
    fprintf('\n\n The output-error parameter estimation program oe.m ')
    fprintf('\n will be run next.  \n')
    p0=[pY;p1;pn;zeros(2,1)];
    z=[fdata(:,[3,5,7,8])*pi/180,fdata(:,12)];
    u=fdata(:,[15:16])*pi/180;
%
%  Use perturbation quantities.
%
    for j=1:size(z,2)
      z(:,j)=z(:,j)-z(1,j);
    end
    for j=1:size(u,2)
      u(:,j)=u(:,j)-u(1,j);
    end
%
%  Add a constant pseudo-input 
%  for the bias terms.
%
    u=[u,ones(size(u,1),1)];
%
%  Constants for the linear perturbation model.
%
    x0=zeros(4,1);
    clear c;
    g=32.174;
    dtr=pi/180;
    c=compcss(fdata);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Output-error parameter estimation.
%
    [y,p,crb,rr]=oe('tnlatss',p0,u,t,x0,c,z,1);
    save -v6 'example_6p1_results.mat';
%
%  Plot the measured model fit to the measured outputs.
%
    subplot(5,1,1), plot(t,z(:,1),t,y(:,1),'--','LineWidth',2), 
    title('Output-Error Modeling','FontWeight','bold'),
    legend('data','model'),
    grid on, ylabel('beta  (rad)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,2), plot(t,z(:,2),t,y(:,2),'--','LineWidth',2), 
    grid on, ylabel('p  (rps)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,3), plot(t,z(:,3),t,y(:,3),'--','LineWidth',2), 
    grid on, ylabel('r  (rps)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,4), plot(t,z(:,4),t,y(:,4),'--','LineWidth',2), 
    grid on, ylabel('phi  (rad)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,5), plot(t,z(:,5),t,y(:,5),'--','LineWidth',2), 
    grid on, ylabel('ay  (g)'), xlabel('time  (sec)'), 
    v=get(gcf,'Position');
    v(2)=v(2)-0.31;
    v(4)=v(4)+0.32;
    set(gcf,'Position',v);
    fprintf('\n\n The figure shows the model fit ')
    fprintf('\n to the measured outputs. ')
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Prediction.
%
%  Load the data file.
%
    load 'totter_f1_014_data.mat'
%
%  Plot the measured inputs and outputs.
%
    lat_plot;
    fprintf('\n\n The figure shows measured outputs'),
    fprintf('\n and control deflections for a '),
    fprintf('\n prediction maneuver.  Note that '),
    fprintf('\n this maneuver has different control '),
    fprintf('\n inputs than the maneuver used for modeling. \n')
%
%  Customize the plots.
%
    set(gcf,'Name',['SIDPAC Example ',num2str(exnum)]),
    set(get(gcf,'Children'),'XTick',[0 5 10 15 20]);
    set(gcf,'Position',[0.492 0.360 0.504 0.556]);
    set(get(gcf,'Children'),'FontSize',8);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Estimate bias parameters for the prediction. 
%
    fprintf('\n\n Now use output-error to estimate ')
    fprintf('\n bias parameters for the prediction case. ')
    fprintf('\n All other model parameters are fixed ')
    fprintf('\n at the values estimated from the ')
    fprintf('\n maneuver used for the modeling.  ')
    fprintf('\n\n The output-error parameter estimation ')
    fprintf('\n program oe.m will be run next to ')
    fprintf('\n estimate the bias parameters.  \n')
    fprintf('\n\n Press any key to continue ... '),pause,
    p0=zeros(5,1);
%
%  Assemble prediction data for use 
%  with the identified model.
%
    z=[fdata(:,[3,5,7,8])*pi/180,fdata(:,12)];
    u=fdata(:,[15:16])*pi/180;
%
%  Use perturbation quantities.
%
    for j=1:size(z,2)
      z(:,j)=z(:,j)-z(1,j);
    end
    for j=1:size(u,2)
      u(:,j)=u(:,j)-u(1,j);
    end
%
%  Add a constant pseudo-input 
%  for the bias terms.
%
    u=[u,ones(size(u,1),1)];
%
%  Constants for the linear perturbation model.
%
    x0=zeros(4,1);
    clear c;
    g=32.174;
    dtr=pi/180;
    c=compcss(fdata);
    c.pf=p([1,2,3,5,6,7,8,9,11,12,13,14,15]);
%
%  Output-error parameter estimation for the bias parameters only.  
%  The result is the predicted output.  
%
    [yp,pb,crbb,rrb]=oe('tnlatss_bias',p0,u,t,x0,c,z,1);
    save -v6 'example_6p1_prediction_results.mat';
%
%  Plot the prediction results.
%
    sid_plot_setup;
%
%  Plot the measured model fit to the measured outputs.
%
    subplot(5,1,1), plot(t,z(:,1),t,yp(:,1),'--','LineWidth',2), 
    title('Prediction',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
    legend('data','model'),
    grid on, ylabel('beta  (rad)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,2), plot(t,z(:,2),t,yp(:,2),'--','LineWidth',2), 
    grid on, ylabel('p  (rps)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,3), plot(t,z(:,3),t,yp(:,3),'--','LineWidth',2), 
    grid on, ylabel('r  (rps)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,4), plot(t,z(:,4),t,yp(:,4),'--','LineWidth',2), 
    grid on, ylabel('phi  (rad)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,5), plot(t,z(:,5),t,yp(:,5),'--','LineWidth',2), 
    grid on, ylabel('ay  (g)'), xlabel('time  (sec)'), 
    v=get(gcf,'Position');
    v(2)=v(2)-0.31;
    v(4)=v(4)+0.32;
    set(gcf,'Position',v);
    fprintf('\n\n The model identified from the first '),
    fprintf('\n maneuver is used to predict the measured '),
    fprintf('\n outputs for the prediction maneuver.  '),
    fprintf('\n The figure shows that the model is a '),
    fprintf('\n good predictor. '),
    fprintf('\n\n End of Example 6.1 \n\n')
%
%  Example 6.2
%
  case 6.2,
%
%  Load the parameter estimation results from 
%  Example 6.1, but using measured data directly, 
%  not perturbation data.
%
    load 'example_6p2_results.mat'
%
%  Reset example number.
%
    exnum=6.2;
%
%  Plot the measured inputs and outputs.
%
    lat_plot;
    fprintf('\n\n The figure shows measured outputs '),
    fprintf('\n and control deflections for a lateral '),
    fprintf('\n maneuver to be used for modeling. \n'),
%
%  Customize the plots.
%
    set(gcf,'Name',['SIDPAC Example ',num2str(exnum)]),
    set(get(gcf,'Children'),'XTick',[0 5 10 15 20]);
    set(gcf,'Position',[0.492 0.360 0.504 0.556]);
    set(get(gcf,'Children'),'FontSize',8);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Plot the measured model fit to the measured outputs.
%
    subplot(5,1,1), plot(t,zm(:,1),t,ym(:,1),'--','LineWidth',2), 
    title('Output-Error Modeling','FontWeight','bold'),
    legend('data','model'),
    grid on, ylabel('beta  (rad)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,2), plot(t,zm(:,2),t,ym(:,2),'--','LineWidth',2), 
    grid on, ylabel('p  (rps)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,3), plot(t,zm(:,3),t,ym(:,3),'--','LineWidth',2), 
    grid on, ylabel('r  (rps)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,4), plot(t,zm(:,4),t,ym(:,4),'--','LineWidth',2), 
    grid on, ylabel('phi  (rad)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,5), plot(t,zm(:,5),t,ym(:,5),'--','LineWidth',2), 
    grid on, ylabel('ay  (g)'), xlabel('time  (sec)'), 
    v=get(gcf,'Position');
    v(2)=v(2)-0.31;
    v(4)=v(4)+0.32;
    set(gcf,'Position',v);
    fprintf('\n\n Model fit to measured outputs using ')
    fprintf('\n output-error parameter estimation is ')
    fprintf('\n shown in the plots.  In this case,')
    fprintf('\n the measured input-output data are used ')
    fprintf('\n directly, i.e., the measured time series ')
    fprintf('\n are not converted to perturbations about trim.')
    fprintf('\n The estimated parameters and standard errors ')
    fprintf('\n are unaffected by this, except for the bias ')
    fprintf('\n parameters, which are different. ')
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Examine the residuals.
%
    subplot(5,1,1), plot(t,zm(:,1)-ym(:,1),'LineWidth',2), 
    title('Output-Error Residuals','FontWeight','bold'),
    grid on, ylabel('beta  (rad)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,2), plot(t,zm(:,2)-ym(:,2),'LineWidth',2), 
    grid on, ylabel('p  (rps)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,3), plot(t,zm(:,3)-ym(:,3),'LineWidth',2), 
    grid on, ylabel('r  (rps)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,4), plot(t,zm(:,4)-ym(:,4),'LineWidth',2), 
    grid on, ylabel('phi  (rad)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,5), plot(t,zm(:,5)-ym(:,5),'LineWidth',2), 
    grid on, ylabel('ay  (g)'), xlabel('time  (sec)'), 
    fprintf('\n\n The output residuals shown are colored, ')
    fprintf('\n due to modeling error, so the estimated ')
    fprintf('\n parameter error bounds must be corrected. ')
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Correct the estimated parameter error bounds.
%
    fprintf('\n\n Starting m_colores.m ...\n\n')
    tic,[crb,crbo] = m_colores('tnlatss',p,u,t,x0,c,z);toc,
    serro=sqrt(diag(crbo));
    serr=sqrt(diag(crb));
    sratio=serr./serro;
%
%  Make a plot comparing the standard errors.
%
    sid_plot_setup;
    leglab=['Equation-Error';'Output-Error  '];
%
%  CY parameters.
%
    indxe=[1,2,3]';
    indxo=[1,2,3]';
    plotpest([pY(indxe),p(indxo)],[serrn(indxe),serr(indxo)],[],[],[],leglab);
    title('Side Force Parameters','FontWeight','bold'),
    set(gcf,'Position',[0.496 0.587 0.503 0.335]);
%
%  Tick labels for the x axis.
%
    text(0.9,-1.175,'CY_\beta'),
    text(1.9,-1.175,'CY_r'),
    text(2.9,-1.175,'CY_\delta_r'),
    fprintf('\n\n Equation-error and output-error estimates ')
    fprintf('\n of side force parameters are shown, along ')
    fprintf('\n with estimates of the 95 percent confidence '),
    fprintf('\n intervals, accounting for colored residuals.  ')
    fprintf('\n The parameter estimates from the two methods ')
    fprintf('\n are in good agreement.  Rolling moment and ')
    fprintf('\n yawing moment parameter estimation results ')
    fprintf('\n will be shown next.  ')
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  C1 parameters.
%
    indxe=[1,2,3,4,5]';
    indxo=[5,6,7,8,9]';
    plotpest([p1(indxe),p(indxo)],[serr1(indxe),serr(indxo)],[],[],[],leglab);
    title('Rolling Moment Parameters','FontWeight','bold'),
    set(gcf,'Position',[0.496 0.587 0.503 0.335]);
%    set(gcf,'Position',[0.45 0.55 0.55 0.35]);
%
%  Tick labels for the x axis.
%
    text(0.9,-0.903,'Cl_\beta'),
    text(1.9,-0.903,'Cl_p'),
    text(2.9,-0.903,'Cl_r'),
    text(3.9,-0.903,'Cl_\delta_a'),
    text(4.9,-0.903,'Cl_\delta_r'),
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Cn parameters.
%
    indxe=[1,2,3,4,5]';
    indxo=[11,12,13,14,15]';
    plotpest([pn(indxe),p(indxo)],[serrn(indxe),serr(indxo)],[],[],[],leglab);
    title('Yawing Moment Parameters','FontWeight','bold'),
    set(gcf,'Position',[0.496 0.587 0.503 0.335]);
%
%  Tick labels for the x axis.
%
    text(0.9,-0.275,'Cn_\beta'),
    text(1.9,-0.275,'Cn_p'),
    text(2.9,-0.275,'Cn_r'),
    text(3.9,-0.275,'Cn_\delta_a'),
    text(4.9,-0.275,'Cn_\delta_r'),
    save -v6 'example_6p2_results.mat';
    fprintf('\n\n End of Example 6.2 \n\n')
%
%  Example 6.3
%
  case 6.3,
%
%  Load the data.
%
    load 'totter_9752ed20_data.mat'
%
%  Reset example number.
%
    exnum=6.3;
%
%  Plot the measured inputs and outputs.
%
    lon_plot;
    fprintf('\n\n The figure shows measured outputs '),
    fprintf('\n and control deflections for a longitudinal '),
    fprintf('\n maneuver to be used for modeling. \n'),
%
%  Customize the plots.
%
    set(gcf,'Name',['SIDPAC Example ',num2str(exnum)]),
    set(get(gcf,'Children'),'XTick',[0 2 4 6 8 10]);
    set(get(gcf,'Children'),'FontSize',8);
    set(gcf,'Position',[0.492 0.360 0.504 0.556]);
    subplot(3,2,3),axis([0 10 -10 5]),
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Start the parameter estimation.
%
    fprintf('\n\n Estimate dimensional stability and control ')
    fprintf('\n derivatives using equation-error. ')
    fprintf('\n\n Working ...')
%
%  Assemble the data.
%
    dtr=pi/180;
    npts=length(t);
    g=32.174;
    Vg=mean(fdata(:,2))/g;
    z=[fdata(:,13),fdata(:,43)*dtr];
    XZ=[fdata(:,[4,14])*dtr*Vg,ones(npts,1)];
    Xm=[fdata(:,[4,6,14])*dtr,ones(npts,1)];
%
%  Linear regression.
%
%  az output equation.
%
    [yZ,pZ,crbZ,s2Z]=lesq(XZ,z(:,1));
    [crbZ,crboZ]=r_colores(XZ,z(:,1));
    serrZ=sqrt(diag(crbZ));
%
%  q dynamic equation.
%
    [ym,pm,crbm,s2m]=lesq(Xm,z(:,2));
    [crbm,crbom]=r_colores(Xm,z(:,2));
    serrm=sqrt(diag(crbm));
%
%  Model fit plots.
%
    sid_plot_setup;
    subplot(2,1,1),plot(t,z(:,1),t,yZ,'--','LineWidth',2),
    title('Equation-Error Modeling',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
    ylabel('az  (g)'),legend('data','model'),
    sid_plot_lines,
    xlabel(''),
    subplot(2,1,2),plot(t,z(:,2),t,ym,'--','LineWidth',2),
    ylabel('qdot  (rps2)'),
    sid_plot_lines,
    xlab=[char(fds.varlab(1)),char(fds.varunits(1))];
    xlabel(xlab),
%
%  Display the body-axis Z parameter estimation results.  
%
    fprintf('\n\n Display the parameter estimation ')
    fprintf('\n results using model_disp.m: \n')
    xnames={fds.varlab(4);fds.varlab(6);...
            fds.varlab(14)};
    fprintf('\n\n Body-axis Z force parameters: ')
    pZnames={'Za  ';'Zde ';'Zo  '};
    model_disp(pZ,serrZ,[1,100,0],xnames,pZnames);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Display the pitching moment parameter estimation results.  
%
    fprintf('\n\n Pitching moment parameters: ')
    pmnames={'Ma  ';'Mq  ';'Mde ';'Mo  '};
    model_disp(pm,serrm,[1,10,100,0],xnames,pmnames);
%
%  Plot the parameter estimation results.
%
    xtlab=['Za ';'Zde';'Ma ';'Mq ';'Mde'];
    plotpest([[pZ([1:2]);pm(1:3)]],[[serrZ([1:3]);serrm(1:3)]],[],[],xtlab);
    title('Equation-Error Parameter Estimation',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
    save -v6 'example_6p3_results.mat';
    fprintf('\n\n End of Example 6.3 \n\n')
%
%  Example 7.1
%
  case 7.1,
%
%  Load the data file.
%
    load 'totter_f1_017_data.mat'
%
%  Plot the measured inputs and outputs.
%
    lat_plot;
    fprintf('\n\n The figure shows measured outputs '),
    fprintf('\n and control deflections for a lateral '),
    fprintf('\n maneuver to be used for modeling. \n'),
%
%  Customize the plots.
%
    set(gcf,'Name',['SIDPAC Example ',num2str(exnum)]),
    set(get(gcf,'Children'),'XTick',[0 5 10 15 20]);
    set(gcf,'Position',[0.492 0.360 0.504 0.556]);
    set(get(gcf,'Children'),'FontSize',8);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Assemble the regressor matrix.
%
    fprintf('\n\n Assemble the matrix of regressors ')
    fprintf('\n for equation-error parameter estimation ')
    fprintf('\n in the frequency domain: ')
    fprintf('\n\n beta  (rad)'),
    fprintf('\n phat '),
    fprintf('\n rhat '),
    fprintf('\n ail  (rad)'),
    fprintf('\n rdr  (rad)'),
    fprintf('\n\n frequency vector = [0.1:0.02:1.5]'' Hz')
    dtr=pi/180;
    x=[fdata(:,3)*dtr,fdata(:,71),fdata(:,73),fdata(:,[15:16])*dtr];
    f=[0.1:0.02:1.5]';
    w=2*pi*f;
    X=fint(zep(x),t,w);
%
%  Plot the regressors.
%
    sid_plot_setup;
    plot(f,abs(X)),
    sid_plot_lines;
    xlab='frequency  (Hz)';
    xlabel(xlab),
    title('Equation-Error Regressors','FontSize',10,'FontWeight','bold','FontAngle','italic');
    legend('beta  (rad)','phat ','rhat ','ail  (rad)','rdr  (rad)');
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Linear regression for the yawing moment coefficient, Cn.
%
    fprintf('\n\n Estimate stability and control ')
    fprintf('\n derivatives for the yawing moment ')
    fprintf('\n coefficient Cn, using program lesq.m ')
    fprintf('\n to implement complex linear regression ')
    fprintf('\n in the frequency domain. ')
%
%  Program lesq.m requires a constant regressor for the bias term.
%
    X=[X,ones(size(X,1),1)];
    Cn=fint(zep(fdata(:,66)),t,w);
    [yn,pn,crbn,s2n]=lesq(X,Cn);
%
%  Plot the Cn results.
%
    plot(f,abs(Cn))
    sid_plot_lines;
%     set(gcf,'Position',[0.48 0.54 0.5 0.375]),
    ylabel('Cn','Rotation',0),
    xlabel(xlab),
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Model fit plot.
%
    plot(f,abs(Cn),f,abs(yn),'--'),
    title('Equation-Error Modeling',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
    ylabel('Cn','Rotation',0),legend('data','model'),
    sid_plot_lines,
    xlabel(xlab),
%
%  Display the results.  
%
    fprintf('\n\n Display the parameter estimation ')
    fprintf('\n results using model_disp.m:')
    serrn=sqrt(diag(crbn));
    xnames={fds.varlab(3);fds.varlab(71);fds.varlab(73);...
            fds.varlab(15);fds.varlab(16)};
    pnnames={'Cnb ';'Cnp ';'Cnr ';'Cnda';'Cndr';'Cno'};
    model_disp(pn,serrn,[1,10,100,1000,10000,0],xnames,pnnames);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Compute equation-error results for the other lateral 
%  coefficients, for later comparison with output-error results. 
%
    CY=fint(zep(fdata(:,62)),t,w);
    C1=fint(zep(fdata(:,64)),t,w);
    [yY,pY,crbY,s2Y]=lesq(X(:,[1,3,5,6]),CY);
    serrY=sqrt(diag(crbY));
    [y1,p1,crb1,s21]=lesq(X,C1);
    serr1=sqrt(diag(crb1));
    save -v6 'example_7p1_ee_results.mat';
%
%  Equation-error parameter estimates are used 
%  as starting values.  
%
    fprintf('\n\n Now use output-error to estimate ')
    fprintf('\n lateral non-dimensional stability and ')
    fprintf('\n control derivatives in the frequency ')
    fprintf('\n domain.  Equation-error parameter ')
    fprintf('\n estimates are used as starting values. ')
    fprintf('\n Perturbation quantities are used ')
    fprintf('\n for the measured inputs and outputs. ')
    fprintf('\n\n The frequency-domain output-error ')
    fprintf('\n parameter estimation program fdoe.m ')
    fprintf('\n will be run next.  \n')
    p0=[pY(1:3);p1(1:5);pn(1:5)];
    z=zep([fdata(:,[3,5,7,8])*pi/180,fdata(:,12)]);
    Z=fint(z,t,w);
    u=zep(fdata(:,[15:16])*pi/180);
    U=fint(u,t,w);
%
%  Constants for the linear perturbation model.
%
    x0=zeros(4,1);
    clear c;
    g=32.174;
    dtr=pi/180;
    c=compcss(fdata);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Output-error parameter estimation.
%
    [Y,p,crb,svv]=fdoe('fnlatss',p0,U,t,w,c,Z,1);
    serr=sqrt(diag(crb));
    save -v6 'example_7p1_oe_results.mat';
%
%  Plot the measured model fit to the measured outputs.
%
    subplot(5,1,1), plot(f,abs(Z(:,1)),f,abs(Y(:,1)),'--','LineWidth',2), 
    title('Output-Error Modeling','FontWeight','bold'),
    legend('data','model'),
    grid on, ylabel('beta  (rad)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,2), plot(f,abs(Z(:,2)),f,abs(Y(:,2)),'--','LineWidth',2), 
    grid on, ylabel('p  (rps)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,3), plot(f,abs(Z(:,3)),f,abs(Y(:,3)),'--','LineWidth',2), 
    grid on, ylabel('r  (rps)'), 
    set(gca,'XTickLabel',[]);
    subplot(5,1,4), plot(f,abs(Z(:,4)),f,abs(Y(:,4)),'--','LineWidth',2), 
    grid on, ylabel('phi  (rad)'), 
    set(gca,'YTick',[0 0.25 0.5]),
    set(gca,'XTickLabel',[]);
    subplot(5,1,5), plot(f,abs(Z(:,5)),f,abs(Y(:,5)),'--','LineWidth',2), 
    grid on, ylabel('ay  (g)'), xlabel('frequency  (Hz)'), 
    v=get(gcf,'Position');
    v(2)=v(2)-0.31;
    v(4)=v(4)+0.32;
    set(gcf,'Position',v);
    fprintf('\n\n The figure shows the model fit to the ')
    fprintf('\n measured outputs in the frequency domain. ')
    fprintf('\n\n End of Example 7.1 \n\n')
%
%  Example 7.2
%
  case 7.2,
%
%  Load the data.
%
    load 'f16xl_r1263e_data.mat'
%
%  Reset example number.
%
    exnum=7.2;
%
%  Plot the measured inputs and outputs.
%
    t=dat(:,1);
    alf=dat(:,3);
    CN=dat(:,11);
    subplot(2,1,1),plot(t,alf),grid on,
    sid_plot_lines,
    title('Schroeder Sweep Forced Oscillation',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
%    ylabel('\it\alpha\rm  (deg)'),
    ylabel('alpha  (deg)'),
    subplot(2,1,2),plot(t,CN),grid on,
    sid_plot_lines,
    ylabel('CN')
    xlabel('time  (sec)')
    fprintf('\n\n The figure shows measured input and '),
    fprintf('\n output time series for a Schroeder sweep ')
    fprintf('\n forced oscillation of an F-16XL model ')
    fprintf('\n in a water tunnel. \n'),
%
%  Customize the plots.
%
    set(gcf,'Name',['SIDPAC Example ',num2str(exnum)]),
    set(get(gcf,'Children'),'FontSize',8);
    set(gcf,'Position',[0.492 0.360 0.504 0.556]);
    fprintf('\n\n Press any key to continue ... '),pause,
    fprintf('\n\n Frequency-domain equation-error ')
    fprintf('\n parameter estimation using program fdoe.m ')
    fprintf('\n will be run next, for the frequency vector ')
    fprintf('\n f=[0.008:0.002:0.2]''. \n')
    fprintf('\n\n Press any key to continue ... '),pause,
    f=[0.008:0.002:0.2]';
    w=2*pi*f;
    dtr=pi/180;
    u=detrend(alf*dtr);
    U=fint(u,t,w);
    z=detrend(CN);
    Z=fint(z,t,w);
%
%  Equation-error parameter estimation.
%
%  The commands below do equation-error
%  parameter estimation, but use the nonlinear 
%  optimizer used by the output-error method.
%  The switch between equation-error and 
%  output-error formulations is inside the 
%  model file flonuatf.m.  
%
   jw=sqrt(-1)*w;
   zr=jw.*Z;
   [yr,pe,crbe,svve] = fdoe('flonuatf',zeros(4,1),U,t,w,Z,zr);
    serre=sqrt(diag(crbe));
    sid_plot_setup;
    set(gcf,'Position',[0.49 0.42 0.50 0.49]),
    plot(f,abs(zr),f,abs(yr),'--'),grid on,
    title('Equation-Error Modeling',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
    sid_plot_lines,
    ylabel('CN'),legend('data','model',0),
    xlabel('frequency  (Hz)');
    fprintf('\n\n This figure shows model fit to the ')
    fprintf('\n data in the frequency domain using equation-error')
    fprintf('\n parameter estimation in the frequency domain.')
    fprintf('\n\n\n Next, output-error parameter estimates ')
    fprintf('\n will be computed in the frequency domain. ')
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Output-error parameter estimation.
%
    [Y,p,crb,svv] = fdoe('fusatf',zeros(4,1),U,t,w,0,Z);
    serr=sqrt(diag(crb));
    plot(f,abs(Z),f,abs(Y),'--'),grid on,
    title('Output-Error Modeling',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
    sid_plot_lines,
    ylabel('CN'),legend('data','model',0),
    xlabel('frequency  (Hz)');
    fprintf('\n\n This figure shows model fit to the ')
    fprintf('\n data in the frequency domain, using output-error')
    fprintf('\n parameter estimation in the frequency domain.\n')
    save -v6 'example_7p2_results.mat';
    fprintf('\n\n End of Example 7.2 \n\n')
%
%  Example 7.3
%
  case 7.3,
%
%  Load the data.
%
    load 'tu144_f20_4d_data.mat'
%
%  Reset example number.
%
    exnum=7.3;
%
%  Plot the measured inputs and outputs.
%
    lon_plot;
    subplot(3,2,3),plot(t,fdata(:,31)/25.4,'LineWidth',1.5),grid on,
    ylabel('etae  (in)','FontSize',lfs),
    fprintf('\n\n The figure shows measured inputs and '),
    fprintf('\n outputs for a longitudinal multi-step input '),
    fprintf('\n maneuver to be used for modeling. \n'),
%
%  Customize the plots.
%
    set(gcf,'Name',['SIDPAC Example ',num2str(exnum)]),
    set(get(gcf,'Children'),'XLim',[0 20]);
    set(get(gcf,'Children'),'XTick',[0 5 10 15 20]);
    set(get(gcf,'Children'),'FontSize',8);
    set(gcf,'Position',[0.492 0.360 0.504 0.556]);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Put data in the desired units, then 
%  zero the endpoints to get rid of bias 
%  and trend, which pollute the 
%  low frequency data in the frequency domain.  
%
    fprintf('\n\n Identify the Low Order Equivalent System (LOES) ')
    fprintf('\n model for longitudinal stick (in) to ')
    fprintf('\n pitch rate (deg/sec).  Trim values have ');
    fprintf('\n been removed for the measured input-output ')
    fprintf('\n data shown.  ')
%
%  Input is longitudinal stick in inches.
%  Data is recorded in millimeters.  
%
    u=zep(fdata(:,31)/25.4);
%
%  Output is pitch rate in deg/sec.
%
    z=zep(fdata(:,6));
%
%  Plot the measured input and output.
%
    clf,
    plot(t,z,t,u,'--');
    sid_plot_lines,
    set(gcf,'Position',[0.48 0.54 0.50 0.40]),
    xlab=[char(fds.varlab(1)),char(fds.varunits(1))];
    xlabel(xlab),
    legend('\itq\rm  (deg/sec) ','\it\eta_e\rm  (in)');
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Transform the data into the frequency domain.
%  Minimum frequency is approximately 2*pi*(2/max(t)).  
%
    w=[0.6:0.1:10]';
    f=w/(2*pi);
    jw=sqrt(-1)*w;
    Z=fint(z,t,w);
    dZ=Z.*jw;
    d2Z=dZ.*jw;
    U=fint(u,t,w);
%
%  Start the parameter estimation.
%
    fprintf('\n\n Estimate the LOES model parameters using ')
    fprintf('\n equation-error parameter estimation ')
    fprintf('\n in the frequency domain. ')
    fprintf('\n\n Working ...')
%
%  Equation-error parameter estimation.
%  No frequency scaling.
%
    p0=[0,0,0,0,0.2]';
    tic,[Y,p,crb,svv]=fdoe('flontf',p0,U,t,w,Z,d2Z);toc,
    serr=sqrt(diag(crb));
    [Y,num,den]=flontf(p,U,w,0,Z);
    tau=p(5);
    y=tfsim(num,den,tau,u,t);
    fprintf('\n\n The LOES model was identified using equation-error ')
    fprintf('\n parameter estimation in the frequency domain.  ')
    fprintf('\n The figure shows the model fit in the time domain. ')
    fprintf('\n Identified closed-loop short-period dynamics are: \n')
    damps(den);
%
%  Model fit plots.
%
    sid_plot_setup;
    plot(t,z,t,y,'--'),grid on,
    sid_plot_lines,
    set(gcf,'Position',[0.504 0.518 0.482 0.419]),
    ylabel('q  (deg/sec)'),legend('data','model'),
    xlabel('time  (sec)');
    title('Frequency-Domain Equation-Error Modeling',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Output-error parameter estimation.
%
    fprintf('\n\n Now estimate the LOES model using ')
    fprintf('\n output-error parameter estimation ')
    fprintf('\n in the frequency domain, with equation-error ')
    fprintf('\n parameter estimates as starting values. ')
    fprintf('\n\n Press any key to continue ... '),pause,
    fprintf('\n\n Working ...')
    [Yo,po,crbo,svvo]=fdoe('flontf',p,U,t,w,c,Z);
    serro=sqrt(diag(crbo));
    [Yo,numo,deno]=flontf(po,U,w,0,0);
    tauo=po(5);
    yo=tfsim(numo,deno,tauo,u,t);
    fprintf('\n\n The figure shows the model fit in both ')
    fprintf('\n the time domain and the frequency domain.  ')
    fprintf('\n Identified closed-loop short-period dynamics are: \n')
    damps(deno);
%
%  Model fit plots.
%
    sid_plot_setup;
    subplot(2,1,1),plot(f,abs(Z),f,abs(Yo),'--'),grid on,
    title('Frequency-Domain Output-Error Modeling',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
    legend('data','model'),
    sid_plot_lines,
    xlabel('frequency  (Hz)');
    subplot(2,1,2),plot(t,z,t,yo,'--'),grid on,
    sid_plot_lines,
    ylabel('q  (deg/sec)'),
    xlabel(xlab),
    save -v6 'example_7p3_results.mat';
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Prediction.
%
%  Load the data file.
%
    load 'tu144_f20_4f_pred_data.mat'
    fdata=fdata_f20_4f;
    t=t_f20_4f;
%
%  Plot the measured inputs and outputs.
%
    lon_plot;
    subplot(3,2,3),plot(t,fdata(:,31)/25.4,'LineWidth',1.5),grid on,
    ylabel('etae  (in)','FontSize',lfs),
    fprintf('\n\n The figure shows measured input-output '),
    fprintf('\n data for a prediction maneuver.  Note that '),
    fprintf('\n this maneuver has different polarity '),
    fprintf('\n for the input, compared to the maneuver ')
    fprintf('\n used for the modeling. \n')
%
%  Customize the plots.
%
    set(gcf,'Name',['SIDPAC Example ',num2str(exnum)]),
    set(get(gcf,'Children'),'XLim',[0 20]);
    set(get(gcf,'Children'),'XTick',[0 5 10 15 20]);
    set(get(gcf,'Children'),'FontSize',8);
    set(gcf,'Position',[0.492 0.360 0.504 0.556]);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Prediction using frequency-domain output-error results.  
%
    yp=tfsim(numo,deno,tauo,up,tp);
%
%  Plot the prediction results.
%
    sid_plot_setup;
    set(gcf,'Position',[0.48 0.40 0.5 0.45]),
    plot(tp,zp,tp,yp,'--'),
    title('Prediction',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
    ylabel('q  (deg/sec)'),legend('data','model'),
    sid_plot_lines,
    xlabel(xlab),
    fprintf('\n\n The LOES model identified from the first '),
    fprintf('\n maneuver is used to predict the pitch rate '),
    fprintf('\n for the prediction maneuver.  The figure '),
    fprintf('\n shows that the model is a good predictor. '),
    fprintf('\n Note that some high-order effects cannot '),
    fprintf('\n be captured by this low-order model.  '),
    save -v6 'example_7p3_prediction_results.mat';
    fprintf('\n\n End of Example 7.3 \n\n')
%
%  Example 8.1
%
  case 8.1,
%
%  Load the data file.
%
    load 'example_5p1_results.mat';
%
%  Reset example number.
%
    exnum=8.1;
%
%  Plot the measured inputs and outputs.
%
    lat_plot;
    fprintf('\n\n The figure shows measured outputs '),
    fprintf('\n and control deflections for a lateral '),
    fprintf('\n maneuver to be used for modeling. \n'),
%
%  Customize the plots.
%
    set(gcf,'Name',['SIDPAC Example ',num2str(exnum)]),
    set(get(gcf,'Children'),'XTick',[0 5 10 15 20]);
    set(gcf,'Position',[0.492 0.360 0.504 0.556]);
    set(get(gcf,'Children'),'FontSize',8);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Assemble the regressor matrix.
%
    dtr=pi/180;
    X=[fdata(:,3)*dtr,fdata(:,71),fdata(:,73),fdata(:,[15:16])*dtr,ones(size(fdata,1),1)];
    xlab=[char(fds.varlab(1)),char(fds.varunits(1))];
    xlabel(xlab),
%
%  Linear regression for the yawing moment coefficient, Cn.
%
    fprintf('\n\n Estimate stability and control ')
    fprintf('\n derivatives for the yawing moment ')
    fprintf('\n coefficient Cn, using recursive ')
    fprintf('\n least squares program rlesq.m.  ')
    Cn=fdata(:,66);
%
%  Plot the Cn results.
%
    sid_plot_setup,
    plot(t,Cn),
    sid_plot_lines;
    ylabel('Cn','Rotation',0),
    xlabel(xlab),
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Recursive least squares parameter estimation.
%
    [y,p,crb,s2,ph,crbh,s2h,seh,kh]=rlesq(X,Cn);
%
%  Display the results.  
%
    fprintf('\n\n Time histories of the parameter ')
    fprintf('\n estimates are shown in the figure. ')
    fprintf('\n The X at the right of each plot ')
    fprintf('\n indicates the batch estimate. ')
%  Cn_beta
    subplot(3,2,1),plot(t,ph(:,1),t(npts),pn(1),'rx'),sid_plot_lines,
    v=get(gca,'Position');v(1)=v(1)+0.01;set(gca,'Position',v);
    sid_plot_lines,
    ylabel('Cn_\beta','Rotation',0),
%  Cn_p
    subplot(3,2,2),plot(t,ph(:,2),t(npts),pn(2),'rx'),sid_plot_lines,
    v=get(gca,'Position');v(1)=v(1)+0.05;set(gca,'Position',v);
    sid_plot_lines,
    ylabel('Cn_p','Rotation',0),
%  Cn_r
    subplot(3,2,3),plot(t,ph(:,3),t(npts),pn(3),'rx'),sid_plot_lines,
    v=get(gca,'Position');v(1)=v(1)+0.01;set(gca,'Position',v);
    sid_plot_lines,
    ylabel('Cn_r','Rotation',0),
%  Cn_da
    subplot(3,2,4),plot(t,ph(:,4),t(npts),pn(4),'rx'),sid_plot_lines,
    v=get(gca,'Position');v(1)=v(1)+0.05;set(gca,'Position',v);
    sid_plot_lines,
    ylabel('Cn_\delta_a','Rotation',0),
%  Cn_dr
    subplot(3,2,5),plot(t,ph(:,5),t(npts),pn(5),'rx'),sid_plot_lines,
    v=get(gca,'Position');v(1)=v(1)+0.01;set(gca,'Position',v);
    sid_plot_lines,
    ylabel('Cn_\delta_r','Rotation',0),
    xlabel('time  (sec)'),
%  Cn_o
    subplot(3,2,6),plot(t,ph(:,6),t(npts),pn(6),'rx'),sid_plot_lines,
    v=get(gca,'Position');v(1)=v(1)+0.05;set(gca,'Position',v);
    sid_plot_lines,
    ylabel('Cn_o','Rotation',0),
    xlabel('time  (sec)'),
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Model fit plot.
%
    fprintf('\n\n The final parameter estimates are ')
    fprintf('\n the same as the batch least squares ')
    fprintf('\n estimates, so the model fit to Cn ')
    fprintf('\n is excellent using the final estimates ')
    fprintf('\n from recursive least squares. ')
    sid_plot_setup,
    plot(t,Cn,t,y,'r:'),
    title('Recursive Equation-Error Parameter Estimation',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
    ylabel('Cn','Rotation',0),legend('data','model'),
    sid_plot_lines,
    xlabel(xlab),
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Control derivative plots, with corresponding regressors.
%
    fprintf('\n\n The graphs show the time histories of')
    fprintf('\n the control derivatives on the same plot with')
    fprintf('\n the corresponding control surface deflection. ')
    fprintf('\n Note that the control derivative estimate ')
    fprintf('\n does not stabilize to an accurate value ')
    fprintf('\n until the corresponding control surface ')
    fprintf('\n moves substantially.  After that, the ')
    fprintf('\n estimator has enough information to compute ')
    fprintf('\n accurate estimates. ')
%
%  Control derivative plots.
%
    sid_plot_setup,
    plot(t,X(:,5),t,ph(:,5),':'),
    legend('rudder  (rad)','Cn_\delta_r'),
    sid_plot_lines,xlabel(xlab),grid off,
    set(gcf,'Position',[0.506 0.465 0.491 0.471]);
    fprintf('\n\n Press any key to continue ... '),pause,
    plot(t,X(:,4),t,ph(:,4),':'),
    legend('aileron  (rad)','Cn_\delta_a'),
    sid_plot_lines, xlabel(xlab),grid off,
    save -v6 'example_8p1_results.mat';
    fprintf('\n\n End of Example 8.1 \n\n')
%
%  Example 8.2
%
  case 8.2,
%
%  Load the data file.
%
    load 'example_5p1_results.mat'
%
%  Reset example number.
%
    exnum=8.2;
%
%  Plot the measured inputs and outputs.
%
    lat_plot;
    fprintf('\n\n The figure shows measured outputs '),
    fprintf('\n and control deflections for a lateral '),
    fprintf('\n maneuver to be used for modeling. \n'),
%
%  Customize the plots.
%
    exnum=8.2;
    set(gcf,'Name',['SIDPAC Example ',num2str(exnum)]),
    set(get(gcf,'Children'),'XTick',[0 5 10 15 20]);
    set(gcf,'Position',[0.492 0.360 0.504 0.556]);
    set(get(gcf,'Children'),'FontSize',8);
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Assemble the regressor matrix.
%
    dtr=pi/180;
    X=[fdata(:,3)*dtr,fdata(:,71),fdata(:,73),fdata(:,[15:16])*dtr,ones(size(fdata,1),1)];
    xlab=[char(fds.varlab(1)),char(fds.varunits(1))];
    xlabel(xlab),
%
%  Linear regression for the yawing moment coefficient, Cn.
%
    fprintf('\n\n Estimate stability and control ')
    fprintf('\n derivatives for the yawing moment ')
    fprintf('\n coefficient Cn, using sequential')
    fprintf('\n least squares in the frequency domain, ')
    fprintf('\n implemented in program rtpid.m.  ')
    Cn=fdata(:,66);
%
%  Plot the Cn results.
%
    sid_plot_setup,
    plot(t,Cn),
    sid_plot_lines;
    ylabel('Cn','Rotation',0),
    xlabel(xlab),
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Sequential least squares parameter estimation
%  in the frequency domain.  The bias term in the 
%  time-domain regressor matrix is omitted for 
%  analysis in the frequency domain.  
%
    f=[0.1:0.04:1.5]';
    w=2*pi*f;
    x=X(:,[1:5]);
    [y,p,crb,s2,ph,th,seh,s2h,Xh,Zh,f] = rtpid(x,Cn,t,w);
%
%  Display the results.  
%
    set(gcf,'Position',[0.494 0.055 0.500 0.870]);
    n=length(th);
    fprintf('\n\n Time histories of the parameter ')
    fprintf('\n estimates are shown in the figure. ')
    fprintf('\n The X at the right of each plot ')
    fprintf('\n indicates the time-domain batch estimate. ')
%
%  Cn_beta
%
    subplot(5,1,1),
    plot(th,ph(:,1),'bd','MarkerSize',5,'MarkerFaceColor','b'),
    grid on, hold on,set(gca,'XTickLabel','');
    for i=1:n,
      plot([th(i);th(i)],[ph(i,1)+2*seh(i,1);ph(i,1)-2*seh(i,1)],'r','LineWidth',1.5),
    end
    v=get(gca,'Position');v(1)=v(1)+0.05;set(gca,'Position',v);    
    plot(th(n),pn(1),'rx','MarkerSize',8,'LineWidth',1.5),hold off,
    ylabel('Cn_\beta','Rotation',0),
    v=get(get(gca,'YLabel'),'Position');
    v(1)=v(1)-1;
    set(get(gca,'Ylabel'),'Position',v);
%
%  Cn_p
%
    subplot(5,1,2),
    plot(th,ph(:,2),'bd','MarkerSize',5,'MarkerFaceColor','b'),
    grid on, hold on,set(gca,'XTickLabel','');
    for i=1:n,
      plot([th(i);th(i)],[ph(i,2)+2*seh(i,2);ph(i,2)-2*seh(i,2)],'r','LineWidth',1.5),
    end
    v=get(gca,'Position');v(1)=v(1)+0.05;set(gca,'Position',v);
    plot(th(n),pn(2),'rx','MarkerSize',8,'LineWidth',1.5),hold off,
    ylabel('Cn_p','Rotation',0),
    v=get(get(gca,'YLabel'),'Position');
    v(1)=v(1)-1.5;
    set(get(gca,'Ylabel'),'Position',v);
%
%  Cn_r
%
    subplot(5,1,3),
    plot(th,ph(:,3),'bd','MarkerSize',5,'MarkerFaceColor','b'),
    grid on, hold on,set(gca,'XTickLabel','');
    for i=1:n,
      plot([th(i);th(i)],[ph(i,3)+2*seh(i,3);ph(i,3)-2*seh(i,3)],'r','LineWidth',1.5),
    end
    v=get(gca,'Position');v(1)=v(1)+0.05;set(gca,'Position',v);
    plot(th(n),pn(3),'rx','MarkerSize',8,'LineWidth',1.5),hold off,
    ylabel('Cn_r','Rotation',0),
    v=get(get(gca,'YLabel'),'Position');
    v(1)=v(1)-1;
    set(get(gca,'Ylabel'),'Position',v);
%
%  Cn_da
%
    subplot(5,1,4),
    plot(th,ph(:,4),'bd','MarkerSize',5,'MarkerFaceColor','b'),
    grid on, hold on,set(gca,'XTickLabel','');
    for i=1:n,
      plot([th(i);th(i)],[ph(i,4)+2*seh(i,4);ph(i,4)-2*seh(i,4)],'r','LineWidth',1.5),
    end
    v=get(gca,'Position');v(1)=v(1)+0.05;set(gca,'Position',v);
    plot(th(n),pn(4),'rx','MarkerSize',8,'LineWidth',1.5),hold off,
    ylabel('Cn_\delta_a','Rotation',0),
    v=get(get(gca,'YLabel'),'Position');
    v(1)=v(1)-1;
    set(get(gca,'Ylabel'),'Position',v);
%
%  Cn_dr
%
    subplot(5,1,5),
    plot(th,ph(:,5),'bd','MarkerSize',5,'MarkerFaceColor','b'),
    grid on, hold on,
    for i=1:n,
      plot([th(i);th(i)],[ph(i,5)+2*seh(i,5);ph(i,5)-2*seh(i,5)],'r','LineWidth',1.5),
    end
    v=get(gca,'Position');v(1)=v(1)+0.05;set(gca,'Position',v);
    plot(th(n),pn(5),'rx','MarkerSize',8,'LineWidth',1.5),hold off,
    ylabel('Cn_\delta_r','Rotation',0),
    v=get(get(gca,'YLabel'),'Position');
    v(1)=v(1)-1;
    set(get(gca,'Ylabel'),'Position',v);
    xlabel(xlab),
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Control derivative plots, with corresponding regressors.
%
    fprintf('\n\n The graphs show the time histories of')
    fprintf('\n the control derivatives on the same plot with')
    fprintf('\n the corresponding control surface deflection. ')
    fprintf('\n Note that the control derivative estimate ')
    fprintf('\n does not stabilize to an accurate value ')
    fprintf('\n until the corresponding control surface ')
    fprintf('\n moves substantially.  After that, the ')
    fprintf('\n estimator has enough information to compute ')
    fprintf('\n accurate estimates. ')
%
%  Control derivative plots.
%
%  Cn_dr
%
    sid_plot_setup,
    plot(t,x(:,5)), sid_plot_lines, hold on, grid on,
    set(gcf,'Position',[0.506 0.465 0.491 0.471]);
    plot(th,ph(:,5),'bd','MarkerSize',5,'MarkerFaceColor','b'),
    for i=1:n,
      plot([th(i);th(i)],[ph(i,5)+2*seh(i,5);ph(i,5)-2*seh(i,5)],'r','LineWidth',1.5),
    end
    plot(th(n),pn(5),'rx','MarkerSize',8,'LineWidth',1.5),hold off,
    legend('rudder  (rad)','Cn_\delta_r'),
    xlabel(xlab),
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Cn_da
%
    sid_plot_setup,
    plot(t,x(:,4)), sid_plot_lines, hold on, grid on,
    set(gcf,'Position',[0.506 0.465 0.491 0.471]);
    plot(th,ph(:,4),'bd','MarkerSize',5,'MarkerFaceColor','b'),
    for i=1:n,
      plot([th(i);th(i)],[ph(i,4)+2*seh(i,4);ph(i,4)-2*seh(i,4)],'r','LineWidth',1.5),
    end
    plot(th(n),pn(4),'rx','MarkerSize',8,'LineWidth',1.5),hold off,
    legend('aileron  (rad)','Cn_\delta_a'),
    xlabel(xlab),
    fprintf('\n\n Press any key to continue ... '),pause,
%
%  Model fit plot.
%
    fprintf('\n\n The final parameter estimates are ')
    fprintf('\n nearly the same as the batch least squares ')
    fprintf('\n estimates in the time domain, so the ')
    fprintf('\n model fit to Cn is excellent using the ')
    fprintf('\n final estimates from sequential least squares ')
    fprintf('\n in the frequency domain.  Note that there is a ')
    fprintf('\n slight drift of the model compared to Cn data. ')
    fprintf('\n This occurs because the drift in the regressors ')
    fprintf('\n and measured output is omitted in the ')
    fprintf('\n frequency-domain modeling.  The drift is a ')
    fprintf('\n low-frequency component in the data, ')
    fprintf('\n which is not included in the Fourier transforms')
    fprintf('\n of the measured time-domain data.')
    sid_plot_setup,
    plot(t,Cn,t,y,'r:'),
    title('Sequential Equation-Error Parameter Estimation',...
          'FontSize',10,'FontWeight','bold','FontAngle','italic');
    ylabel('Cn','Rotation',0),legend('data','model'),
    sid_plot_lines,
    xlabel(xlab),
    save -v6 'example_8p2_results.mat';
    fprintf('\n\n End of Example 8.2 \n\n')
end
return
