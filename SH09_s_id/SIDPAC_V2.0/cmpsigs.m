function xs = cmpsigs(t,x,lplot)
%
%  CMPSIGS  Signal comparision excluding biases and scaling.
%
%  Usage: xs = cmpsigs(t,x,lplot);
%
%  Description:
%
%    Draws a plot comparing the column vectors in x, 
%    where each column has bias removed and is scaled so that  
%    the waveform information can be directly compared.  
%    Scaling is done relative to the signal 
%    in the first column of x, and the scaled vectors 
%    are output as xs.  
%
%  Input:
%
%      t = time vector.
%      x = matrix of column vectors to be plotted and compared.
%  lplot = plot flag (optional):
%          = 0 for no plot
%          = 1 for plot (default)
%
%  Output:
%
%    xs = scaled matrix of column vectors to be plotted and compared.
%
%    graphics:
%      comparison plot
%

%
%    Calls:
%      rms.m
%      sid_plot_setup.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      9 Apr  1995 - Created and debugged, EAM.
%     12 Nov  2005 - Added zs output, EAM.
%     28 Dec  2005 - Added plot option, EAM.
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
t=t(:,1);
npts=length(t);
[m,n]=size(x);
if m~=npts
  fprintf('\n Vector length mismatch \n\n');
end
if nargin < 3
  lplot=1;
end
xz=x-ones(npts,1)*x(1,:);
xsize=rms(xz);
%
%  If any signal is a constant, 
%  modify the scaling to avoid divide by zero.
%
zindx=find(xsize==0);
if ~isempty(zindx)
  xsize(zindx)=ones(1,length(zindx));
end
%
%  Scale all signals to roughly 
%  the magnitude of the first signal. 
%
xscale=ones(1,n)./(xsize/xsize(1)),
xs=xz.*(ones(npts,1)*xscale);
if lplot==1
  sid_plot_setup,
  plot(t,xs)
  title('Comparison plot')
  grid on;
  xlabel('time (sec)');
end
return
