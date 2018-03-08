function [fdata,t] = fixdrop(to,fdatao)
%
%  FIXDROP  Interpolates to repair data dropouts, using a graphical interface.  
%
%  Usage: [fdata,t] = fixdrop(to,fdatao);
%
%  Description:
%
%    Repairs data dropouts identified in the flight
%    data matrix fdatao, according to user input.  
%    The input can also be individual columns
%    in the fdatao matrix, to limit the interpolation
%    to only the specified columns.  
%
%  Input:
%    
%    fdatao = flight data array in standard configuration, 
%             or specific columns in the fdatao array.
%        to = time vector corresponding to fdatao.
%
%  Output:
%
%    fdata = flight data array with data dropouts repaired, 
%            or specific repaired columns from the fdatao array.
%        t = time vector corresponding to fdata.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      06 Aug  1999 - Created and debugged, EAM.
%      29 Mar  2006 - Added input to, made applicable to any size fdatao, EAM.
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
[npts,n]=size(fdatao);
t=to-to(1);
dt=1/round(1/(t(2)-t(1)));
time=[0:dt:max(t)]';
if length(time)~=length(t)
  fprintf('\n\n Irregularity in input time to \n\n');
  fdata=[];
  t=[];
  return
end
t=time;
fdata=fdatao;
jplt=1;
j=jplt;
while j >= 0,
  while j > 0 & j <=n,
    plot(t,fdata(:,j));grid on;
    xlabel('time  (sec)');ylabel(['channel ',num2str(j)]);
    title(['Maneuver length = ',num2str(max(t)-min(t)),' sec']);
    zoom on;
    fprintf('\n\nZoom is ON, click plot to find dropout times ');
    j=input('\n\nPlot channel number (0 to fix dropout, -1 to quit) ');
    if j > 0,
      jplt=j;
      jplt=max(1,min(jplt,n));
    end
  end
  if j==0,
%
%  Initial time.
%
    fprintf('\n\nSelect initial time on the graph ');
    fprintf('\nUse right mouse button for manual input ');
    [ti,y,nb]=ginput(1);
    if nb~=1,
      ti=input('\n\nInput initial time (0 to skip) ');
    end
    if ti < 0 
      ti=0;
    end
    ti=round(ti/dt)*dt;
    fprintf('\n\nSelected initial time = %f',ti);
    indi=max(find(time<=ti));
%
%  Final time.
%
    fprintf('\n\nSelect final time on the graph ');
    fprintf('\nUse right mouse button for manual input ');
    [tf,y,nb]=ginput(1);
    if nb~=1,
      tf=input('\n\nInput final time (0 to skip) ');
    end
    if tf <= 0 | tf > max(time),
      tf=max(time);
    end
    tf=round(tf/dt)*dt;
    fprintf('\n\nSelected final time = %f \n',tf);
    indf=min(find(time>=tf));
%
%  Fix the dropout with a linear interpolation.
%
    indx=[indi:indf]';
    di=(indx-indi)/(max(indx)-indi);
    fdata(indx,:)=ones(length(di),1)*fdata(indi,:)+di*(fdata(indf,:)-fdata(indi,:));
    hold on;
    plot(t,fdata(:,jplt),'r+')
    fprintf('\n\n Press any key to continue ... '),pause,
    hold off;
    j=jplt;
  end
end
zoom off;
return
