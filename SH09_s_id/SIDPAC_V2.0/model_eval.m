function [merr,perr] = model_eval(x,z,p,ip,xindx,confindx,cindx,s2,pse,xlab,zlab);
%
%  MODEL_EVAL  Makes plots and computes diagnostics for evaluating linear regression models.  
%
%  Usage: [merr,perr] = model_eval(x,z,p,ip,xindx,confindx,cindx,s2,pse,xlab,zlab);
%
%  Description:
%
%    Makes diagnostic evaluation of the polynomial model 
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
%     cindx = indices for the center points.
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
%      misvd.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      22 Dec 2002 - Created and debugged, EAM.
%      02 Feb 2005 - Added comparison of model fit error
%                    with random error, EAM.
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
%  Plot the studentized model residuals versus the regressor values.
%
clf,
np=length(ip);
H=x(xindx,:)*misvd(x(xindx,:)'*x(xindx,:))*x(xindx,:)';
hd=diag(H);
res=z(xindx)-y;
%
%  Compute output variance using external scaling.
%
s2m=(z(xindx)-y)'*(z(xindx)-y)/(nmp-np);
s2x=((nmp-np)*s2m*ones(nmp,1)-((res.*res)./(ones(nmp,1)-hd)))/(nmp-np-1);
stdres=res./sqrt(s2x.*(ones(nmp,1)-hd));
for j=1:n,
  subplot(n,1,j),plot(x(xindx,j),stdres,'o'),grid on,hold on,
  if j==1
    title('Studentized Model Residual Plots',...
          'FontSize',12,'FontWeight','bold','FontAngle','italic'),
  end
  subplot(n,1,j),plot(x(xindx,j),3*ones(nmp,1),'r'),
  subplot(n,1,j),plot(x(xindx,j),-3*ones(nmp,1),'r'),
  subplot(n,1,j),plot(x(xindx,j),2*ones(nmp,1),'g'),
  subplot(n,1,j),plot(x(xindx,j),-2*ones(nmp,1),'g'),
  xlabel(xlab(j,:)),hold off,
end
%
%  Find and report model outliers identified using 
%  the studentized residuals. 
%
mindx=find(abs(stdres) > 3);
if ~isempty(mindx)
  fprintf('\n\n\n Model Outlier Report: \n')
  fprintf('\n Run    Std. Res ')
  for k=1:n,
    fprintf(['   ',xlab(k,:),'  ']),
  end
  for j=1:length(mindx),
    fprintf('\n %3i    %6.2f',xindx(mindx(j)),stdres(mindx(j))),
    for k=1:n,
      fprintf('   %7.2f',x(xindx(mindx(j)),k)),
    end
  end
end
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Plot the studentized prediction residuals versus the regressor values.
%
clf,
Hp=x(confindx,:)*misvd(x(confindx,:)'*x(confindx,:))*x(confindx,:)';
resp=z(confindx)-yp;
stdresp=resp./sqrt(s2m*(ones(ncp,1)-diag(Hp)));
for j=1:n,
  subplot(n,1,j),plot(x(confindx,j),stdresp,'o'),grid on,hold on,
  if j==1
    title('Studentized Prediction Residual Plots',...
          'FontSize',12,'FontWeight','bold','FontAngle','italic'),
  end
  subplot(n,1,j),plot(x(confindx,j),3*ones(ncp,1),'r'),
  subplot(n,1,j),plot(x(confindx,j),-3*ones(ncp,1),'r'),
  subplot(n,1,j),plot(x(confindx,j),2*ones(ncp,1),'g'),
  subplot(n,1,j),plot(x(confindx,j),-2*ones(ncp,1),'g'),
  xlabel(xlab(j,:)),hold off,
end
%
%  Find and report prediction outliers identified using 
%  the studentized residuals. 
%
pindx=find(abs(stdresp) > 3);
if ~isempty(pindx)
  fprintf('\n\n\n Prediction Outlier Report: \n')
  fprintf('\n Run    Std. Res ')
  for k=1:n,
    fprintf(['   ',xlab(k,:),'  ']),
  end
  for j=1:length(pindx),
    fprintf('\n %3i    %6.2f',confindx(pindx(j)),stdresp(pindx(j))),
    for k=1:n,
      fprintf('   %7.2f',x(confindx(pindx(j)),k)),
    end
  end
end
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Plot leverage.  
%
clf,
np=length(ip);
lev=diag(H);
plot([1:nmp]',lev,'o','LineWidth',1.5,'MarkerSize',8),grid on,hold on,
title('Leverage Plot',...
      'FontSize',12,'FontWeight','bold','FontAngle','italic'),
plot([1:nmp]',(2*np/nmp)*ones(nmp,1),'r'),
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Plot Cook's distances.  
%
clf,
d=((stdres.*stdres)/np).*(diag(H)./(ones(nmp,1)-diag(H)));
plot([1:nmp]',d,'rd','LineWidth',1.5,'MarkerSize',8),grid on,
title('Cook''s Distance',...
      'FontSize',12,'FontWeight','bold','FontAngle','italic'),
fprintf('\n\n Press any key to continue ... '),pause,
%
%  Plot the PRESS residual inflation factors.
%
clf,
pressfac=ones(nmp,1)./(ones(nmp,1)-hd);
for j=1:n,
  subplot(n,1,j),plot(x(xindx,j),pressfac,'o'),grid on,hold on,
  if j==1
    title('PRESS Residual Inflation Factors',...
          'FontSize',12,'FontWeight','bold','FontAngle','italic'),
  end
  xlabel(xlab(j,:)),hold off,
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
fprintf('\n\n Press any key to continue ... '),pause,
close,
%
%  Compute and output R squared values.  
%
z2=z(xindx)'*z(xindx);
SSr=y'*z(xindx) - sum(z(xindx))*sum(z(xindx))/nmp;
SSe=(z(xindx)-y)'*(z(xindx)-y);
SSt=z2-sum(z(xindx))*sum(z(xindx))/nmp;
R2=(1-SSe/SSt);
fprintf('\n\n\n R squared = %5.2f percent \n',100*R2),
R2adj=1-((nmp-1)/(nmp-np))*(1-R2);
fprintf('\n Adjusted R squared = %5.2f percent \n',100*R2adj),
%
%  Compare model fit error with an estimate 
%  of the random error.  
%
fprintf('\n\n model rms fit error = %9.3e \n',rms(z(xindx)-y)),
fprintf('\n random error 2-sigma bound = %9.3e \n\n',2*sqrt(s2)),
return
