function [Y,X,A,B,C,D] = fnlatss(p,U,w,x0,c)
%
%  FNLATSS  Frequency-domain lateral state-space model file using non-dimensional parameters.  
%
%  Usage: [Y,X,A,B,C,D] = fnlatss(p,U,w,x0,c);
%
%  Description:
%
%    Non-dimensional lateral state space dynamic model 
%    in the frequency domain.  This m-file is used for 
%    output-error parameter estimation and simulation.  
%
%  Input:
%
%    p = parameter vector.
%    U = matrix of input vectors in the frequency domain.
%    w = frequency vector, rad/sec.
%   x0 = initial state vector.
%    c = vector of constants.
%
%  Output:
%
%        Y = model output vector or matrix.
%        X = model state vector or matrix.
%  A,B,C,D = system matrices.
%
%

%
%    Calls:
%      None
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
A=[k1*p(1),c.sa,(-c.ca+k1*p(2)*c.b2v),c.dgdp;...
   c.qsb*[p(4),p(5)*c.b2v,p(6)*c.b2v,0];...
   c.qsb*[p(9),p(10)*c.b2v,p(11)*c.b2v,0];...
   0,1,c.tt,0];
ns=size(A,1);
B=[k1*[0,p(3)];...
   c.qsb*[p(7),p(8)];...
   c.qsb*[p(12),p(13)];...
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
%  Output matrices.
%
C=[1,0,0,0;...
   0,1,0,0;...
   0,0,1,0;...
   0,0,0,1;...
   k2*p(1),0,k2*p(2)*c.b2v,0];
D=[0,0;...
   0,0;...
   0,0;...
   0,0;...
   0,k2*p(3)];
[no,ni]=size(D);
%
%  Output error.
%
nw=length(w);
jay=sqrt(-1);
jw=jay*w;
Y=zeros(nw,no);
X=zeros(nw,ns);
for i=1:nw,
  X(i,:)=((jw(i)*eye(ns,ns)-A)\(B*U(i,:).')).';
  Y(i,:)=(C*X(i,:).' + D*U(i,:).').';
end
return
