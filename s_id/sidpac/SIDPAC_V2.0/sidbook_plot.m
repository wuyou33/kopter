%
%  SIDBOOK_PLOT  Makes standard plots for the SIDPAC textbook.  
%
%  Usage: sidbook_plot;
%
%  Description:
%
%    Implements MATLAB graphics commands to make 
%    a standard line or surface plot for the SIDPAC textbook.
%
%  Input:
%
%    None
%
%  Output:
%
%    graphics
%
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      26 Jun 2003 - Created and debugged, EAM.
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
%  Figure setup.
%
set(gcf,'Units','normalized');
set(gcf,'Position',[0.49 0.37 0.50 0.51]);
%
%  Axes setup.
%
grid on,
set(get(gca,'Children'),'MarkerSize',9);
set(get(gca,'Children'),'LineWidth',2.0);
if ~isempty(get(gca,'ZTickLabel'))
  set(get(gca,'Children'),'EdgeColor','interp','FaceColor','interp');
end
set(gca,'Position',[0.145 0.12 0.775 0.815]);
%
%  Axis labels.
%
txlab=input('Enter the x axis label: ','s');
set(get(gca,'Xlabel'),'String',txlab,'FontSize',9,'FontWeight','bold');
tylab=input('Enter the y axis label: ','s');
set(get(gca,'Ylabel'),'String',tylab,'FontSize',9,'FontWeight','bold');
if ~isempty(get(gca,'ZTickLabel'))
  tzlab=input('Enter the z axis label: ','s');
  set(get(gca,'Zlabel'),'String',tzlab,'FontSize',9,'FontWeight','bold');
end
%
%  Figure title.
%
ttitl=input('Enter the figure title: ','s');
title(ttitl,'FontSize',10,'FontWeight','bold','FontAngle','italic');
%
%  Axis limits.
%
ans=input('Axis limits OK (y/n)? ','s');
tlim=axis;
if strcmp(ans,'n') | strcmp(ans,'N')
  txlim=input('Enter x axis limits [xlow,xhigh]: ');
  if ~isempty(txlim)
    tlim(1:2)=txlim;
    axis(tlim);
  end
  tylim=input('Enter y axis limits [ylow,yhigh]: ');
  if ~isempty(tylim)
    tlim(3:4)=tylim;
    axis(tlim);
  end
  if ~isempty(get(gca,'ZTickLabel'))
    tzlim=input('Enter z axis limits [zlow,zhigh]: ');
    if ~isempty(tzlim)
      tlim(5:6)=tzlim;
      axis(tlim);
    end
  end
end
return
