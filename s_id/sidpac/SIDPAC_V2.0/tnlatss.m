function [y,x,A,B,C,D] = tnlatss(p,u,t,x0,c)
%
%  TNLATSS  Time-domain lateral state-space model file using non-dimensional parameters.  
%
%  Usage: [y,x,A,B,C,D] = tnlatss(p,u,t,x0,c);
%
%  Description:
%
%    Non-dimensional lateral state-space dynamic model 
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
%      17 May 2004 - Created and debugged, EAM.
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
k1=c.qs/(c.mass*c.vo);
k2=c.qs/(c.mass*g);
A=[k1*p(1),c.sa,(-c.ca+k1*p(2)*c.b2v),c.dgdp;...
   c.qsb*[p(5),p(6)*c.b2v,p(7)*c.b2v,0];...
   c.qsb*[p(11),p(12)*c.b2v,p(13)*c.b2v,0];...
   0,1,c.tt,0];
B=[k1*[0,p(3)];...
   c.qsb*[p(8),p(9)];...
   c.qsb*[p(14),p(15)];...
   0,0];
%
%  Isolate state derivatives for p and r 
%  on the left-hand side.  
%
Ao=A;
A(2,:)=c.ci(3)*Ao(2,:)+c.ci(4)*Ao(3,:);
A(3,:)=c.ci(4)*Ao(2,:)+c.ci(9)*Ao(3,:);
Bo=B;
B(2,:)=c.ci(3)*Bo(2,:)+c.ci(4)*Bo(3,:);
B(3,:)=c.ci(4)*Bo(2,:)+c.ci(9)*Bo(3,:);
%
%  Include bias terms.
%
B=[B,[p(4),p(10),p(16),p(17)]'];
C=[1,0,0,0;...
   0,1,0,0;...
   0,0,1,0;...
   0,0,0,1;...
   k2*p(1),0,k2*p(2)*c.b2v,0];
D=[0,0,0;...
   0,0,0;...
   0,0,0;...
   0,0,0;...
   0,k2*p(3),p(18)];
[y,x]=lsims(A,B,C,D,u,t,x0);
return
