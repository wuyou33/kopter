function [Y,X,A,B,C,D] = fnlonss(p,U,w,x0,c)
%
%  FNLONSS  Frequency-domain longitudinal state-space model file using non-dimensional parameters.  
%
%  Usage: [Y,X,A,B,C,D] = fnlonss(p,U,w,x0,c);
%
%  Description:
%
%    Non-dimensional longitudinal state space dynamic model 
%    in the frequency domain.  This m-file is used for 
%    output-error parameter estimation.  
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
%      30 Nov 2004 - Created and debugged, EAM.
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
dtr=pi/180;
k1=-c.qs/(c.mass*c.vo);
k2=c.qsc*c.ci(7);
k3=-c.qs/(c.mass*g);
%
%  System and control matrices.
%
% A=[k1*p(1),1+k1*c.c2v*p(2);...
%    k2*[p(4),c.c2v*p(5)]];
% ns=size(A,1);
% B=[k1*p(3);...
%    k2*p(6)];
A=[k1*p(1),1;...
   k2*[p(3),c.c2v*p(4)]];
ns=size(A,1);
B=[k1*p(2);...
   k2*p(5)];
%
%  Output matrices.
%
% C=[1,0;...
%    0,1;...
%    k3*p(1),k3*c.c2v*p(2)];
% D=[0;...
%    0;...
%    k3*p(3)];
C=[1,0;...
   0,1;...
   k3*p(1),0];
D=[0;...
   0;...
   k3*p(2)];
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
