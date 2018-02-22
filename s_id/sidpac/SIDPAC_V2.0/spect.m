function [P,f,Y,wdw] = spect(y,t,w,navg,ldw,lplot)
%
%  SPECT  Computes power spectral density estimates for measured time series.  
%
%  Usage: [P,f,Y,wdw] = spect(y,t,w,navg,ldw,lplot);
%
%  Description:
%
%    Estimates the one-sided auto spectral density 
%    using data windowing in the time domain to reduce 
%    leakage, and averaging in the frequency domain to 
%    reduce random error.  The power spectral density 
%    is computed using frequency vector f=w/(2*pi).  The 
%    Fourier transform Y is computed on a fine frequency 
%    grid with navg values inserted between each frequency 
%    point specified in the w vector.  Input navg is 
%    the number of averages used to generate each value 
%    of P at the frequency points specified in the 
%    w vector.  The variance of the power spectral  
%    density estimates = (1/navg)*100 percent
%    of the spectral density estimates.  Inputs w,  
%    navg, and lplot are optional.  The defaults 
%    give the same number of auto spectral density 
%    estimates as time domain points, with variance equal to 
%    10 percent of the estimated auto spectral densities, 
%    with the plot included.  
%
%  Input:
%    
%        y = matrix of time series column vectors.
%        t = time vector.
%        w = frequency vector, rad/sec.
%     navg = number of averages in the frequency domain.  
%      ldw = data windowing flag:
%            = 1 for data windowing (default).
%            = 0 to omit the data windowing. 
%    lplot = plot flag:
%            = 1 for auto spectral density plot (default).
%            = 0 to skip the plot. 
%
%  Output:
%
%    P    = auto spectral density.
%    f    = vector of frequencies corresponding to the elements of P, Hz.
%    Y    = discrete Fourier transform of y on a fine frequency grid.  
%    wdw  = time-domain windowing function.
%

%
%    Calls:
%      cvec.m
%      czts.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      28 Oct 2004 - Created and debugged, EAM.
%      11 Nov 2004 - Modified inputs, EAM.
%      03 Oct 2005 - Corrected frequency vector endpoint treatment, EAM.
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

[npts,n]=size(y);
%
%  Time vector information used for frequency scaling.
%
t=cvec(t);
npts=length(t);
dt=1/round(1/(t(2)-t(1)));
fs=1/dt;
%
%  Turn on plotting when the plotting flag is not specified.
%
if nargin < 6
  lplot=1;
end
%
%  Include data windowing when the 
%  data windowing flag is not specified.
%
if nargin < 5
  ldw=1;
end
%
%  Default inputs.
%
if nargin < 4
  navg=10;
end
if any(size(navg)~=1)
	error('Input navg must be a scalar.')
end
%
%  Assemble the frequency vector.
%
if nargin < 3
  df=1/(npts*dt);
  f=[0:df:fs/2]';
  w=2*pi*f;
else
  w=cvec(w);
  f=w/(2*pi);
  df=f(2)-f(1);
end
nf=length(f);
f1=max(min(f),0);
f2=min(max(f),fs/2);
%
%  Assemble the fine grid frequency vector.
%
%  Make the number of averages odd, 
%  so that the original frequency grid 
%  can be maintained easily. 
%
if mod(navg,2)==0
  navg=navg+1;
end
dff=df/navg;
ff=[f1:dff:f2]';
%
%  If lower limit of the frequency range 
%  is not zero, extend the fine grid 
%  frequency vector, to get full accuracy 
%  at the endpoint frequency f1.  
%
if f1 > 0
  ff=[f1-fix(navg/2)*dff:dff:f2]';
end
%
%  Similarly for the upper limit of the 
%  frequency range f2.  
%
if f2 < fs/2
  ff=[min(ff):dff:f2+fix(navg/2)*dff]';
end
M=length(ff);
%
%  Window the data in the time domain 
%  to mitigate leakage. 
%
if ldw==1
%
%  Hanning window.
%
%  wdw=0.5*(ones(npts,1)-cos(2*pi*[0:1:npts-1]'/(npts-1)));
%
%  Bartlett window.
%
  wdw=ones(npts,1)-abs(([0:1:npts-1]'-(npts/2)*ones(npts,1))/(npts/2));
else
%
%  No data windowing.  
%
  wdw=ones(npts,1);
end
wss=wdw'*wdw;
%
%  Complex step for the chirp z-transform.
%
jay=sqrt(-1);
W=exp(-jay*2*pi*dff*dt);
%
%  Stay on the unit circle in the z-plane,
%  and start at the initial frequency min(ff).  
%
A=1*exp(jay*2*pi*min(ff)*dt);
%
%  Compute the chirp z-transform 
%  for the fine frequency grid.
%
Y=czts(y.*wdw(:,ones(1,n)),M,W,A);
%
%  Compute the raw two-sided auto spectral 
%  density estimates.  Include the normalization 
%  to enforce Parceval's theorem.  
%
Pf=dt*(Y.*conj(Y))*dff;
%
%  Get rid of very small imaginary parts, 
%  due to round-off error.  
%
Pf=real(Pf);
%
%  Average the raw spectral estimates over navg
%  values.  This reduces the variance of the 
%  spectral estimates by a factor of 1/navg.  
%  The resulting frequency spacing is df.
%  Conversion from two-sided to one-sided 
%  spectral density is also done here.    
%
P=zeros(nf,n);
%
%  Adjust the limits for the sums, 
%  depending on whether or not the 
%  frequency vector f includes the
%  special endpoint frequencies at zero 
%  and fs/2.  
%
dj=fix(navg/2);
if f1==0
  jl=navg+1;
  i=2;
else
  jl=dj+1;
  i=1;
end
if f2==fs/2
  ju=M-navg;
else
  ju=M-dj;
end
%
%  Averaging for spectral estimation is a 
%  sum over the fine grid frequency points.
%
for j=jl:navg:ju
  P(i,:)=2*sum(Pf([j-dj:j+dj],:));
  i=i+1;
end
%
%  If the endpoints are either 0 Hz or the 
%  Nyquist frequency, then the two-sided 
%  spectral density need not be doubled, 
%  and only values at frequencies on 
%  one side are available for averaging.
%
if f1==0
  P(1,:)=sum(Pf([1:1+dj],:));
end
if f2==fs/2
  P(nf,:)=sum(Pf([M-dj:M],:));
end
%
%  Scale the spectral estimates using wss so that the sum of the
%  P values equals the mean square value of the time function.
%
P=P/wss;
Y=Y/sqrt(wss);
%
%  Print out the variance accuracy.
%
fprintf('\n\n Variance of the spectral estimates = %5.1f percent \n\n',100/navg)
%
%  Optional auto spectral density plot.
%
if lplot==1
  plot(f,P);
  xlabel('frequency  (Hz)');
  title('Power Spectral Density');
%
%  Scale the abscissa to include only 0 to 3 Hz.
%  Leave ordinate scaling at the default.
%
  v=axis;
  axis([0 3 v(3:4)]);
end
return
