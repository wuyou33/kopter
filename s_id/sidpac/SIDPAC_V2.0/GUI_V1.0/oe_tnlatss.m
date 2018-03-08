function [y,x,A,B,C,D] = oe_tnlatss(p,u,t,x0,c)
%
%  OE_TNLATSS  Time-domain lateral state-space model using non-dimensional parameters.  
%
%  Usage: [y,x,A,B,C,D] = oe_tnlatss(p,u,t,x0,c);
%
%  Description:
%
%    Lateral state-space dynamic model 
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
%      08 Aug 2006 - Created and debugged, EAM.
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
no=5;
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
k1=c.qs/(c.mass*c.vo);
%
A(1,1)=A(1,1)*k1;
%
%  The kinematic term must be added 
%  for the non-dimensional model.  
%  In the dimensional case, the kinematic 
%  terms are lumped together with Yp and Yr.  
%
A(1,2)=A(1,2)*k1*c.b2v + c.sa;
A(1,3)=A(1,3)+c.ca*k1*c.b2v - c.ca;
B(1,[1:3])=B(1,[1:3])*k1;
%
A(2,1)=A(2,1)*c.qsb;
A(2,2)=A(2,2)*c.qsb*c.b2v;
A(2,3)=A(2,3)*c.qsb*c.b2v;
B(2,[1:3])=B(2,[1:3])*c.qsb;
%
A(3,1)=A(3,1)*c.qsb;
A(3,2)=A(3,2)*c.qsb*c.b2v;
A(3,3)=A(3,3)*c.qsb*c.b2v;
B(3,[1:3])=B(3,[1:3])*c.qsb;
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
%  Accelerometer outputs depend on parameters in the state equations.
%
%  ay
%
C(5,1)=A(1,1)*c.vog;
C(5,2)=(A(1,2)-c.sa)*c.vog;
C(5,3)=(A(1,3)+c.ca)*c.vog;
D(5,[1:2])=B(1,[1:2])*c.vog;
%
[y,x]=lsims(A,B,C,D,u,t,x0);
%
%  Use only the outputs specified for matching.
%
oindx=find(c.imo==1);
y=y(:,oindx);
return
