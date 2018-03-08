function [wn,zeta] = damps(a)
%
%  DAMPS  Computes and displays modal damping and natural frequencies.
%
%  Usage: [wn,zeta] = damps(a);
%
%  Description:
%
%    Computes modal damping and natural frequencies for 
%    an input square matrix or transfer fucntion denominator polynomial, 
%    and displays the results.  
%
%  Input:
%    
%    a = square state-space system matrix, or a vector 
%        of coefficients for a transfer function denominator polynomial.
%
%  Output:
%
%      wn = natural frequency, rad/sec.
%    zeta = damping ratio.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      13 Feb 2006 - Created and debugged, EAM.
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
[m,n]=size(a);
if m==1 | n==1
  ev=roots(a);
else
  ev=eig(a);
end
nr=length(ev);
wn=zeros(nr,1);
zeta=zeros(nr,1);
fprintf('\n\n        Eigenvalue            Damping    Frequency (rad/sec)\n'),
for j=1:nr,
  if isreal(ev(j))
    zeta(j)=-sign(ev(j));
    wn(j)=ev(j);
    fprintf('\n%12.3e                  %6.3f       %11.3e ',ev(j),zeta(j),wn(j)),
  else
    wn(j)=sqrt(ev(j)*conj(ev(j)));
    zeta(j)=-real(ev(j))/wn(j);
    fprintf('\n%12.3e  %12.3e    %6.3f       %11.3e ',...
            real(ev(j)),imag(ev(j)),zeta(j),wn(j)),
  end
end
fprintf('\n\n'),
return
