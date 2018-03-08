function [y,p,crb,s2,xm,pindx] = swr(x,z,lplot,svlim)
%
%  SWR  Stepwise regression.
%
%  Usage: [y,p,crb,s2,xm,pindx] = swr(x,z,lplot,svlim);
%
%  Description:
%
%    Computes interactive stepwise regression estimates 
%    of parameter vector p, estimated parameter covariance 
%    matrix crb, model output y, model fit error variance 
%    estimate s2, and the model regressor matrix xm, using 
%    least squares with matrix inversion based on 
%    singular value decomposition.  The output y is computed 
%    from y=xm*p(pindx).  A constant term is included 
%    automatically in the model as the last column in the 
%    model regressor matrix xm.  Optional input lplot controls 
%    plotting, and optional input svlim specifies minimum singular 
%    value ratio.  This routine works for real or complex data.  
%
%  Input:
%
%      x = matrix of column regressors.
%      z = measured output vector.
%  lplot = plot flag (optional):
%          = 0 for no plots (default)
%          = 1 for plots
%  svlim = minimum singular value ratio 
%          for matrix inversion (optional).
%
%  Output:
%
%      y = model output vector.
%      p = vector of parameter estimates.
%    crb = estimated parameter covariance matrix.
%     s2 = model fit error variance estimate.
%     xm = matrix of column regressors retained in the model.  
%  pindx = vector of parameter vector indices for 
%          retained regressors, indicating the columns
%          of [x,ones(npts,1)] retained in the model.  
%

%
%    Calls:
%      corrcoefs.m
%      lesq.m
%      regsel.m
%      pfstat.m
%      press.m
%      rms.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      21 July 1996 - Created and debugged, EAM.
%      08 Sept 2000 - Added plot option and pindx, EAM.
%      09 May  2001 - Modified plotting for complex numbers, EAM.
%      21 Sept 2004 - Cleaned up code, updated comments, EAM.
%      10 Jan  2006 - Modified for new version of press.m, EAM.
%      12 July 2006 - Added calls to corrcoefs.m, for complex data, EAM.
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
%  Initialization.
%
[npts,n]=size(x);
if nargin<4 | isempty(svlim)
  svlim=eps*npts;
end
if svlim <=0
  svlim=eps*npts;
end
if nargin<3
  lplot=0;
end
z=z(:,1);
z_rms=rms(z);
t=[1:1:npts]';
%
%  Initialization.
%
%  R squared quantities.
%
zbar=mean(z);
R2den=z'*z - npts*zbar*zbar;
R2=0.0;
%
%  Open the output file.
%
[fid,message]=fopen('swr.out','w');
if fid < 3
  message,
  return
end
%
%  F statistic value to retain a single regressor 
%  with 95 percent confidence, including a safety factor of 5.
%
%[Fm,Fv]=fstat(1,npts-2);
%Fval=5*(Fm+2*sqrt(Fv));
%
%  Conservative constant value.
%
Fval=5*4;
%
%  Parameter estimates and associated quantities.
%
y=zbar*ones(npts,1);
np=n+1;
p=zeros(np,1);
p(np)=zbar;
crb=cov(z);
s2=R2den/(npts-1);
xm=ones(npts,1);
plst=zeros(np,1);
dp=zeros(np,1);
%
%  Compute the partial correlation coefficients (parc) with z 
%  for all regressors in x.  Initialize all partial F ratios 
%  (parf) to zero.  
%
corlm=corrcoefs([x,z]);
parc=corlm([1:n],np);
parf=zeros(n,1);
%
%  Prediction error quantities.
%
sig2max=s2/2.0;
pse=(z-y)'*(z-y)/npts + 2.0*sig2max/npts;
prs=press(xm,z);
%
%  Regressor selection quantities.
%
parin=zeros(n,1);
nsp=1;
nr=0;
%
%  Stepwise regression loop starts here.
%
while nsp~=0 
  plst=p;
%
%  Plot the current modeling results.
%
  if lplot==1
    if isreal(z)
      subplot(2,1,1),plot(t,z,t,y,'--','LineWidth',1.5),
    else
      subplot(2,1,1),plot(t,abs(z),t,abs(y),'--','LineWidth',1.5),
    end
    v=get(gca,'Position');
    set(gca,'Position',v + [0.02 0 0 0]);
    title('Plots for Stepwise Regression Modeling'),
    grid on,legend('data ','model',0),
    if isreal(z)
      subplot(2,1,2),plot(t,z-y,'LineWidth',1.5),
    else
      subplot(2,1,2),plot(t,abs(z-y),'LineWidth',1.5),
    end
    v=get(gca,'Position');
    set(gca,'Position',v + [0.02 0 0 0]);
    ylabel('residual, z - y'),xlabel('index'),
    grid on,
  end
%
%  Screen output.
%
  fprintf(1,'\n                                                     Squared ');
  fprintf(1,'\n       Parameters                      F ratio      Part. Corr. \n');
  fprintf(1,'\n No.    Estimate        Change           In            Out    \n');
  fprintf(1,' ---    --------        ------           --            ---   \n');
  fprintf(fid,'\n                                                     Squared ');
  fprintf(fid,'\n       Parameters                      F ratio      Part. Corr. \n');
  fprintf(fid,'\n No.    Estimate        Change           In            Out    \n');
  fprintf(fid,' ---    --------        ------           --            ---   \n');
  for j=1:n,
%  Regressor number.
    fprintf(1,'%3.0f',j);
    fprintf(fid,'%3.0f',j);
%  Parameter estimate.
    if p(j)<0
      fprintf(1,'  %11.4e',p(j));
      fprintf(fid,'  %11.4e',p(j));
    else
      fprintf(1,'   %11.4e',p(j));
      fprintf(fid,'   %11.4e',p(j));
    end
%  Parameter estimate change.
    if dp(j)<0
      fprintf(1,'   %11.4e',dp(j));
      fprintf(fid,'   %11.4e',dp(j));
    else
      fprintf(1,'    %11.4e',dp(j));
      fprintf(fid,'    %11.4e',dp(j));
    end
%  Partial F ratios and partial correlation coefficients.
    if parin(j)~=0
      fprintf(1,'    %11.4e     %8.5f \n',parf(j),0.0);
      fprintf(fid,'    %11.4e     %8.5f \n',parf(j),0.0);
    else
      fprintf(1,'    %11.4e     %8.5f \n',0.0,parc(j)*parc(j));
      fprintf(fid,'    %11.4e     %8.5f \n',0.0,parc(j)*parc(j));
    end
  end
  fprintf(1,'\n   constant term  = %11.4e     F cut-off value = %6.2f \n',...
          p(np),Fval);
  fprintf(1,'\n\n   dependent variable rms value = %12.4e \n',z_rms);
  fprintf(1,'\n   fit error  = %13.6e  or %6.2f percent',...
          sqrt(s2),100*sqrt(s2)/rms(z));
  fprintf(1,'\n\n   R squared  = %6.2f %%        PRESS =  %9.4e',R2,prs);   
  fprintf(1,'\n                                  PSE =  %9.4e',pse);
  fprintf(fid,'\n   constant term  = %11.4e     F cut-off value = %6.2f \n',...
          p(np),Fval);
  fprintf(fid,'\n\n   dependent variable rms value = %12.4e \n',z_rms);
  fprintf(fid,'\n   fit error  = %13.6e  or %6.2f percent',...
          sqrt(s2),100*sqrt(s2)/rms(z));
  fprintf(fid,'\n\n   R squared  = %6.2f %%        PRESS =  %9.4e',R2,prs);   
  fprintf(fid,'\n                                  PSE =  %9.4e',pse);
%
%  Prompt user for more stepwise regression iterations.
%
  nsp=input('\n\n   NUMBER OF REGRESSOR TO MOVE (0 to quit) ');
%
%  Assemble the new regressor matrix.
%
  if isempty(nsp)
    nsp=0;
  else
    nsp=round(nsp);
    nsp=min(n,max(0,nsp));
  end
  fprintf(fid,'\n\n   SELECTED REGRESSOR TO MOVE = %3i',nsp);
%
%  Do calculations unless quit command was given.
%
  if nsp > 0
%
%  Selected regressor not in the current model -> put it in.
%
%    parin(x matrix regressor number) = 1 to include this regressor
%                                     = 0 to exclude this regressor
%
    if parin(nsp)==0
      parin(nsp)=1;
      nr=nr+1;
    else
%
%  Selected regressor in the current model -> take it out.
%
      parin(nsp)=0;
      nr=nr-1;
    end
  end
%
%  Assemble the regressor matrix when number of the regressors
%  in the model is positive.  The parin vector selects the 
%  regressors from the x matrix for inclusion in the current model.
%
%    parin(x matrix regressor number) = 1 to include this regressor
%                                     = 0 to exclude this regressor
%
  if nr > 0
    xm=[x(:,[find(parin==1)]),ones(npts,1)];
%
%  The number of model terms is nm.
%
    [npts,nm]=size(xm);
%
%  Least squares parameter estimation.
%
    [y,pm,crb,s2]=lesq(xm,z);
%
%  Parameter vector update.  Parameter vector length is np=n+1
%  to accomodate the constant term in the model equation. 
%  Compute partial F ratios for all regressors retained in the model.
%
    p=zeros(np,1);
%
%  Record the estimated parameter for the constant term.
%
    p(np)=pm(nm);
%
%  Reset the partial F ratios and the partial correlations.
%
    parf=zeros(n,1);
    parc=zeros(n,1);
%
%  Condition the measured output on the model regressors.
%
    zc=z-y;
    j=1;
    for i=1:n,
      if parin(i)~=0
%
%  Regressor is retained in the model -> compute partial F ratios.
%
        p(i)=pm(j);
        [xr,xj]=regsel(xm,j);
        parf(i)=pfstat(xr,xj,z);
        j=j+1;
      else
%
%  Regressor is omitted from the model -> compute partial correlation.
%
        x1=lesq(xm,x(:,i));
        xc=x(:,i)-x1;
        corlm=corrcoefs([xc,zc]);
        parc(i)=corlm(1,2);
      end
    end
    R2=100*(pm'*xm'*z - npts*zbar*zbar)/R2den;
    pse=(z-y)'*(z-y)/npts + 2.0*sig2max*(nr+1)/npts;
    prs=press(xm,z);
  else
%
%  No regressors in the model.
%
    y=zbar*ones(npts,1);
    p=zeros(np,1);
    p(np)=zbar;
    crb=cov(z);
    s2=R2den/(npts-1);
    xm=ones(npts,1);
    R2=0.0;
%
%  Compute the partial correlation coefficient with z 
%  for all regressors in x.
%
    corlm=corrcoefs([x,z]);
    parc=corlm([1:n],np);
    parf=zeros(np,1);
%
%  Compute prediction error quantities.
%
    pse=(z-y)'*(z-y)/npts + 2.0*sig2max/npts;
    prs=press(xm,z);
  end
%
%  Update the parameter change vector.
%
  dp=p-plst;
end
%
%  Find the indices of the selected parameters, 
%  and add the constant term.  
%
pindx=find(parin==1);
pindx=[pindx;np];
fclose(fid);
return
