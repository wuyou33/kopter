function u_rot = rotat(u,d,angle)
%
%  ROTAT  Rotates a 3D vector.
%
%  Usage: u_rot = rotat(u,d,angle);
%
%  Description:
%
%    Rotates 3D vector u through angle about 
%    the direction specified by 3D vector d.  
%    Both u and d are assumed to emanate 
%    from the origin.
%
%
%  Input:
%    
%      u = 3D vector to be rotated about vector d.
%      d = 3D direction vector.
%  angle = rotation angle of u about d.
%
%
%  Output:
%
%    u_rot = 3D vector u rotated through angle about d.
%

%
%    Calls:
%      unit.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      01 Jan 2002 - Created and debugged, EAM.
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
d = unit(d);
u = [ u 1 ];
if(d(3) == 0)
  R1 = eye(4);
elseif(d(2) == 0)
  R1 = [ 1 0 0 0 ; 0 0 -1 0; 0 1 0 0 ; 0 0 0 1 ];
else
  thet = atan(d(3)/d(2));
  R1 = [ 1 0 0 0
         0 cos(-thet) sin(-thet) 0
         0 -sin(-thet) cos(-thet) 0
         0 0 0 1 ];
end
d2 = [ d 1 ]*R1;
if(d2(2) == 0)
  R2 = eye(4);
elseif(d2(1) == 0)
  R2 = [ 0 -1 0 0 ; 1 0 0 0; 0 0 1 0 ; 0 0 0 1 ];
else
  phi = atan(d2(2)/d2(1));
  R2 = [ cos(-phi) sin(-phi) 0 0
         -sin(-phi) cos(-phi) 0 0
         0 0 1 0 
         0 0 0 1 ];
end
R3 = [ 1 0 0 0
       0 cos(angle) sin(angle) 0
       0 -sin(angle) cos(angle) 0
       0 0 0 1 ];
u_rot = u*R1*R2*R3*inv(R2)*inv(R1);
u_rot = u_rot(1:3);
return
