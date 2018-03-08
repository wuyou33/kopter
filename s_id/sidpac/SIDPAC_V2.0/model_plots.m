function [merr,perr] = model_plots(x,z,p,ip,xindx,confindx,s2,pse,xlab,zlab);
%
%  MODEL_PLOTS  Makes plots for evaluating linear regression models.  
%
%  Usage: [merr,perr] = model_plots(x,z,p,ip,xindx,confindx,s2,pse,xlab,zlab);
%
%  Description:
%
%    Makes diagnostic plots for the polynomial model 
%    with structure defined by ip with parameters p.  
%
%
%  Input:
%
%         x = matrix of column vectors containing the independent variables. 
%         z = dependent variable vector.
%         p = vector of model parameters.
%        ip = vector of integer indices defining the ordinary polynomial model functions.
%     xindx = indices for the model identification points.
%  confindx = indices for the confirmation points.
%        s2 = dependent variable error variance estimate.
%       pse = predicted squared error.
%      xlab = matrix of rows containing x axis labels (optional).
%      zlab = z axis label (optional). 
%
%
%  Output:
%
%      merr = root mean square (RMS) modeling error.
%      perr = root mean square (RMS) prediction error.  
%
%      graphics:
%        2D diagnostic plots
%

%
%    Calls:
%      comfun.m
%      rms.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      04 Nov 2002 - Created and debugged, EAM.
%      05 Nov 2002 - Added modeling error and prediction error outputs, EAM.
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
figure('Units','normalized',...
       'Position',[0.473 0.027 0.521 0.903],...
       'Color',[0.8 0.8 0.8],...
       'Name','Model Diagnostic Plots',...
       'NumberTitle','off',...
       'ToolBar','none');
%
%  Supply omitted inputs, if necessary.
%
[npts,n]=size(x);
z=z(:,1);
y=comfun(x(xindx,:),p,ip);
if nargin < 10
  zlab='z ';
end
if nargin < 9
  for j=1:n
    if j==1
      xlab='x1 ';
    else
      if j < 10
        xlab=[xlab;['x',num2str(j),' ']];
      else
        xlab=[xlab;['x',num2str(j)]];
      end
    end
  end
end
%
%  Check the model fit to the data.
%
nmp=length(xindx);
indx=[1:nmp]';
subplot(2,1,1),plot(indx,z(xindx),'xr','LineWidth',1.5,'MarkerSize',8),hold on,
subplot(2,1,1),plot(indx,y),grid on,ylabel(zlab),
subplot(2,1,2),plot(indx,z(xindx)-y,'ob','LineWidth',1.5),grid on,hold on,
subplot(2,1,2),plot(indx,2*sqrt(s2)*ones(nmp,1),'r',indx,-2*sqrt(s2)*ones(nmp,1),'r'),
subplot(2,1,2),plot(indx,2*sqrt(pse)*ones(nmp,1),'g',indx,-2*sqrt(pse)*ones(nmp,1),'g'),
xlabel('Run Number'),ylabel('Residual'),hold off;
merr=rms(z(xindx)-y);
fprintf('\n\n\n Model Error RMS = %10.3e',merr),
fprintf('\n\n Percent Model Error = %10.3e',100*merr/rms(z(xindx))),
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Check the prediction errors.
%
ncp=length(confindx);
yp=comfun(x(confindx,:),p,ip);
indx=[1:ncp]';
subplot(3,1,1),plot(indx,z(confindx),'xr','LineWidth',1.5,'MarkerSize',8),hold on,
subplot(3,1,1),plot(indx,yp),grid on,ylabel('Prediction')
subplot(3,1,2),plot(indx,z(confindx)-yp,'ob','LineWidth',1.5),grid on,hold on,
subplot(3,1,2),plot(indx,2*sqrt(s2)*ones(ncp,1),'r',indx,-2*sqrt(s2)*ones(ncp,1),'r'),
subplot(3,1,2),plot(indx,2*sqrt(pse)*ones(ncp,1),'g',indx,-2*sqrt(pse)*ones(ncp,1),'g'),
ylabel('Prediction Residual')
subplot(3,1,3),plot(indx,100*(z(confindx)-yp)./rms(z),'dr','LineWidth',1.5),grid on,
xlabel('Run Number'),ylabel('Percent Prediction Error')
perr=rms(z(confindx)-yp);
fprintf('\n\n\n Prediction Error RMS = %10.3e',perr),
fprintf('\n\n Percent Prediction Error = %10.3e',100*perr/rms(z(confindx))),
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Plot the residuals versus the regressor values.
%
clf,
res=z(xindx)-y;
for j=1:n,
  subplot(n,1,j),plot(x(xindx,j),res,'o'),grid on,hold on,
  subplot(n,1,j),plot(x(xindx,j),2*sqrt(s2)*ones(nmp,1),'r')
  subplot(n,1,j),plot(x(xindx,j),-2*sqrt(s2)*ones(nmp,1),'r'),
  subplot(n,1,j),plot(x(xindx,j),2*sqrt(pse)*ones(nmp,1),'g')
  subplot(n,1,j),plot(x(xindx,j),-2*sqrt(pse)*ones(nmp,1),'g'),
  xlabel(xlab(j,:)),
  ylabel('Residual'),hold off,
end
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Check the normality of the residuals.
%
clf,
indx=[1:nmp]';
subplot(3,1,1),plot(y,res,'dr','LineWidth',1.5),grid on,
xlabel('Fitted Value'),
ylabel('Residuals'),
[res,ri]=sort(res);
prob=(indx-0.5*ones(nmp,1))/nmp;
subplot(3,1,2),plot(res,prob,'o'),grid on,
xlabel('Residuals'),
ylabel('Probability'),
subplot(3,1,3),plot(sort(z(indx)),sort(z(indx)),'r'),hold on,
legend('Ideal Model',4)
subplot(3,1,3),plot(y,z(xindx),'bd'),grid on,hold on,
xlabel('Predicted'),
ylabel('Actual'),
return
