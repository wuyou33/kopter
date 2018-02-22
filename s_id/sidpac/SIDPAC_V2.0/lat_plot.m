%
%  LAT_PLOT  Makes plots of lateral variables.
%
%  Usage: lat_plot;
%
%  Description:
%
%    Makes standard line plots for 
%    a lateral flight test maneuver.
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
%  beta
%
subplot(4,2,2),plot(t,fdata(:,3),'LineWidth',1.5),grid on,
ylabel([fds.varlab{3},fds.varunits{3}],'FontSize',lfs),
v=get(gca,'Position');
v(1)=v(1)+0.04;
set(gca,'Position',v);
v=axis;v(3)=-10;v(4)=10;axis(v);
set(gca,'XTickLabel',''),
%
%  p
%
subplot(4,2,4),plot(t,fdata(:,5),'LineWidth',1.5),grid on,
ylabel([fds.varlab{5},fds.varunits{5}],'FontSize',lfs),
v=get(gca,'Position');
v(1)=v(1)+0.04;
set(gca,'Position',v);
set(gca,'XTickLabel',''),
%
%  r
%
subplot(4,2,6),plot(t,fdata(:,7),'LineWidth',1.5),grid on,
ylabel([fds.varlab{7},fds.varunits{7}],'FontSize',lfs),
v=get(gca,'Position');
v(1)=v(1)+0.04;
set(gca,'Position',v);
set(gca,'XTickLabel',''),
%
%  phi
%
subplot(4,2,8),plot(t,fdata(:,8),'LineWidth',1.5),grid on,
ylabel([fds.varlab{8},fds.varunits{8}],'FontSize',lfs),
v=get(gca,'Position');
v(1)=v(1)+0.04;
xlabel([fds.varlab{1},fds.varunits{1}],'FontSize',lfs),
set(gca,'Position',v);
%
%  ail
%
subplot(4,2,1),plot(t,fdata(:,15),'LineWidth',1.5),grid on,
ylabel([fds.varlab{15},fds.varunits{15}],'FontSize',lfs),
set(gca,'XTickLabel',''),
%
%  rdr
%
subplot(4,2,3),plot(t,fdata(:,16),'LineWidth',1.5),grid on,
ylabel([fds.varlab{16},fds.varunits{16}],'FontSize',lfs),
set(gca,'XTickLabel',''),
%
%  ay
%
subplot(4,2,5),plot(t,fdata(:,12)-fdata(1,12),'LineWidth',1.5),grid on,
ylabel([fds.varlab{12},fds.varunits{12}],'FontSize',lfs),
%
%  Keep the original axis sizing, even with x-axis labeling.
%
v=get(gca,'Position');
xlabel([fds.varlab{1},fds.varunits{1}],'FontSize',lfs),
set(gca,'Position',v);
return
