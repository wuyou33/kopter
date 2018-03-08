%
%  SWR_EST  Estimate model parameters using stepwise regression.  
%
%  Calling GUI: swr_gui.m
%
%  Usage: swr_est;
%
%  Description:
%
%    Estimates stepwise regression model parameters 
%    and computes model outputs.  
%
%  Input:
%    
%    fdata = matrix of measured flight data in standard configuration.
%        t = time vector.
%
%  Output:
%
%       y = stepwise regression model output vector.
%       p = vector of parameter estimates.
%     crb = estimated parameter covariance matrix.
%      s2 = model fit error variance estimate.
%      xm = matrix of column regressors retained in the model.
%   pindx = vector of parameter vector indices for 
%           retained regressors, indicating the columns
%           of [x,ones(npts,1)] retained in the model.  
%    serr = vector of estimated parameter standard errors.  
%  xnames = names of the regressors.
%

%
%    Calls:
%      swr.m
%      sid_plot_lines.m
%      model_disp.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      05 Aug  2006 - Created and debugged, EAM.
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
%  Check to be sure that regressors and a measured output
%  have been specified.
%
if exist('X','var') & exist('Z','var') 
  fprintf('\n\n Estimating model parameters ...\n'),
  guiH=guidata(gcf);
  zcol=get(guiH.output_popup,'Value');
%
%  Use a separate figure window for the stepwise regression plots.
%
  figure('Units','normalized','Position',[0.492 0.360 0.504 0.556],...
         'NumberTitle','off','Toolbar','none');
%
%  Axes setup.
%
  set(gca,'Position',[0.160 0.12 0.775 0.815]);
%
%  Set standard appearance.
%
  sid_plot_lines,
  [y,p,crb,s2,xm,pindx]=swr(X,Z(:,zcol),1);
%
%  Turn on the output plot listbox and associated text.
%
  set(guiH.output_plot_text,'Visible','on');
  set(guiH.output_plot_popup,'Visible','on');
%
%  Plot measured and model output comparison, or residuals.
%
  if (get(guiH.output_plot_popup,'Value')==1)
    axes(guiH.axes1),
    plot(t,Z(:,zcol),t,y,'--','LineWidth',1.5),
    ylabel(Zlist(zcol)),
    legend('data','model',0),
  else
    axes(guiH.axes1),
    plot(t,Z(:,zcol)-y,'LineWidth',1.5),
    ylabel('residuals'),
  end
  xlabel([guiH.label.xp,guiH.units.xp]);
  if get(guiH.grid_radiobutton,'Value')==1
    grid on
  else
    grid off
  end
  serr=sqrt(diag(crb));
  xnames=get(guiH.regressor_listbox,'String');
  n=size(xnames,1);
  xnames=cellstr(strvcat(char(xnames),'  bias  '));
  ip=10.^[0:n]'';
  ip=ip(pindx);
  model_disp(p(pindx),serr,ip,xnames);
  mflg=2;
end
fprintf('\n\n Done\n\n');
return
