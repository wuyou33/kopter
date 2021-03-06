function czt = czo_mod(alpha,LUTvalues)
%  CZO  Computes basic aerodynamic Z force coefficient.
%
%  Usage: czt = czo(alpha);
%
%  Description:
%
%    Computes the basic Z body-axis aerodynamic force 
%    coefficient for the F-16.  
%
%  Input:
%    
%     alpha = angle of attack, deg.
%
%  Output:
%
%       czt = basic Z body-axis aerodynamic force coefficient.
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
% global CZO
CZO = LUTvalues.CZO;
s=0.2*alpha;
k=fix(s);
k=max(-1,k);
k=min(k,8);
da=s-k;
%
%  Add 3 to the indices because the indexing of CZO 
%  starts at 1, not -2.
%
k=k+3;
l=k+sign(da);
czt=CZO(k)+abs(da)*(CZO(l)-CZO(k));
return
