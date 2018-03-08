function [zv,vs,cp,vsn,erfz,z] = prob_plot(v,lplot);
%
%  PROB_PLOT  Makes a diagnostic cumulative probability plot.  
%
%  Usage: [zv,vs,cp,vsn,erfz,z] = prob_plot(v,lplot);
%
%  Description:
%
%    Makes diagnostic cumulative probability plot 
%    of z score versus sorted values of v, for an 
%    input data vector v.  A straight line indicates
%    that the elements of v are normally distributed.  
%    A cumulative probability plot of cp versus vsn 
%    should roughly match the plot of erfz verus z, 
%    if the elements of v are normally distributed.    
%
%
%  Input:
%
%       v = data vector.
%   lplot = plot flag (optional):
%           = 0 for no plot 
%           = 1 for plot (default)
%
%
%  Output:
%
%     zv = z score values for sorted values of v.
%     vs = sorted values of v.
%     cp = cumulative normal probability for vs.
%    vsn = normalized values of vs.  
%      z = normalized z score values, [-4 <= z <= 4].
%   erfz = ideal normal probability distribution for z, [0 <= erfz <= 1].
%
%      graphics:
%          2D diagnostic plot
%

%
%    Calls:
%      cvec.m
%      rms.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      14 Dec 2004 - Created and debugged, EAM.
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
if nargin < 2
  lplot=1;
end
%
%  Order the elements of v from smallest to largest.
%
vs=sort(cvec(v));
vsn=vs/rms(vs);
%
%  Compute the cumulative probability.
%
npts=length(vs);
cp=([1:1:npts]'-0.5*ones(npts,1))/npts;
%
%  Tabulated values of erfz.
%
z  = [0.0,     0.1,     0.2,     0.3,     0.4,     0.5,     0.6,     0.7,     0.8,     0.9,...
      1.0,     1.1,     1.2,     1.3,     1.4,     1.5,     1.6,     1.7,     1.8,     1.9,...
      2.0,     2.1,     2.2,     2.3,     2.4,     2.5,     2.6,     2.7      2.8,     2.9,...
      3.0,     3.5,     4.0]';
erfz=[0.5,     0.53983, 0.57926, 0.61791, 0.65542, 0.69146, 0.72575, 0.75803, 0.78814, 0.81594,... 
      0.84134, 0.86433, 0.88493, 0.90320, 0.91924, 0.93319, 0.94520, 0.95543, 0.96407, 0.97128,...
      0.97725, 0.98214, 0.98610, 0.98928, 0.99180, 0.99379, 0.99534, 0.99653, 0.99744, 0.99813,...
      0.99865, 0.99977, 1.0]';
%
%  Build the rest of the table by 
%  reflecting about z=0.
%
n=length(z);
z=[-z(n:-1:2);z];
erfz=[ones(n-1,1)-erfz(n:-1:2);erfz];
%
%  Compute the z score associated with 
%  the data vector v, for plotting.  
%
zv=zeros(npts,1);
for i=1:npts,
  zv(i)=int1(cp(i),erfz,z);
end
%
%  Draw the probability plot.
%
if lplot==1
  plot(vs,zv,'.','MarkerSize',8,'LineWidth',1.5),grid on,
  title('Cumulative Probability Plot','FontSize',10,'FontWeight','bold','FontAngle','italic');
  xlabel('ordered data'),
  ylabel('z'),
  grid on,
end
return
