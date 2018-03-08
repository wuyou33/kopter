function [mag,ph,f,coh,Puy,Pyy,Puu,Y,U] = fresp(u,y,t,npart,lplot)
%
%  FRESP  Computes the frequency response from measured input-output data.  
%
%  Usage: [mag,ph,f,coh,Puy,Pyy,Puu,Y,U] = fresp(u,y,t,npart,lplot);
%
%  Description:
%
%    Estimates the single input single output (SISO) frequency
%    response and ordinary coherence using data windowing in the time domain.  
%    The power spectra are computed using frequency resolution 
%    determined by the first power of two higher than the length
%    of y.  Frequency range is [0,fs/2).
%
%  Input:
%    
%    u     = input time history vector.
%    y     = output time history vector.
%    t     = time vector.
%    npart = number of partitions for the time domain data = a power of 2.
%    lplot = plot flag:
%            = 1 for auto spectral density plot.
%            = 0 to skip the plot. 
%
%  Output:
%
%    mag = transfer function magnitude, db.
%    ph  = straightened phase angle, deg.
%    f   = frequency vector, Hz.
%    coh = ordinary coherence.
%    Puy = cross spectral density.
%    Pyy = output auto spectral density.
%    Puu = input auto spectral density.
%    Y   = two-sided output discrete Fourier transform.
%    U   = two-sided input discrete Fourier transform.
%

%
%    Calls:
%      spect.m
%      bodeplt.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      12 Apr 1996 - Created and debugged, EAM.
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
y=y(:,1);
npts=length(y);
u=u([1:npts],1);
%
%  Set the plotting flag to zero when not specified.
%
if nargin < 5
  lplot=0;
end
%
%  Find the auto spectral densities and discrete Fourier transforms.
%
[Pyy,f,Y,wdw]=spect(y,t,npart);
[Puu,f,U,wdw]=spect(u,t,npart);
[nf,ndw]=size(Y);
nfft=round(2*(nf-1));
wss=nfft*(wdw'*wdw);
%
%  Compute the cross spectral density, normalized so that
%  the power spectral density is one-sided.
%
Puy=2*(conj(U).*Y);
%
%  The Fourier transform is one-sided for zero frequency
%  and the Nyquist frequency only. 
%
Puy(1,:)=conj(U(1,:)).*Y(1,:);
Puy(nf,:)=conj(U(nf,:)).*Y(nf,:);
%
%  Average the individual cross spectral densities to
%  reduce the variance of the spectral estimates
%  by a factor of 9*ndw/11.  Finally, normalize the cross 
%  spectral estimates using wss.
%
if ndw>1
  Puy=mean(Puy')'/wss;
else
  Puy=Puy/wss;
end
%
%  Compute the transfer function magnitude, phase, and coherence.
%
tf=Puy./Puu;
mag=20*log10(abs(tf));
ph=atan2(imag(tf),real(tf))*180/pi;
coh=(Puy.*conj(Puy))./(Puu.*Pyy);
%
%  Optional bode plot, limited to 10 rad/sec maximum frequency.
%
if lplot==1
  indx=find(2*pi*f<=10.0);
  bodeplt(2*pi*f(indx),mag(indx),ph(indx))
end
return
