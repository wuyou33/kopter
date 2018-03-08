function [Y,A,B,C,D] = flatss(p,U,w,x0,c)
%
%  FLATSS  Frequency-domain lateral state-space model file.  
%
%  Usage: [Y,A,B,C,D] = flatss(p,U,w,x0,c);
%
%  Description:
%
%    Model file for closed-loop lateral 
%    low order equivalent system state-space 
%    model in the frequency domain.
%
%  Input:
%
%    p = parameter vector.
%    U = input vector in the frequency domain.
%    w = frequency vector, rad/sec.
%   x0 = initial state vector.
%    c = vector of constants.
%
%  Output:
%
%        Y = model output vector in the frequency domain.
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
%      28 Nov 1996 - Created and debugged, EAM.
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
np=length(p);
[nw,ni]=size(U);
nw=length(w);
jay=sqrt(-1);
jw=jay*w;
%
%  System matrices.
%
A=[p(1),c.sa,-c.ca,c.dgdp;...
   p(3),p(4),p(5),0;...
   p(8),p(9),p(10),0;...
   0,1,c.tt,0];
B=[p(2),0;...
   p(6),p(7);...
   p(11),p(12);...
   0,0];
C=[1,0,0,0;...
   0,1,0,0;...
   0,0,1,0;...
   0,0,0,1;...
   p(1)*c.vog,0,0,0];
D=[0,0;...
   0,0;...
   0,0;...
   0,0;...
   p(2)*c.vog,0];
[no,ns]=size(C);
%
%  Multiple input - lateral stick, rudder pedal.
%
Ul=U;
%
%  Estimate input time delay in the frequency domain. 
%
%Ul=zeros(nw,ni);
%for k=1:ni,
%  Ul(:,k)=U(:,k).*exp(-jw*p(np-ni+k));
%end
%
%  Determine whether to use equation error or output error formulation.
%
if ~isreal(c)
%
%  Equation error.
%
  Y=zeros(nw,no);
  Z=c;
  for i=1:nw,
    Y(i,:)=(A*Z(i,:).' + B*Ul(i,:).').';
  end
else
%
%  Output error.
%
  Y=zeros(nw,no);
  for i=1:nw,
    x=(jw(i)*eye(ns,ns)-A)\(B*Ul(i,:).');
    Y(i,:)=(C*x + D*Ul(i,:).').';
  end
end
return
