function [y,x,A,B,C,D] = tnlatss_bias(p,u,t,x0,c)
%
%  TNLATSS_BIAS  Model file associated with tnlatss.m for estimating biases.
%
%  Usage: [y,x,A,B,C,D] = tnlatss_bias(p,u,t,x0,c);
%
%  Description:
%
%    Non-dimensional lateral state space dynamic model 
%    in the time domain.  This m-file is used to 
%    estimate bias parameters using output-error
%    parameter estimation.  
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
%      22 Nov 2004 - Created and debugged, EAM.
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
pf=c.pf;
A=[k1*pf(1),c.sa,(-c.ca+k1*pf(2)*c.b2v),c.dgdp;...
   c.qsb*[pf(4),pf(5)*c.b2v,pf(6)*c.b2v,0];...
   c.qsb*[pf(9),pf(10)*c.b2v,pf(11)*c.b2v,0];...
   0,1,c.tt,0];
B=[k1*[0,pf(3)];...
   c.qsb*[pf(7),pf(8)];...
   c.qsb*[pf(12),pf(13)];...
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
B=[B,[p(1),p(2),p(3),p(4)]'];
C=[1,0,0,0;...
   0,1,0,0;...
   0,0,1,0;...
   0,0,0,1;...
   k2*pf(1),0,k2*pf(2)*c.b2v,0];
D=[0,0,0;...
   0,0,0;...
   0,0,0;...
   0,0,0;...
   0,k2*pf(3),p(5)];
[y,x]=lsims(A,B,C,D,u,t,x0);
return
