% Variables output from the model

% State vector elements are states:
%        x(1)  = true airspeed, vt  (fps). 
%        x(2)  = sideslip angle, beta  (rad).
%        x(3)  = angle of attack, alpha  (rad). 
%        x(4)  = roll rate, p (rps).
%        x(5)  = pitch rate, q (rps).
%        x(6)  = yaw rate, r  (rps).
%        x(7)  = roll angle, phi  (rad).
%        x(8)  = pitch angle, the  (rad).
%        x(9)  = yaw angle, psi  (rad).
%        x(10) = xe  (ft)
%        x(11) = ye  (ft)
%        x(12) = h   (ft)  
%        x(13) = pow (percent, 0 <= pow <= 100)


% Forces
% CX,CY,CZ,C1,Cm,Cn

% Accels
% ax, ay, az, \dot{p}, \dot{q}, \dot{r}

% Inputs
%        u(1) = throttle input, thtl  (fraction of full power, 0 <= thtl <= 1.0).
%        u(2) = stabilator input, stab  (deg).
%        u(3) = aileron input, ail  (deg).
%        u(4) = rudder input, rdr  (deg)