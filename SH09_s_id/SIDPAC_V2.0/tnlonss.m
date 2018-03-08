function [y,x,A,B,C,D] = tnlonss(p,u,t,x0,c)
%
%  TNLONSS  Time-domain longitudinal state-space model file using non-dimensional parameters.  
%
%  Usage: [y,x,A,B,C,D] = tnlonss(p,u,t,x0,c);
%
%  Description:
%
%    Non-dimensional longitudinal state-space dynamic model 
%    in the time domain.  This m-file is used for 
%    output-error parameter estimation and simulation.  
%
%  Input:
%
%    p = parameter vector.
%    u = input vector or matrix.
%    t = time vector.
%   x0 = initial state vector.
%    c = vector of constants.
%
%  Output:
%
%         y = model output vector or matrix time history.
%         x = model state vector or matrix time history.
%   A,B,C,D = system matrices.
%
%

%
%    Calls:
%      lsims.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      30 Nov 2004 - Created and debugged, EAM.
%      09 Jun 2006 - Standardized constants, EAM.
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
g=32.174;
k1=-c.qs/(c.mass*c.vo);
k2=c.qsc*c.ci(7);
k3=-c.qs/(c.mass*g);
A=[k1*p(1),1;...
   k2*[p(4),c.c2v*p(5)]];
ns=size(A,1);
B=[k1*p(2);...
   k2*p(6)];
%
%  Include bias terms.
%
B=[B,[p(3),p(7)]'];
%
%  Output matrices.
%
C=[1,0;...
   0,1;...
   k3*p(1),0];
D=[0,0;...
   0,0;...
   k3*p(2),p(8)];
[y,x]=lsims(A,B,C,D,u,t,x0);
return
