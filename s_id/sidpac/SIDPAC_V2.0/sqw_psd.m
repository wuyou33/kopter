function [P,f,U] = sqw_psd(u,t,w,lplot)
%
%  SQW_PSD  Analytically computes the power spectra of square waves.  
%
%  Usage: [P,f,U] = sqw_psd(u,t,w,lplot);
%
%  Description:
%
%    Computes the power spectrum of an input 
%    square wave u, associated with time vector t. 
%    The power spectrum is computed analytically, 
%    and assumes a pure square wave with no 
%    rate limiting.  Also draws a plot of the 
%    square wave with the power spectrum, according 
%    to the input lplot. 
%
%  Input:
%
%       u = square wave input vector.  
%       t = time vector.
%       w = frequency vector, rad/sec.
%   lplot = plot flag (optional):
%           = 1 for plots.
%           = 0 to skip the plots (default). 
%
%  Output:
%
%       P = power spectral density, amp^2/Hz.
%       f = frequency vector for P, Hz.
%       U = Fourier integral of u for frequency vector w.
%

%
%    Calls:
%      cvec.m
%      sqw_tap.m
%
%    Author:  Eugene A. Morelli
%
%    History: 
%      11 June 2003 - Created and debugged, EAM.
%      10 Nov  2004 - Added input frequency vector
%                     and plot flag, EAM.
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
u=cvec(u);
npts=length(u);
%
%  Turn on plotting when the plotting flag is not specified.
%
if nargin < 4
  lplot=0;
end
%
%  Get the square wave amplitudes and 
%  transition points.  
%
[amp,tsw,dt,tmax]=sqw_tap(u,t);
nsw=length(tsw);
%
%  Define the frequency vector.
%
w=cvec(w);
f=w/(2*pi);
nf=length(f);
df=f(2)-f(1);
findx=find(f~=0);
nnzf=length(findx);
%
%  Special calculation for zero frequency.
%
zindx=find(f==0);
dw=2*pi*df;
jw=sqrt(-1)*w(findx);
%
%  Compute the Fourier transform analytically for each pulse, 
%  then add up the results.  
%
U=zeros(nf,1);
%
%  Fourier transform at non-zero frequencies 
%  for pulses of the square wave. 
%
tp1=tsw(1)+dt/2;
for j=2:nsw,
  tp2=tsw(j)+dt/2;
  U(findx)=U(findx) + amp(j)*(ones(nnzf,1)./jw).*(exp(-jw*tp1) - exp(-jw*tp2));
%
%  Different expression for the integral
%  when the frequency is zero.
%
  if ~isempty(zindx)
    U(zindx)=U(zindx) + amp(j)*(tp2-tp1)*ones(length(zindx),1);
  end
  tp1=tp2;
end
%
%  The Fourier integral is related to 
%  the discrete Fourier transform by 
%  the sampling interval dt. 
%
U=U/dt;
%
%  Scale the power spectrum so that 
%  the sum of the spectral components
%  equals the mean square amplitude 
%  in the time domain.  This enforces 
%  Parceval's theorem.  
%
P=zeros(nf,1);
P(findx)=2*dt*real(U(findx).*conj(U(findx)))*df/npts;
P(zindx)=dt*U(zindx).*U(zindx)*df/npts;
%
%  Plot the results.
%
if lplot==1
  subplot(2,1,1),plot(t,u),grid on,
  subplot(2,1,2),plot(f,P),grid on,
end
return
