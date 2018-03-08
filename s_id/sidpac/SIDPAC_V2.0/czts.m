function X = czts(x,M,W,A)
%
%  CZTS  Chirp z-transform.  
%
%  Usage: X = czts(x,M,W,A);
%
%  Description:
%
%    Computes the chirp z-transform of the data vector x 
%    for M points along a contour in the complex plane 
%    defined by complex scalars W and A.  W is the complex ratio 
%    between points on the contour, and A is the
%    starting point in the complex plane.  The contour is a spiral 
%    in the z-plane, corresponding to a chirp signal:
%
%                     z = A * W.^(0:M-1)
%
%    The parameters M, W, and A are optional.  Default values are 
%    M = size(x,1), W = exp(-j*2*pi/M), and A = 1.  These defaults
%    return the z-transform of x at equally spaced points
%    around the unit circle, equivalent to fft(x).  If x is a matrix, 
%    the chirp z-transform operation is applied to each column.
%
%  Reference:
%
%    Rabiner, L.R., Schafer, R.W., and Rader, C.M.   
%    “The Chirp z Transform Algorithm and Its Application,”  
%    The Bell System Technical Journal, May-June 1969, pp. 1249-1292.  
%
%  Input:
%    
%    x = column vector of data or matrix of column vector data. 
%    M = number of chirp z-transform values, M <= 2*size(x,1).   
%    W = step along the spiral contour in the z-plane.  
%    A = starting point in the z-plane.  
%
%  Output:
%
%    X = chirp z-transform.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      08 Feb 2006 - Created and debugged, EAM.
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
[N,nc] = size(x);
if N <= 1
  error('Input x must be a column vector or matrix of column vectors.')
end
jay = sqrt(-1);
%
%  Set defaults for standard FFT calculation.
%
if nargin < 2 
  M = size(x,1);
end
if nargin < 3
  W = exp(-jay*2*pi/M); 
end
if nargin < 4
  A = 1;
end
%
%  Input checking.
%
if any([size(M), size(W), size(A)]~=1)
	error('Inputs M, W, and A must be scalars.')
end
%
%  Find the nearest power of two for FFT. 
%
nfft = 2.^(ceil(log(N+M-1)/log(2)));
%
%  z-transform sum: nk = (n*n + k*k - (k-n)^2)/2
%
%  Generate the chirp filter vector 
%  in wrap-around order needed for the 
%  fast FFT convolution.  
%
k = [(-N+1):max(M-1,N-1)]';
k2 = (k.^ 2)/ 2;
wk2 = W.^(k2);
%
%  Create data vector for the fast FFT convolution.
%
n = [0:N-1]';
an = A.^(-n);
an = an.*wk2(N+n);
y = x.*an(:,ones(1,nc));
%
%  Create chirp filter vector for the fast FFT convolution.
%
v = 1./wk2(1:(N+M-1));
%
%  Fast convolution using FFT.
%  The FFT function automatically 
%  zero-pads the vectors to nfft.  
%
fy = fft(y,nfft);
fv = fft(v,nfft);
fy = fy.*fv(:,ones(1, nc));
g = ifft(fy);
%
%  Final multiplication step.
%
X = g([N:(N+M-1)],:).*wk2([N:(N+M-1)],ones(1,nc));
return
