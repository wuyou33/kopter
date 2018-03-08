function [fdata,t,ti,tf] = cutftd(fdatao)
%
%  CUTFTD  Plots flight test data and implements manual data cutting for flight test maneuvers.  
%
%  Usage: [fdata,t,ti,tf] = cutftd(fdatao);
%
%  Description:
%
%    Cuts input flight test data matrix fdatao 
%    according to user input.  
%
%  Input:
%    
%   fdatao = flight data array in standard configuration.
%
%  Output:
%
%    fdata = flight data array cut according to user input.
%        t = time vector corresponding to fdata, sec.
%       ti = selected initial time, sec.
%       tf = selected final time, sec.
%
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      06 Aug 1999 - Created and debugged, EAM.
%      29 Aug 1999 - Fixed input handling so return input exits, EAM.
%      17 Mar 2005 - Added ti and tf outputs, EAM.
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
t=fdatao(:,1)-fdatao(1,1);
dt=1/round(1/(t(2)-t(1)));
time=[0:dt:(npts-1)*dt]';
t=time;
ti=t(1);
tf=t(npts);
fdata=fdatao;
jplt=4;
j=jplt;
while j >= 0,
  while j > 0 & j <=n,
    plot(t,fdata(:,j));grid on;
    xlabel('time (sec)');ylabel(['Channel ',num2str(j)]);
    title(['Maneuver length = ',num2str(max(t)-min(t)),' sec']);
    j=input('\nPlot channel number (0 to cut, -1 to quit) ');
%
%  Carriage return input is the same as 0 to cut.
%
    if isempty(j),
      j=0;
    end
    if j > 0,
      jplt=j;
      jplt=max(1,min(jplt,n));
    end
  end
  if j==0,
%
%  Initial time input.
%
    fprintf('\n\nSelect initial time on the graph ');
    fprintf('\nUse right mouse button for manual input ');
    [ti,y,nb]=ginput(1);
    if nb~=1,
      ti=input('\n\nInput initial time  ');
      tf=input('\nInput final time  ');
    else
%
%  Final time input.
%
      fprintf('\n\nSelect final time on the graph ');
      [tf,y,nb]=ginput(1);
    end
%
%  Initial time data conditioning.
%
    if ti < 0 
      ti=0;
    end
    ti=round(ti/dt)*dt;
    fprintf('\n\nSelected initial time = %f',ti);
    indi=max(find(time<=ti));
%
%  Final time data conditioning.
%
    if tf <= 0 | tf > max(time),
      tf=max(time);
    end
    tf=round(tf/dt)*dt;
    fprintf('\n\nSelected final time = %f \n',tf);
    indf=min(find(time>=tf));
%
%  Cut the maneuver.
%
    t=time(indi:indf);
    fdata=fdatao([indi:indf],:);
    j=jplt;
  end
end
%
%  Make time vector start at zero.
%
t=t-t(1);
return
