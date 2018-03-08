function [y,x,A,B,C,D] = oe_tnlonss(p,u,t,x0,c)
%
%  OE_TNLONSS  Time-domain longitudinal state-space model using non-dimensional parameters.  
%
%  Usage: [y,x,A,B,C,D] = oe_tnlonss(p,u,t,x0,c);
%
%  Description:
%
%    Longitudinal state-space dynamic model 
%    in the time domain using non-dimensional parameters.
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
%      06 Aug 2006 - Created and debugged, EAM.
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
ip=c.ip;
p0=c.p0;
pindx=find(ip==1);
p0(pindx)=p;
ns=4;
nc=3;
no=6;
np=length(p0);
%
%  Assemble the system matrices.
%
S=[p0(1:ns+nc)';...
   p0(ns+nc+1:2*(ns+nc))';...
   p0(2*(ns+nc)+1:3*(ns+nc))';...
   p0(3*(ns+nc)+1:4*(ns+nc))'];
A=S(:,[1:ns]);
B=S(:,[ns+1:ns+nc]);
C=zeros(no,ns);
C([1:ns],[1:ns])=eye(ns,ns);
D=zeros(no,nc);
D(:,nc)=p0(ns*(ns+nc)+1:np);
%
%  Multiply the parameters by 
%  dimensionalizing constants.  
%
g=c.vo/c.vog;
k1=c.qs/c.mass;
k2=c.qs/(c.mass*c.vo);
k3=c.qsc*c.ci(7);
k4=c.qs/(c.mass*g);
%
A(1,1)=A(1,1)*k1/c.vo;
%
%  The kinematic term must be added 
%  for the non-dimensional model.  
%  In the dimensional case, the kinematic
%  term is lumped together with Xa.
%
A(1,2)=A(1,2)*k1 + g;
A(1,3)=A(1,3)*k1*c.c2v;
B(1,[1:3])=B(1,[1:3])*k1;
%
A(2,1)=A(2,1)*k2/c.vo;
A(2,2)=A(2,2)*k2;
%
%  The kinematic term must be added 
%  for the non-dimensional model.  
%  In the dimensional case, the kinematic 
%  term is lumped together with Zq.  
%
A(2,3)=A(2,3)*k2*c.c2v + 1;
B(2,[1:3])=B(2,[1:3])*k2;
%
A(3,1)=A(3,1)*k3/c.vo;
A(3,2)=A(3,2)*k3;
A(3,3)=A(3,3)*k3*c.c2v;
B(3,[1:3])=B(3,[1:3])*k3;
%
%  Accelerometer outputs depend on parameters in the state equations.
%
%  ax
%
C(5,1)=A(1,1)/g;
C(5,2)=(A(1,2)-g)/g;
C(5,3)=A(1,3)/g;
D(5,[1:2])=B(1,[1:2])/g;
%
%  az
%
C(6,[1:2])=A(2,[1:2])*c.vog;
C(6,3)=(A(2,3)-1)*c.vog;
D(6,[1:2])=B(2,[1:2])*c.vog;
%
[y,x]=lsims(A,B,C,D,u,t,x0);
%
%  Use only the outputs specified for matching.
%
oindx=find(c.imo==1);
y=y(:,oindx);
return
