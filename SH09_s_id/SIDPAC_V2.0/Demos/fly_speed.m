%
%  FLY_SPEED  Speed control for fly.m.  
%
%  Usage: fly_speed;
%
%  Description:
%
%    Controls the speed and of flight 
%    for the viewpoint inside routine fly.m, 
%    depending on user mouse button inputs. 
%
%  Input:
%    
%    None
%
%  Output:
%
%     SPEED = viewpoint speed.
%
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      31 Dec 2001 - Created and debugged, EAM.
%      21 Jan 2002 - Added extra SPEED controls and capability, EAM.
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

global SPEED
%
%  Find which mouse button was pressed.
%
stype=get(gcf,'SelectionType');
%
%  Decrease speed for a left button click.  
%  Increase speed for a right button click.
%
if strcmp(stype,'normal')
  SPEED = SPEED - 0.01;
elseif strcmp(stype,'alt')
  SPEED = SPEED + 0.01;
elseif strcmp(stype,'open')
  if strcmp(last_stype,'normal')
    SPEED = SPEED - 0.01;
  elseif strcmp(last_stype,'alt')
    SPEED = SPEED + 0.01;
  end
end
last_stype=stype;
%
%  Remove any round-off errors and 
%  enforce SPEED limits.  
%
SPEED=round(100*SPEED)/100;
SPEED=max(-1,min(SPEED,1));
return
