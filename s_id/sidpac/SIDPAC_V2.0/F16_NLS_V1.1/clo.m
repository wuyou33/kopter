function clt = clo(alpha,beta)
%
%  CLO  Computes basic aerodynamic rolling moment coefficient.
%
%  Usage: clt = clo(alpha,beta);
%
%  Description:
%
%    Computes the basic aerodynamic rolling moment 
%    coefficient for the F-16.  
%
%  Input:
%    
%     alpha = angle of attack, deg.
%      beta = sidelsip angle, deg.
%
%  Output:
%
%       clt = basic aerodynamic rolling moment coefficient.
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
global CLO
s=0.2*alpha;
k=fix(s);
k=max(-1,k);
k=min(k,8);
da=s-k;
%
%  Add 3 to the indices because the indexing of CLO 
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
t=CLO(k,m);
u=CLO(k,n);
v=t+abs(da)*(CLO(l,m)-t);
w=u+abs(da)*(CLO(l,n)-u);
clt=v+(w-v)*abs(db);
clt=clt*sign(beta);
return
