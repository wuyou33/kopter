function [y,x,A,B,C,D] = tlonsssl(p,u,t,x0,c)
%
%  TLONSSSL  Simulink equivalent of tlonss.m
%
%  Usage: [y,x,A,B,C,D] = tlonsssl(p,u,t,x0,c);
%
%  Description:
%
%    Model file for longitudinal state-space
%    dynamic model in the time domain, 
%    using the simulink model ss_model.mdl. 
%
%  Input:
%
%     p = parameter vector.
%     u = input vector or matrix.
%     t = time vector.
%    x0 = initial state vector.
%     c = vector of constants.
%
%  Output:
%
%         y = model output vector or matrix time history.
%         x = model state vector or matrix time history.
%   A,B,C,D = system matrices.

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      01 Feb 2006 - Created and debugged, EAM.
%      09 Jun 2006 - Standardized constants, EAM.
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
%  Longitudinal short period approximation.
%
A=[p(1),p(2);...
   p(5),p(6)];
B=[p(3),p(4);...
   p(7),p(8)];
[ns,ni]=size(B);
C=eye(2,2);
[no,ns]=size(C);
D=zeros(no,ni);
%
%  Add vertical accelerometer output.
%
C=[C;[p(1),p(2)-1]*c.vog];
D=[D;[p(3)*c.vog,p(9)]];
%
%  A Simulink state-space model file with 
%  the correct dimensions must be open in Simulink 
%  for this to work.  
%
set_param('ss213_model/State-Space','A',mat2str(A));
set_param('ss213_model/State-Space','B',mat2str(B));
set_param('ss213_model/State-Space','C',mat2str(C));
set_param('ss213_model/State-Space','D',mat2str(D));
set_param('ss213_model/State-Space','x0',mat2str(x0));
[t,x,y]=sim('ss213_model',[],[],[t,u]);
return