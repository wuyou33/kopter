function [uvec,mag] = unit(vec)
%
%  UNIT  Finds the unit vector for a given vector.  
%
%  Usage: [uvec,mag] = unit(vec);
%
%  Description:
%
%    Computes a unit vector uvec in the same direction 
%    as input vector vec.  Magnitude of vec is mag.  
%
%  Input:
%    
%    vec = vector.
%
%  Outputs:
%
%    uvec = unit vector with the same direction as vec. 
%     mag = magnitude of vec, vec = mag*uvec.
%

%
%    Author:  Eugene A. Morelli
%
%    Calls:
%      None
%
%    History:  
%      29 Dec 2001 - Created and debugged, EAM.
%
%
%  Copyright (C) 2006  Eugene A. Morelli
%
%
%  This program carries no warranty, not even the implied 
%  warranty of merchantability or fitness for a particular purpose.  
%
%  Please email bug reports or suggestions for improvements to:
%
%      e.a.morelli@nasa.gov
%
mag=sqrt(sum(vec.*vec));
uvec=vec/mag;
return
