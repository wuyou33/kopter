function [c,lags] = xcorrs(x,y,opt)
%
%  XCORRS  Cross-correlation estimate for time series.
%
%  Usage: [c,lags] = xcorrs(x,y,opt);
%
%  Description:
%
%    Computes cross-correlation of time series x and y 
%    using the fast Fourier transform convolution method.
%    If y is omitted, the auto-correlation of x is computed.
%
%  Input:
%    
%     x = time series vector. 
%     y = time series vector (optional). 
%   opt = calculation option (optional):
%         = 'unbiased' for 1/(N-abs(k)) scaling (default).
%         = 'biased" for 1/N scaling.
%
%  Output:
%
%      c = cross-correlation of x and y;
%          auto-correlation of x, if y is omitted.  
%

%
%    Calls:
%      cvec.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      06 Feb 2006 - Created and debugged, EAM.
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
dstr='unbiased';
if nargin==1
  opt=dstr;
  y=x;
elseif nargin==2
  if isstr(y)
    opt=y;
    y=x;
  else
    opt=dstr;
  end
else
  if ~isstr(opt)
    opt=dstr;
  end
end
if size(x,1)~=size(y,1)
  fprintf('\n\n Data dimension mismatch in xcorrs.m \n\n\n')
  return
end
[N,nr]=size(x);
nc=size(y,2);
%
%  Add zero padding for FFT to avoid 
%  spoiling results near the endpoints
%  when using the convolution.
%
nfft = 2.^(ceil(log(2*N)/log(2)));
xdata=[x;zeros(nfft-N,nr)];
ydata=[y;zeros(nfft-N,nc)];
%
%  Compute the FFT of x and y.
%
X=fft(xdata);
Y=fft(ydata);
%
%  Compute the correlation in the frequency domain, 
%  then inverse FFT to return to the time domain.
%
c=zeros(nfft,nr*nc);
for i=1:nr,
  for j=1:nc,
    c(:,j+(i-1)*nc)=ifft(X(:,i).*conj(Y(:,j)));
  end
end
%
%  Discard the spoiled results near the endpoints, 
%  which are now in the middle, because of 
%  the wrap-around.
%
c=[c([1:N],:);c([nfft-N+2:nfft],:)];
%
%  Unscramble the results.  
%  The fftshift function is not vectorized. 
%
for j=1:nr*nc,
  c(:,j)=fftshift(c(:,j));
end
%
%  Biased or unbiased calculation.
%
lags=[-(N-1):N-1]';
if strcmp(opt,'biased')
  c=c/N;
else
  den=N*ones(2*N-1,nr*nc)-abs(lags(:,ones(1,nr*nc)));
  c=c./den;
end
return
