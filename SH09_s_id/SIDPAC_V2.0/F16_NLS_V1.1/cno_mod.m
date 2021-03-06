function cnt = cno_mod(alpha,beta,LUTvalues)
%
%  CNO  Computes basic aerodynamic yawing moment coefficient.
%
%  Usage: cnt = cno(alpha,beta);
%
%  Description:
%
%    Computes the basic aerodynamic yawing moment 
%    coefficient for the F-16.  
%
%  Input:
%    
%     alpha = angle of attack, deg.
%      beta = sidelsip angle, deg.
%
%  Output:
%
%       cnt = basic aerodynamic yawing moment coefficient.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      19 June 1995 - Created and debugged, EAM.
%
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
% global CNO
CNO = LUTvalues.CNO;
s=0.2*alpha;
k=fix(s);
k=max(-1,k);
k=min(k,8);
da=s-k;
%
%  Add 3 to the indices because the indexing of CNO 
%  starts at 1, not -2.
%
k=k+3;
l=k+sign(da);
s=0.2*abs(beta);
m=fix(s);
m=max(1,m);
m=min(m,5);
db=s-m;
m=m+1;
n=m+sign(db);
t=CNO(k,m);
u=CNO(k,n);
v=t+abs(da)*(CNO(l,m)-t);
w=u+abs(da)*(CNO(l,n)-u);
cnt=v+(w-v)*abs(db);
cnt=cnt*sign(beta);
return
