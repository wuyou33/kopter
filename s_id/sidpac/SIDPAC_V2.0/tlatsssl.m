function [y,x,A,B,C,D] = tlatsssl(p,u,t,x0,c)
%
%  TLATSSSL  Simulink equivalent of tlatss.m
%
%  Usage: [y,x,A,B,C,D] = tlatsssl(p,u,t,x0,c);
%
%  Description:
%
%    Model file for lateral state-space
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
%      02 Feb 2006 - Created and debugged, EAM.
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
%  Lateral model.  
%
A=[p(1),c.sa,-c.ca,c.dgdp;...
   p(4),p(5),p(6),0;...
   p(10),p(11),p(12),0;...
   0,1,c.tt,0];
B=[p(2),0,p(3);...
   p(7),p(8),p(9);...
   p(13),p(14),p(15);...
   0,0,p(16)];
C=[1,0,0,0;...
   0,1,0,0;...
   0,0,1,0;...
   0,0,0,1;...
   p(1)*c.vog,0,0,0];
D=[0,0,0;...
   0,0,0;...
   0,0,0;...
   0,0,0;...
   p(2)*c.vog,0,p(17)];
%
%  A Simulink state-space model file with 
%  the correct dimensions must be open in Simulink 
%  for this to work.  
%
set_param('ss435_model/State-Space','A',mat2str(A));
set_param('ss435_model/State-Space','B',mat2str(B));
set_param('ss435_model/State-Space','C',mat2str(C));
set_param('ss435_model/State-Space','D',mat2str(D));
set_param('ss435_model/State-Space','x0',mat2str(x0));
[t,x,y]=sim('ss435_model',[],[],[t,u]);
return