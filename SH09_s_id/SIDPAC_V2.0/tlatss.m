function [y,x,A,B,C,D] = tlatss(p,u,t,x0,c)
%
%  TLATSS  Time-domain lateral state-space model file.  
%
%  Usage: [y,x,A,B,C,D] = tlatss(p,u,t,x0,c);
%
%  Description:
%
%    Model file for lateral state-space
%    dynamic model in the time domain. 
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
%      14 May 1995 - Created and debugged, EAM.
%      03 Feb 2006 - Changed c(1) definition, EAM.
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
A=[p(1),c.sa,-c.ca,c.dgdp;...
   p(4),p(5),p(6),0;...
   p(10),p(11),p(12),0;...
   0,1,c.tt,0];
B=[p(2),0,p(3);...
   p(7),p(8),p(9);...
   p(13),p(14),p(15);...
   0,0,p(16)];
C=[1,0,0,0;...
   0,1,0,0;...
   0,0,1,0;...
   0,0,0,1;...
   p(1)*c.vog,0,0,0];
D=[0,0,0;...
   0,0,0;...
   0,0,0;...
   0,0,0;...
   p(2)*c.vog,0,p(17)];
[y,x]=lsims(A,B,C,D,u,t,x0);
return
