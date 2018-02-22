%
%  LON_PLOT  Makes plots of longitudinal variables.
%
%  Usage: lon_plot;
%
%  Description:
%
%    Makes standard line plots for 
%    a longitudinal flight test maneuver.
%
%  Input:
%
%    None
%
%  Output:
%
%    2D graphics
%
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      11 May 2004 - Created and debugged, EAM.
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
clf;
set(gcf,'Units','normalized');
set(gcf,'Position',[0.012, 0.055, 0.980, 0.80]);
%
%  Label font size.
%
lfs=9;
%
%  airspeed
%
subplot(3,2,2),plot(t,fdata(:,2),'LineWidth',1.5),grid on,
ylabel([fds.varlab{2},fds.varunits{2}],'FontSize',lfs),
v=get(gca,'Position');
v(1)=v(1)+0.04;
set(gca,'Position',v);
%v=axis;v(3)=0;v(4)=800;axis(v);
%ytic=get(gca,'YTickLabel');
%set(gca,'YTickLabel',ytic,'FontSize',7),
set(gca,'XTickLabel',''),
%
%  alpha
%
subplot(3,2,4),plot(t,fdata(:,4),'LineWidth',1.5),grid on,
ylabel([fds.varlab{4},fds.varunits{4}],'FontSize',lfs),
v=get(gca,'Position');
v(1)=v(1)+0.04;
set(gca,'Position',v);
%v=axis;v(3)=-10;v(4)=50;axis(v);
%set(gca,'YTick',[-10 0 10 20 30 40 50]),
set(gca,'XTickLabel',''),
%
%  q
%
subplot(3,2,6),plot(t,fdata(:,6),'LineWidth',1.5),grid on,
ylabel([fds.varlab{6},fds.varunits{6}],'FontSize',lfs),
v=get(gca,'Position');
v(1)=v(1)+0.04;
set(gca,'Position',v);
%v=axis;v(3)=-30;v(4)=30;axis(v);
%set(gca,'YTick',[-30 -20 -10 0 10 20 30]),
xlabel([fds.varlab{1},fds.varunits{1}],'FontSize',lfs),
%
%  the
%
subplot(3,2,1),plot(t,fdata(:,9),'LineWidth',1.5),grid on,
ylabel([fds.varlab{9},fds.varunits{9}],'FontSize',lfs),
%v=axis;v(3)=-60;v(4)=60;axis(v);
%set(gca,'YTick',[-60 -40 -20 0 20 40 60]),
set(gca,'XTickLabel',''),
%
%  el
%
subplot(3,2,3),plot(t,fdata(:,14),'LineWidth',1.5),grid on,
ylabel([char(fds.varlab(14)),char(fds.varunits(14))],'FontSize',lfs),
%
%  etae
%
%subplot(3,2,3),plot(t,fdata(:,31)/25.4,'LineWidth',1.5),grid on,
%ylabel('etae  (in)','FontSize',lfs),
%v=axis;v(3)=-30;v(4)=30;axis(v);
%set(gca,'YTick',[-30 -20 -10 0 10 20 30]),
set(gca,'XTickLabel',''),
%
%  az
%
subplot(3,2,5),plot(t,fdata(:,13),'LineWidth',1.5),grid on,
ylabel([fds.varlab{13},fds.varunits{13}],'FontSize',lfs),
xlabel([fds.varlab{1},fds.varunits{1}],'FontSize',lfs),
return
