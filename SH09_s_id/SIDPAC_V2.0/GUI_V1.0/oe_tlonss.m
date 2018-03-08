function [y,x,A,B,C,D] = oe_tlonss(p,u,t,x0,c)
%
%  OE_TLONSS  Time-domain longitudinal state-space model.  
%
%  Usage: [y,x,A,B,C,D] = oe_tlonss(p,u,t,x0,c);
%
%  Description:
%
%    Longitudinal state-space dynamic model 
%    in the time domain.  
%
%  Input:
%
%    p = parameter vector.
%    u = input vector or matrix.
%    t = time vector.
%   x0 = initial state vector.
%    c = vector or data structure of constants.
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

%
%  Longitudinal dynamics.  
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
%  Accelerometer outputs depend on parameters in the state equations.
%
%  ax
%
g=c.vo/c.vog;
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
