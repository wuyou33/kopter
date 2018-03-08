function [yh,th,uh,xh]=avds_matlab_f16(u0,x0)
%
%  AVDS_MATLAB_F16  Nonlinear simulation using the data interface between AVDS and MATLAB.  
%
%  Usage: [yh,th,uh,xh]=avds_matlab_f16(u0,x0);
%
%  Description:
%
%    This is the AVDS to MATLAB shared memory connection.
%    The aircraft (AC) model is implemented in MATLAB. 
%    Inputs to the AC are sent through shared memory from AVDS to MATLAB.
%    Outputs from the AC are sent through shared memory from MATLAB to AVDS.
%
%
%  To start the simulation:
%
%    1) Start AVDS
%    2) Load the simulation initialization file "f16.sim.ini". From the AVDS 
%       menu select "File->Simulation Init->Open" and choose the file "f16.sim.ini".
%    3) In MATLAB, run the avds_matlab_f16.m script by typing "avds_matlab_f16" (no quotes) 
%       at the MATLAB prompt.  To save the time histories to the MATLAB workspace, 
%       type "[yh,th,uh,xh]=avds_matlab_f16(u0,x0);".  
%    4) In AVDS, choose Simulation Mode and press the "Start" button.
%
%
%  To stop the simulation:
%
%    1) Press the AVDS "Stop" button.
%
%
%  Input:
%    
%     u0 = initial input vector.
%     x0 = initial state vector.
%
%  Output:
%
%     yh = output vector time history = [x, ax (g), ay (g), az (g), 
%                                        pdot (rps2), qdot (rps2), rdot (rps2), thrust (lbf)].
%
%     xh = state vector time history  = [    vt  (ft/sec)
%                                          alpha (rad)
%                                           beta (rad)
%                                            phi (rad)
%                                            the (rad)
%                                            psi (rad)
%                                             p  (rad/sec)
%                                             q  (rad/sec)
%                                             r  (rad/sec)
%                                            xe  (ft)
%                                            ye  (ft)
%                                             h  (ft)  
%                                            pow (percent, 0 <= pow <= 100) ];
%
%     uh = input vector time history = [   thtl  (0 <= thtl <= 1.0)
%                                          stab  (deg)
%                                           ail  (deg)
%                                           rdr  (deg) ];
%
%     th = time vector with sample times for yh, xh, and uh.  
%

%
%    Calls:
%      f16_massprop.m
%      f16_aero_setup.m
%      f16_engine_setup.m
%      atm.m
%      f16_deq.m
%      SimulationConnection.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      09 Apr  2001 - Created and debugged, revision 1.3, Steve Rasmussen.
%      18 Jul  2001 - Modified to use constant time step and  
%                     3rd order Adams-Bashforth numerical integration, 
%                     repaired engine output scaling, 
%                     generalized control scaling, 
%                     scaled controls for display, 
%                     added acceleration outputs, 
%                     reduced control surface travel 
%                     for easier open-loop flying, EAM.
%      20 Jul  2001 - Modified to use quasi-constant simulation dt
%                     matched to real time, to automatically 
%                     account for computer/video speed and 
%                     numerical integration algorithm, EAM.
%      21 Jul  2001 - Added comments, eliminated x and y position input from AVDS,
%				              added procedure to reset alpha and beta to travel 
%                     between +/- 180 deg only, FRG.  
%      20 Aug  2001 - Cleared Outputvector with zeros, FRG.
%      05 Nov  2001 - Started 3rd order Adams-Bashorth with 2nd order Runge-Kutta, FRG.
%      28 Jan  2004 - Added time history outputs at constant sampling intervals, EAM.  
%      25 Feb  2006 - Updated for F-16 NLS version 1.1, EAM.
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

%
%
%  Set up simulation parameters.
%
%
%  This is the connection ID number 
%  for the MATLAB_AC aircraft in AVDS.
%
ConnectionID = 2;
%
%  Define the indices for the input vector:
%
InRunning = 1; 
IndStabilator = 2; 	
IndAileron = 3; 	
IndRudder = 4;	
IndThrottle = 5; 
InElapsedTime = 6;
%
%  The following indicies in the input vector 
%  have not been used by this Aircraft, 
%  and can be used to receive other signals from AVDS:
%
InToMATLAB01 = 7;	  
InToMATLAB02 = 8;	  InToMATLAB03 = 9;	  
InToMATLAB04 = 10;	InToMATLAB05 = 11;	
InToMATLAB06 = 12;	InToMATLAB07 = 13;	
InToMATLAB08 = 14;	InToMATLAB09 = 15;	
InToMATLAB10 = 16;	
%
%  Total size of input (from AVDS) vector, must be the same 
%  size as the definition found in the 
%  SimulationConnection function for the AC type.
%
%  Intitialize input vector - the contents of this vector will be received from AVDS.
%
InputVector = zeros(16,1);  
%
%  Define the indices for the output vector:
%
OutPositionX = 1;	OutPositionY = 2;	OutPositionZ = 3;
OutRotationX = 4;	OutRotationY = 5;	OutRotationZ = 6;
OutAlpha  = 7;	  OutBeta  = 8;
OutG  = 9;
OutVelocity  = 10;
OutM  = 11;
OutDeltaRudder  = 12;	OutDeltaStabilator  = 13;	OutDeltaAileron  = 14;
OutEngine = 15;
%
%  The following indices in the output vector have not been used by this aircraft, 
%  and can be used to send other signals to AVDS:
%
OutToAVDS01 = 16; 
OutToAVDS02 = 17; OutToAVDS03 = 18; OutToAVDS04 = 19; 
OutToAVDS05 = 20; OutToAVDS06 = 21; OutToAVDS07 = 22; 
OutToAVDS08 = 23; OutToAVDS09 = 24; OutToAVDS10 = 25;
%
%  Total size of output (to AVDS) vector, must be the same size as the defintion found 
%  in the SimulationConnection function for the AC type:
%
%  Intitialize output vector - the contents of this vector will be sent to AVDS
%
OutputVector = zeros(25,1);
WasRunning = 0;	% flag to prevent exit before simulation has run once.
%
%  Mass/inertia properties, aerodynamic data and engine data initialization.  
%
c=f16_massprop; 
f16_aero_setup;
f16_engine_setup;  
tpi=2*pi;
%
%  Physical limits on the controls.
%
thtl_lim=1;
stab_lim=25;
ail_lim=21.5;
rdr_lim=30;
%
%  Control surface deflections are displayed 
%  at cdfac times the actual values.  
%
cdfac=1;
%
% Stick gains for smoother open-loop flying.
%
thtl_gain=1;
stab_gain=0.8;
ail_gain=0.8;
rdr_gain=0.8;
%
%  AVDS joystick calibration constants to 
%  normalize the joystick inputs from AVDS 
%  to the range [-1,1], and the throttle input
%  from AVDS to [0,1].  These ranges apply  
%  for the AVDS joystick scale factor
%  and bias settings below:
%
%  X-scale:  2     Bias: -0.50
%  Y-scale:  2     Bias: -0.50
%  Z-scale:  1     Bias:  0.00
%  R-scale: -2     Bias: -0.50
%
stk_cal=[1;...
         1;...
         0.76335877862595;...
         5.26315789473684];
%
%  Minimum and maximum values from the
%  joystick for range testing.  
%
%umax=-999*ones(length(stk_cal),1);
%umin=999*ones(length(stk_cal),1);
%
%  Loop counter is nloops, and dt is re-computed to 
%  correspond to real time through each loop.  
%
nloops=0;
%
%  Open the AVDS shared memory link
%
SimulationConnection('OpenConnection',ConnectionID,'AC');
%
%  Initialization flag.
%
init=0;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%       Simulation Main Loop      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
while 1	% loop until the break is encountered
%
%  Retrive input vector from AVDS (from shared memory link).
%
  InputVector = SimulationConnection('ReceiveData',ConnectionID);
%
%  The signal InputVector(InRunning) is a flag that tests 
%  whether AVDS is running in Simulation mode (1) or not (0).
%  The "WasRunning" flag is used to know when to stop the simulation.
%
  if ((InputVector(InRunning) == 0) & (WasRunning == 1)),
%
%  If the simulation has run and the alive flag is set to zero, 
%  stop the simulation  (Alive flag is set to 1 when AVDS is 
%  operating in Simulation mode).
%
%  Zero the Outputvector and sends to AVDS to clear Sharedfiles. 
%
    OutputVector = zeros(25,1);
    SimulationConnection('SendData',ConnectionID,OutputVector);
    break;	
  elseif (InputVector(InRunning) == 1),	
%
%  If AVDS is running in Simulation mode.
%
    WasRunning = 1;
%
%  Initialize the first time through.
%
    if (init==0)
%
%  Wait for AVDS to catch up, then get the input.
%
      pause(0.1);
      InputVector = SimulationConnection('ReceiveData',ConnectionID);
%
%  Numerical integration initialization.
%
      k=[23/12,-16/12,5/12]';
      xdp=zeros(13,3);
      xd1=zeros(13,1);
      xd2=zeros(13,1);
      simtime=0;
      dt=0.025;
%
%  State and control vector initialization.
%
      xl=zeros(13,1);
      x=zeros(13,1);
      ul=zeros(4,1);
      u=zeros(4,1);
      xl(1)=InputVector(InToMATLAB07)*1.689; % vt (knots to ft/sec conversion)
      xl(2)=InputVector(InToMATLAB10); % beta (rad)   
      xl(3)=InputVector(InToMATLAB09); % alpha (rad)
      xl(4)=0; % p initialized to 0 rad/sec
      xl(5)=0; % q initialized to 0 rad/sec
      xl(6)=0; % r initialized to 0 rad/sec
      xl(7)=InputVector(InToMATLAB04)*pi/180.0; % phi (deg to rad conversion)  
      xl(8)=InputVector(InToMATLAB05)*pi/180.0; % theta (deg to rad conversion)
      xl(9)=InputVector(InToMATLAB06)*pi/180.0; % psi (deg to rad conversion)
      xl(10)=0; % x starting position (ft)
      xl(11)=0; % y starting position (ft)
      xl(12)=InputVector(InToMATLAB03); % altitude starting position (ft)
%
%  Engine power input from AVDS ranges from 0-2, 
%  which is converted to 0-100 percent.  
%
      xl(13)=InputVector(InToMATLAB08)*100/2; 
%
%  Variables used to subtract initial alt, phi, theta, and psi from 
%  values sent to AVDS for display (this is a work-around for an AVDS bug). 
%
      b=xl(7);
      e=xl(8);
      d=xl(9);
      a=xl(12);
      if exist('x0','var')
        xl=x0;
      end
%
%  Control vector initialization.
%
      if ~exist('u0','var')
        u0=zeros(4,1);
      end
      stk=stk_cal.*[InputVector(IndThrottle); ...
	                  InputVector(IndStabilator); ...
	                  InputVector(IndAileron); ...
                    InputVector(IndRudder)];
%      ul=[max([0,min([thtl_lim*stk(1),thtl_lim])]); ...
%          max(stab_gain*[-stab_lim,min([stab_lim*stk(2),stab_lim])]); ...
%          max(ail_gain*[-ail_lim,min([ail_lim*stk(3),ail_lim])]); ...
%          max(rdr_gain*[-rdr_lim,min([rdr_lim*stk(4),rdr_lim])])];
      ul=[max([0,min([thtl_lim*stk(1),thtl_lim])]); ...
          max(stab_gain*[-stab_lim,min([stab_lim*stk(2)+u0(2),stab_lim])]); ...
          max(ail_gain*[-ail_lim,min([ail_lim*stk(3)+u0(3),ail_lim])]); ...
          max(rdr_gain*[-rdr_lim,min([rdr_lim*stk(4)+u0(4),rdr_lim])])];
%
%  Set up initial output vector to be sent to AVDS
%  for initialization.  
%
   	  OutputVector(OutPositionX) = xl(10);
   	  OutputVector(OutPositionY) = xl(11);
%
%  Initial alt, phi, theta, and psi subtracted from 
%  current values for correct display in AVDS (this is a work-around for AVDS bug). 
%
      OutputVector(OutPositionZ) = xl(12)-a;
      OutputVector(OutRotationX) = (xl(7)-b)*pi/180; % phi (rad to rad conversion) (work-around for another AVDS bug)
      OutputVector(OutRotationY) = (xl(8)-e)*pi/180; % theta (rad to rad conversion) (work-around for another AVDS bug)
      OutputVector(OutRotationZ) = -(xl(9)-d)*pi/180; % psi (rad to rad conversion) (work-around for another AVDS bug)
      OutputVector(OutAlpha) = xl(3);
      OutputVector(OutBeta) = xl(2);
      OutputVector(OutG) = cos(xl(7))*cos(xl(8));
     	OutputVector(OutVelocity) = xl(1);
      mach=atm(xl(1),xl(12));
     	OutputVector(OutM) = mach;
%
%  Exaggerate the displayed control surface motion by a factor of cdfac.
%
      OutputVector(OutDeltaStabilator) = ul(2)*cdfac*pi/180.0; % port stabilator deflection (deg to rad conversion)
      OutputVector(OutDeltaAileron) = -ul(3)*cdfac*pi/180.0; % port aileron deflection (deg to rad conversion)
      OutputVector(OutDeltaRudder) = -ul(4)*cdfac*pi/180.0; % rudder deflection (deg to rad conversion)
      OutputVector(OutEngine) = 2*xl(13)/100; % engine range is 0-2 for 0-100 percent.
%      OutputVector(OutEngine) = 2*stk(1); % engine range is 0-2 for 0-100 percent.
%
%  The next two outputs are used to delflect the respective starboard control effectors.
%
     	OutputVector(OutToAVDS01) = -ul(2)*cdfac*pi/180.0; % starboard stabilator deflection (deg to rad conversion)
     	OutputVector(OutToAVDS02) = ul(3)*cdfac*pi/180.0; % starboard aileron deflection (deg to rad conversion)
%
%  Send output vector to AVDS.
%
      SimulationConnection('SendData',ConnectionID,OutputVector);
%
%  Real time and AVDS time initialization.
%
      t0=clock;
      tl=t0;
      time0=InputVector(InElapsedTime);
%
%  Initialization complete.
%
      init=1;
    end
%
%  Get the input from the joystick.
%
    stk=stk_cal.*[InputVector(IndThrottle); ...
	                InputVector(IndStabilator); ...
	                InputVector(IndAileron); ...
                  InputVector(IndRudder)];
%
%  Input limiting and control gains.
%
%    u=[max([0,min([thtl_lim*stk(1),thtl_lim])]); ...
%       max(stab_gain*[-stab_lim,min([stab_lim*stk(2),stab_lim])]); ...
%       max(ail_gain*[-ail_lim,min([ail_lim*stk(3),ail_lim])]); ...
%       max(rdr_gain*[-rdr_lim,min([rdr_lim*stk(4),rdr_lim])])];
    u=[max([0,min([thtl_lim*stk(1),thtl_lim])]); ...
       max(stab_gain*[-stab_lim,min([stab_lim*stk(2)+u0(2),stab_lim])]); ...
       max(ail_gain*[-ail_lim,min([ail_lim*stk(3)+u0(3),ail_lim])]); ...
       max(rdr_gain*[-rdr_lim,min([rdr_lim*stk(4)+u0(4),rdr_lim])])];
%
%  Stick input range testing.
%
%    for j=1:length(u),
%      if u(j)>umax(j)
%        umax(j)=u(j);
%      end
%      if u(j)<umin(j)
%        umin(j)=u(j);
%      end
%    end
%
%  Numerical integration - 3rd order Adams-Bashforth
%  starting with 2nd order Runge-Kutta for initial steps.
%
    if nloops < 2
      xd1=f16_deq(ul,xl,c);
      if nloops == 0
        xdp=xd1*ones(1,3);
      else
        xdp(:,[2:3])=xdp(:,[1:2]);
        xdp(:,1)=xd1;
      end
      xint=xl+dt*xd1/2;
      uint=(ul+u)/2;
      [xd2,accel,thrust,qbar,mach]=f16_deq(uint,xint,c);
      x=xl+dt*xd2;
      xdp(:,2-nloops)=f16_deq(u,x,c);
    else
      xdp(:,[2:3])=xdp(:,[1:2]);
      [xdp(:,1),accel,thrust,qbar,mach]=f16_deq(u,xl,c);
      x=xl + dt*xdp*k;
    end
%
%  Numerical integration - 2nd order Runge-Kutta.
%
%    xd1=f16_deq(ul,xl,c);
%    xint=xl+dt*xd1/2;
%    uint=(ul+u)/2;
%    [xd2,accel,thrust,qbar,mach]=f16_deq(uint,xint,c);
%    x=xl+dt*xd2;
%
%  Numerical integration - Euler.  
%
%    uint=(ul+u)/2;
%    [xd1,accel,thrust,qbar,mach]=f16_deq(uint,xl,c);   
%    x=xl+dt*xd1;
%    
%  Keep alpha and beta in the proper range:
%  +/- 180 deg (+/- 2*pi rad) 
%
    alpha_res=x(3)/tpi-fix(x(3)/tpi);
    if (alpha_res > 0.5 & alpha_res < 1)
      x(3)=tpi*(alpha_res-1);
    elseif (alpha_res < -0.5 & alpha_res > -1)
      x(3)=tpi*(alpha_res+1);
    else 
      x(3)=tpi*alpha_res;
    end
    beta_res=x(2)/tpi-fix(x(2)/tpi);
    if (beta_res > 0.5 & beta_res < 1)
      x(2)=tpi*(beta_res-1);
    elseif (beta_res < -0.5 & beta_res > -1)
      x(2)=tpi*(beta_res+1);
    else 
      x(2)=tpi*beta_res;
    end
%
%  Keep Euler angles in the proper range.  
%
    x(7)=(x(7)/(tpi)-fix(x(7)/(tpi)))*tpi;
    x(8)=(x(8)/(tpi)-fix(x(8)/(tpi)))*tpi;
    x(9)=(x(9)/(tpi)-fix(x(9)/(tpi)))*tpi;
%
%  Set up output vector to be sent to AVDS.
%
   	OutputVector(OutPositionX) = x(10);
   	OutputVector(OutPositionY) = x(11);
%
%  Initial alt, phi, theta, and psi subtracted from 
%  current values for correct display in AVDS (this is a work-around for AVDS bug). 
%
    OutputVector(OutPositionZ) = x(12)-a;
    OutputVector(OutRotationX) = (x(7)-b)*pi/180; % phi (rad to rad conversion) (work-around for another AVDS bug)
    OutputVector(OutRotationY) = (x(8)-e)*pi/180; % theta (rad to rad conversion) (work-around for another AVDS bug)
    OutputVector(OutRotationZ) = -(x(9)-d)*pi/180; % psi (rad to rad conversion) (work-around for another AVDS bug)
    OutputVector(OutAlpha) = x(3);
    OutputVector(OutBeta) = x(2);
    OutputVector(OutG) = -accel(3);
   	OutputVector(OutVelocity) = x(1);
   	OutputVector(OutM) = mach;
%
%  Exaggerate the displayed control surface motion by a factor of cdfac.
%
    OutputVector(OutDeltaStabilator) = u(2)*cdfac*pi/180.0; % port stabilator deflection (deg to rad conversion)
    OutputVector(OutDeltaAileron) = -u(3)*cdfac*pi/180.0; % port aileron deflection (deg to rad conversion)
    OutputVector(OutDeltaRudder) = -u(4)*cdfac*pi/180.0; % rudder deflection (deg to rad conversion)
    OutputVector(OutEngine) = 2*x(13)/100; % engine range is 0-2 for 0-100 percent.
%
%  The next two outputs are used to delflect the respective starboard control effectors.
%
   	OutputVector(OutToAVDS01) = -u(2)*cdfac*pi/180.0; % starboard stabilator deflection (deg to rad conversion)
   	OutputVector(OutToAVDS02) = u(3)*cdfac*pi/180.0; % starboard aileron deflection (deg to rad conversion)
%
%  Send output vector to AVDS.
%
    SimulationConnection('SendData',ConnectionID,OutputVector);
%
%  Get ready for the next iteration.
%
    xl=x;
    ul=u;
    nloops=nloops+1;
%
%  Check if AVDS time warrants another integration time step.
%
    simtime=simtime+dt;
    AVDStime=InputVector(InElapsedTime)-time0;
    realtime=etime(clock,t0);
    looptime=etime(clock,tl);
    tl=clock;
%     fprintf('\n\n MATLAB sim time = %7.3f ',simtime)
%     fprintf('\n AVDS time = %7.3f ',AVDStime)
%     fprintf('\n Real time = %7.3f ',realtime)
%     fprintf('\n Loop time = %7.3f ',looptime)
%     looptime=(InputVector(InElapsedTime)-time0)/nloops;
%
%  Save the input vector, output vector, 
%  state vector, and time.
%
%     uh(nloops,:)=stk';
    uh(nloops,:)=u';
    yh(nloops,:)=[x',accel',thrust];
    xh(nloops,:)=x';
    th(nloops)=simtime;
%
%  Adjust the simulation integration time step
%  to match the real time required to get through 
%  the simulation loop.  
%
    dt=max(0.001,min(looptime,0.025));
  end	%  elseif (InputVector(1) == 1),	
end %  while 1,
%
%  Print out simulation run metrics.
%
fprintf('\n Average dt = %7.4f sec ',simtime/nloops)
fprintf('\n Average loop time = %8.4f sec ',realtime/nloops)
fprintf('\n (Real time)/(Sim Time) = %6.3f ',realtime/simtime)
%
%  Close the connection with AVDS.
%
SimulationConnection('CloseConnection');
%
%  Make time a column vector, and 
%  correct for the offset resulting 
%  from the first integration step.
%
th=cvec(th)-th(1);
%
%  Interpolate the data to fixed and uniform 
%  sampling intervals.
%
dt=0.025;
ti=[0:dt:dt*fix(max(th)/dt)]';
ui=interp1(th,uh,ti,'linear');
yi=interp1(th,yh,ti,'linear');
xi=interp1(th,xh,ti,'linear');
th=ti;
uh=ui;
yh=yi;
xh=xi;
fprintf('\n Maneuver length = %7.3f sec \n\n',max(th))
return
