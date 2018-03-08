function [mag,ph] = phasor(x)
%
%  PHASOR  Computes magnitude and phase angle of complex numbers.  
%
%  Usage: [mag,ph] = phasor(x);
%
%  Description:
%
%    Converts a vector of complex numbers (x) into 
%    magnitude (mag) and phase angle (phase) vectors.
%    Phase angle is in degrees.  
%
%  Input:
%
%      x = scalar or vector of complex numbers.
%
%  Output:
%
%    mag = magnitude.
%     ph = phase angle, deg.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      04 Nov 1997 - Created and debugged, EAM.
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
mag=sqrt(real(x).^2 + imag(x).^2);
ph=(180/pi)*atan2(imag(x),real(x));
return
