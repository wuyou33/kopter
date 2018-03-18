function cxt = cxo_mod(alpha,stab,LUTvalues)
%
%  CXO  Computes basic aerodynamic X force coefficient.
%
%  Usage: cxt = cxo(alpha,stab);
%
%  Description:
%
%    Computes the basic X body-axis aerodynamic force 
%    coefficient for the F-16.  
%
%  Input:
%    
%     alpha = angle of attack, deg.
%      stab = stabilator deflection, deg.
%
%  Output:
%
%       cxt = basic X body-axis aerodynamic force coefficient.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      19 June 1995 - Created and debugged, EAM.
%      02 Aug  2006 - Changed elevator to stabilator, EAM.
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
% global CXO
CXO = LUTvalues.CXO;
s=0.2*alpha;
k=fix(s);
k=max(-1,k);
k=min(k,8);
da=s-k;
%
%  Add 3 to the indices because the indexing of CXO 
%  starts at 1, not -2.
%
k=k+3;
l=k+sign(da);
s=stab/12;
m=fix(s);
m=max(-1,m);
m=min(m,1);
de=s-m;
m=m+3;
n=m+sign(de);
t=CXO(k,m);
u=CXO(k,n);
v=t+abs(da)*(CXO(l,m)-t);
w=u+abs(da)*(CXO(l,n)-u);
cxt=v+(w-v)*abs(de);
return
