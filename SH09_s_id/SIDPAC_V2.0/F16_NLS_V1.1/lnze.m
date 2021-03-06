function [A,B,C,D] = lnze(fname,u,x,c,iu,ix,pert)
%
%  LNZE  Generates local linear dynamic system models using finite differences.  
%
%  Usage: [A,B,C,D] = lnze(fname,u,x,c,iu,ix,pert);
%
%  Description:
%
%    Computes linear constant coefficient system matrices 
%    from a nonlinear system using central finite differences.
%    The system of nonlinear equations is specified 
%    in the file named fname.  
%
%  Input:
%
%     fname = name of the file that computes the vector function values.
%         u = nominal control vector.
%         x = nominal state vector.
%         c = vector or data structure of constants passed to fname.
%        iu = index vector indicating which controls are to be included
%             and in what order.
%        ix = index vector indicating which states are to be included
%             and in what order.
%      pert = scalar for state and control perturbations, 
%             fraction of the nominal value.
%
%  Output:
%
%    A,B,C,D = linear system matrices.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      18 Aug  1995 - Created and debugged, EAM.
%      02 July 2001 - Repaired failure to restore perturbed values, EAM.
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
pert=abs(pert(1));
%
%  Determine the selected number of states and controls.
%
maxx=length(ix);
maxu=length(iu);
ns=0;
ni=0;
for i=1:maxx,
  if ix(i)~=0, 
    ns=ns+1;
  end
end
for i=1:maxu,
  if iu(i)~=0,
    ni=ni+1;
  end
end
%
%  Linearization loop.
%
A=zeros(ns,ns);B=zeros(ns,ni);
xo=x;uo=u;
%
%  First the A matrix.
%
for j=1:maxx,
  if ix(j)~=0,
    k=ix(j);
    if pert>abs(xo(k)),
      dx=pert;
    else
      dx=pert*xo(k);
    end
    x(k)=xo(k)+dx/2.;
    fp=eval([fname,'(u,x,c)']);
    x(k)=xo(k)-dx/2.;
    fm=eval([fname,'(u,x,c)']);
%
%  Restore perturbed state.
%
    x(k)=xo(k);
    for i=1:ns,
      A(i,j)=(fp(ix(i))-fm(ix(i)))/dx;
    end
  end
end
%
%  Now the B matrix.
%
for j=1:maxu,
  if iu(j)~=0
    k=iu(j);
    if pert>abs(uo(k)),
      du=pert;
    else
      du=pert*uo(k);
    end
    u(k)=uo(k)+du/2.;
    fp=eval([fname,'(u,x,c)']);
    u(k)=uo(k)-du/2.;
    fm=eval([fname,'(u,x,c)']);
%
%  Restore perturbed control.
%
    u(k)=uo(k);
    for i=1:ns,
      B(i,j)=(fp(ix(i))-fm(ix(i)))/du;
    end
  end
end  
%
%  Assume states and outputs are identical. 
%
C=eye(ns);D=zeros(ns,ni);
return
