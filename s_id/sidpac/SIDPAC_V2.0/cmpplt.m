function cmpplt(z,y,t)
%
%  CMPPLT  Makes comparison plots for model and measured data.  
%
%  Usage: cmpplt(z,y,t);
%
%  Description:
%
%    Plots z, y, and z-y versus t 
%    in the current figure window.  
%
%  Input:
%    
%     y = model vector or matrix.  
%     z = measured vector or matrix.
%     t = time vector.
%
%  Output:
%
%    graphics:
%      2-D plots
%

%
%    Calls:
%      cvec.m
%      sid_plot_lines.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      8 Sept 2000 - Created and debugged, EAM.
%     29 Oct  2005 - Updated to handle matrices, EAM.
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
[npts,no]=size(z);
t=cvec(t);
npts=length(t);
if npts~=size(z,1) | npts ~=size(y,1)
  fprintf('\n Input data are dimensionally inconsistent \n\n');
  return
end
for j=1:no,
  subplot(2,1,1);plot(t,z(:,j),t,y(:,j),'--');
  sid_plot_lines;
  grid on;legend('z','y',0);
  subplot(2,1,2);plot(t,z(:,j)-y(:,j),'+');
  grid on;legend('residual z-y',0);
  fprintf('\n\n Press any key to continue ... '),pause,
end
return
