function fly(varargin);
%
%  FLY  Simulates flight through a three-dimensional data set.  
%
%  Usage: fly(varargin);
%
%  Description:
%
%    Simulates flight over the 3D mesh plot.
%    
%
%  Input:
%
%    fly('FileName.mat') starts the program using the 
%    parameters saved to the FileName.mat file.  
%    All parameters have default values and need only 
%    be included in the call line if necessary or desired.
%    Values for each parameter must be saved in the 
%    FileName.mat file with names given below.  
%
%    The calling syntax:
%
%       fly(LANDSCAPE,'PropertyName1',value1,'PropertyName2',value2,...) 
%
%    allows user control of parameters using values 
%    from the workspace.  All parameters have default values.
%
%    List of parameters:
%
%  landscape = matrix of data defining the surface, default = peaks.
%          x = vector of x values for the 3D plot, default = [1:1:size(landscape,1)].
%          y = vector of y values for the 3D plot, default = [1:1:size(landscape,2)].
%      speed = forward speed, default = 1.
%              Left mouse button click decreases speed.
%              Right mouse button click increases speed.
%        map = colormap used for the 3D surface, default is 'jet'.
%        sky = sky color [ R G B ], default = [0.5, 0.8, 0.9] (sky blue).
%      shade = 3D surface shading ='flat','facted', or 'interp',default = 'flat'.
%      start = initial location in 3D axis coordinates, default calculated based on landscape.
%     target = initial view target point, plane target, default calculated based on landscape.
%
%    Flying:
%      The mouse pointer is automatically centered in the middle of the 
%      figure window.  Moving the mouse up and down is analagous to moving the
%      stick forward and backward, and changes the pitch attitude 
%      relative to the 3D landscape.  Moving the mouse right and left is 
%      analogous to moving the stick right and left, and causes changes in the 
%      the bank angle relative to the 3D landscape.  Mouse button clicks change 
%      the forward speed.  The flying commands are summarized below:
%
%         fore and aft mouse motion = change pitch angle
%         left and right mouse motion = change bank angle
%         left mouse click = decrease forward speed by 0.1
%         left mouse double-click = decrease forward speed by 0.2
%         right mouse click = increase forward speed by 0.1
%         right mouse double-click = increase forward speed by 0.2
%
%       At any time, the following keyboard commands are active:
%         r: reverse heading (change heading by 180 degrees).
%         x: exit
%    
% 
%    Examples:
%       fly;
%
%
%
%  Output:
%
%    graphics:
%      3D plot from various viewpoints.
%
%

%
%    Calls:
%      unit.m
%      fly_speed.m
%      rotat.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      30 Dec 2001 - Created and debugged, EAM.
%      21 Jan 2002 - Separated camera target placement from SPEED, EAM.
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
%  Initialization.
%
close all;
map = 'jet';
shade = 'flat';
groundstyle = 'mesh';
dtr=pi/180;
rtd=180/pi;
%
% Parse the input.
%
if (nargin == 0)
  landscape = peaks;
  x = 1:size(landscape,1);
  y = 1:size(landscape,2);
elseif (nargin == 1)
%
%  A single input argument may be 
%  a file name or a landscape.
%
%
%  File.
%
  if(ischar(varargin{1})) % This is a file.
    load(varargin{1});
%
%  Landscape.
%
  else
    landscape = varargin{1};
    x = 1:size(landscape,1);
    y = 1:size(landscape,2);
  end
else
%
%  Parse multiple inputs.
%
  landscape = varargin{1};
  x = 1:size(landscape,1);
  y = 1:size(landscape,2);
  for i = 2:2:nargin
    eval(strcat(varargin{i},' = varargin{i+1};'));
  end
end
%
%  Initialize the figure window.
%
ssize=get(0,'ScreenSize');
rect=[0.02*ssize(3) 0.07*ssize(4) 0.95*ssize(3) 0.83*ssize(4)];
figH=figure('Position',rect, ...
            'Name','Aerodynamic Database', ...
            'NumberTitle','off', ...
            'MenuBar','none',...
            'Visible','on', ...
            'NextPlot','add',...
            'Renderer','OpenGL',...
            'Units','normalized');
%
%  Axis scaling relative to the peaks data 
%  so that the stick gains still apply and 
%  the 3D graphics remain smooth.  
%
mxl=max(max(landscape));
mnl=min(min(landscape));
zscl=10/(10^round(log10(mxl-mnl)));
%
%  Plot the 3D surface.
%
eval([groundstyle,'(y,x,landscape*zscl);']);
zlabel([' x ',num2str(zscl)]);
colormap(map);
shading(shade);
axis vis3d;
v=gca;
set(v,'Units','Normalized');
lim=axis;
%
%  Initialize flight controls.
%
offset=get(figH,'Position'),
%
%  Convert center position to pixels for 
%  cursor positioning.  
%
hpix=1200;
vpix=1000;
center=[mean(offset([1,3]))*hpix,mean(offset([2,4]))*vpix];
dimen=[(offset(3)-offset(1))*hpix,(offset(4)-offset(2))*vpix];
stick=[0,0];
side=0;
push=0;
%
%  Set up the instrumentation.
%
%  Speedometer.
%
xPos=0.01;
yPos=0.04;
Width=0.05;
Height=0.035;
tPos=[xPos,yPos,Width,Height];
stH=uicontrol('Style','text', ...
              'Units','normalized', ...
              'Position',tPos, ...
              'String','Speed');
sH=uicontrol('Style','edit', ...
             'Units','normalized', ...
             'Position',[xPos,yPos-.04,Width,Height], ...
             'BackgroundColor',[1 1 1], ...
             'Tag','EditText1');
%
%  Altimeter.
%
xPos=0.07;
yPos=0.04;
Width=0.05;
Height=0.035;
tPos=[xPos,yPos,Width,Height];
atH=uicontrol('Style','text', ...
              'Units','normalized', ...
              'Position',tPos, ...
              'String','Altitude');
aH=uicontrol('Style','edit', ...
             'Units','normalized', ...
             'Position',[xPos,yPos-.04,Width,Height], ...
             'BackgroundColor',[1 1 1], ...
             'Tag','EditText2');
%
%  X position.
%
xPos=0.75;
yPos=0.04;
Width=0.07;
Height=0.035;
tPos=[xPos,yPos,Width,Height];
xtH=uicontrol('Style','text', ...
              'Units','normalized', ...
              'Position',tPos, ...
              'String','X Position');
xH=uicontrol('Style','edit', ...
             'Units','normalized', ...
             'Position',[xPos,yPos-.04,Width,Height], ...
             'BackgroundColor',[1 1 1], ...
             'Tag','EditText3');
%
%  Y position.
%
xPos=0.83;
yPos=0.04;
Width=0.07;
Height=0.035;
tPos=[xPos,yPos,Width,Height];
ytH=uicontrol('Style','text', ...
              'Units','normalized', ...
              'Position',tPos, ...
              'String','Y Position');
yH=uicontrol('Style','edit', ...
             'Units','normalized', ...
             'Position',[xPos,yPos-.04,Width,Height], ...
             'BackgroundColor',[1 1 1], ...
             'Tag','EditText4');
%
%  Heading.
%
xPos=0.91;
yPos=0.04;
Width=0.07;
Height=0.035;
tPos=[xPos,yPos,Width,Height];
htH=uicontrol('Style','text', ...
              'Units','normalized', ...
              'Position',tPos, ...
              'String','Heading');
hH=uicontrol('Style','edit', ...
             'Units','normalized', ...
             'Position',[xPos,yPos-.04,Width,Height], ...
             'BackgroundColor',[1 1 1], ...
             'Tag','EditText5');
%
%  Set initial camera position, target, direction, 
%  and view angle.
%
if(~exist('target'))
  target=get(v,'CameraTarget');
end
if(~exist('start'))
  start=get(v,'CameraPosition');
end
camerat=target;
cameral=start;
camerad=unit(camerat - cameral);
camerau=get(v,'CameraUpVector');
%
%  Set the camera up direction perpendicular to the 
%  camera direction from camera position to camera target.
%
camerau = unit(cross(cross(camerad,camerau),camerad));
camerav=fix(get(v,'CameraViewAngle'));
%
%  Set the Projection property so that depth can be 
%  represented with a 2D rendering of 3D information.
%
set(v,'Projection','perspective');
%
%  Initialize camera, which sets all camera modes to manual.
%
set(v,'CameraTarget',camerat);
set(v,'CameraPosition',cameral);
set(v,'CameraViewAngle',camerav);
set(0,'PointerLocation',center);
%
%  Initialize speed control:
%    Left mouse button click decreases speed.
%    Right mouse button click increases speed.
%
SPEED=0.2;
set(figH,'WindowButtonDownFcn','fly_speed;');
%
%
%  Flying loop starts here.  Keyboard interrupts are enabled.
%
while(~strcmp(get(figH,'CurrentCharacter'),'x'))
%
%  Read the stick deflections.
%
  stick = get(0,'PointerLocation');
%
%  Pitch stick input, including deadband.
%
  if(abs(stick(2) - center(2)) > 10)
    push = (stick(2) - center(2))/dimen(2);
  else
    push = 0;
  end
%
%  Lateral stick input, including deadband.
%
  if(abs(stick(1) - center(1)) > 10)
    side = (stick(1) - center(1))/dimen(1);
  else
    side = 0;
  end
%
%  Bank angle.
%
%  Rotate 2 degrees for each lateral stick 
%  position displacement count using the mouse.  
%
  angle = sign(camerad(1))*2*side*dtr;
  camerau = rotat(camerau,camerad,angle);
%
%  Pitch angle.
%
%  Rotate 0.1 degrees for each longitudinal stick 
%  position displacement count using the mouse.  
%
  pitch_vec = cross(camerad,camerau);
  if(pitch_vec(1) == 0)
    angle = -0.1*push*dtr;
  else
    angle = -0.1*sign(pitch_vec(1))*push*dtr;
  end
  camerau = rotat(camerau,pitch_vec,angle);
  camerad = rotat(camerad,pitch_vec,angle);
%
%  Move along the camera direction.   
%
  cameral = cameral + camerad*SPEED; 
%
%  Update the view position.
%
  set(v,'CameraPosition',cameral);
  set(v,'CameraUpVector',camerau);
%
%  Reverse the view direction.
%
  if(strcmp(get(figH,'CurrentCharacter'),'r'))
    camerad=-camerad;
    set(figH,'CurrentCharacter',' ');
    figure(figH);
  end
%
%  Slew the view direction 2 degrees for each key press:
%
%    2 degrees clockwise for 's'
%    2 degrees counterclockwise for 'd'.
%
  if(strcmp(get(figH,'CurrentCharacter'),'s'))
    camerad=camerad - 2*dtr;
    set(figH,'CurrentCharacter',' ');
    figure(figH);
  end
  if(strcmp(get(figH,'CurrentCharacter'),'d'))
    camerad=camerad + 2*dtr;
    set(figH,'CurrentCharacter',' ');
    figure(figH);
  end
%
%  Move the camera target forward to prevent 180 degree spins.
%
  camerat = cameral + camerad*0.2;
  set(v,'CameraTarget',camerat);
%
%  Update instrumentation data.
%
  set(sH,'String',num2str(SPEED));
  set(aH,'String',num2str(round(cameral(3))));
  set(xH,'String',num2str(round(cameral(1))));
  set(yH,'String',num2str(round(cameral(2))));
  set(hH,'String',num2str(round(cart2pol(camerad(1),camerad(2))*rtd)));
%
%  Update the view.  This is where most of the delay occurs.
%
  drawnow;
end
%
%  Reset the button down function and erase the figure.
%
set(figH,'WindowButtonDownFcn','');
close(figH);
fprintf('\n Program Exit \n\n')
return
