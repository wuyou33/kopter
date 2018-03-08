function pt = ptrans(p,ldir)
%
%  PTRANS  Translates parameters for longitudinal LOES models.
%
%  Usage: pt = ptrans(p,ldir);
%
%  Description:
%
%    For longitudinal low order equivalent system (LOES) models, 
%    this routine translates parameter vectors as follows:
%
%      ldir = 1 : 
%        translate parameters from transfer function form to state space form.
%      ldir = -1 :
%        translate parameters from state space form to transfer function form.
%
%    Transfer function parameter vector: [b1,b0,a1,a0,tau]'
%    State space parameter vector: [La,Ma,Mq,Md,tau]'
%
%  Input:
%    
%       p = parameter vector to be translated. 
%    ldir = translation direction parameter:
%         =  1 for transfer function to state space.
%         = -1 for state space to transfer function.
%
%  Output:
%
%      pt = translated parameter vector.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      25 Feb 2002 - Created and debugged, EAM.
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
np=length(p);
pt=zeros(np,1);
%
%  State space to transfer function.
%
if ldir < 0
  pt(1)=p(4);
  pt(2)=p(4)*p(1);
  pt(3)=p(1)-p(3);
  pt(4)=-(p(3)*p(1)+p(2));
  pt(5)=p(5);
else
%
%  Transfer function to state space. 
%
  pt(1)=p(2)/p(1);
  pt(4)=p(1);
  pt(3)=-p(3)+pt(1);
  pt(2)=-p(4)-pt(1)*pt(3);
  pt(5)=p(5);
end
return
