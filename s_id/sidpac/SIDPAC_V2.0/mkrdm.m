function [u,t,ons] = mkrdm(amp,tdelay,tfinal,dt,T,m,bw,pwrf)
%
%  MKRDM  Creates random white or colored noise inputs.
%
%  Usage: [u,t,ons] = mkrdm(amp,tdelay,tfinal,dt,T,m,bw,pwrf);
%
%  Description:
%
%    Creates m Gaussian random noise input vectors of length
%    T, with root-mean-square amplitude amp.  If optional 
%    inputs bw and pwrf are specified, the noise is colored with 
%    a band-limited component in the frequency interval [0,bw] Hz, 
%    and pwrf is the fraction of the total noise power that is band-limited: 
%
%        total noise power = band-limited power + wide-band power
%
%    Inputs m, bw, and pwrf are optional.  Defaults for m, bw, 
%    and pwrf give a single vector of Gaussian white noise.  
%
%  Input:
%    
%       amp = amplitude.
%    tdelay = time delay before the random noise input starts, sec.
%    tfinal = quiet time at the end of the random noise input, sec.
%        dt = sampling interval, sec.
%         T = time length, sec.
%         m = number of random noise vectors to be generated (default=1).
%        bw = bandwidth of the band-limited noise component, Hz (default=1/(2*dt)).
%      pwrf = fraction of total noise power that is band-limited, [0,1] (default=0).
%
%  Output:
%
%        u = matrix of m random noise column vectors.  
%        t = time vector.
%      ons = matrix of m original noise sequence column vectors.
%

%
%    Calls:
%      cvec.m
%      fdfilt.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%     06 Apr  1996 - Created and debugged, EAM.
%     14 July 2004 - Changed name from mkrdn.m to mkrdm.m, EAM.
%     08 Feb  2006 - Substituted call to fdfilt.m for calls to routines 
%                    from the MATLAB Signal Processing Toolbox, EAM.
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
t=[0:dt:T]';
npts=length(t);
%
%  Check for values of m, bw, and pwrf.
%
if nargin < 8
  pwrf=0;
end
pwrf=cvec(pwrf);
if nargin < 7
  bw=1/(2*dt);
end
bw=cvec(bw);
if nargin < 6 | m<=0
  m=1;
else
  m=round(m);
end
if length(pwrf) < m
  pwrf=pwrf(1)*ones(m,1);
end
if length(bw) < m
  bw=bw(1)*ones(m,1);
end
%
%  If only one value is given for amp, tdelay, or tfinal, 
%  make amp and tdelay the same for all m.
%
amp=cvec(amp);
if length(amp) < m
  amp=amp(1)*ones(m,1);
end
tdelay=cvec(tdelay);
if length(tdelay) < m
  tdelay=tdelay(1)*ones(m,1);
end
tfinal=cvec(tfinal);
if length(tfinal) < m
  tfinal=tfinal(1)*ones(m,1);
end
u=zeros(npts,m);
%
%  Random noise input.
%
randn('seed',sum(100*clock));
%
%  Get white gaussian random noise for raw material for the 
%  band limiting process which will produce the band limited noise.
%
nse=randn(npts,m);
ons=nse;
nmid=floor(npts/2);
if mod(npts,2)==0
  nmid=nmid-1;
end
blnse=zeros(2*nmid+npts,m);
%
%  Extended length of blnse is necessary for the technique
%  used to avoid endpoint problems.
%
blnse(nmid+1:nmid+npts,:)=nse;
%
%  Reflect nmid points on each end about a zero ordinate.
%  This is done to avoid endpoint problems with the low-pass filter.
%
li=(nmid+1)*ones(m,1);
for j=1:m,
  blnse(1:nmid,j)=-blnse(2*nmid+1:-1:nmid+2,j);
  blnse(nmid+npts+1:nmid+npts+nmid,j)=-blnse(nmid+npts-1:-1:npts,j);
  blnse(:,j)=fdfilt(blnse(:,j),bw(j),dt);
  if blnse(li(j),j) < 0
    while blnse(li(j),j) < 0
      li(j)=li(j)+1;
    end
  else
    while blnse(li(j),j) > 0
      li(j)=li(j)+1;
    end
  end
end
%
%  Restore the proper length to the noise sequence. 
%
for j=1:m,
  blnse([1:npts],j)=blnse(li(j):li(j)+npts-1,j);
end
blnse=blnse([1:npts],:);
%
%  Fix the initial value of the band limited noise to zero
%  to avoid inaccurate initial conditions.
%
%blnse=blnse-ones(npts,1)*blnse(1,:);
%
%  Get a new realization of white gaussian random noise 
%  for the broad band noise component.
%
nse=randn(npts,m);
%
%  Combine wide band and bandlimited noise sequences
%  to produce colored noise.
%
for j=1:m,
  if pwrf(j)<=0
    u(:,j)=amp(j)*nse(:,j);
  else
    scf=sqrt(pwrf(j)*(nse(:,j)'*nse(:,j))/(blnse(:,j)'*blnse(:,j)));
    blnse(:,j)=scf*blnse(:,j);
    nse(:,j)=sqrt(1-pwrf(j))*nse(:,j);
    u(:,j)=amp(j)*(blnse(:,j) + nse(:,j));
  end
end
%
%  Time delay and final quiet time.
%  Don't overwrite the initial part, which
%  starts the time series at or near zero.  
%
n0=round(tdelay/dt) + ones(m,1);
n1=round(tfinal/dt) + ones(m,1);
for j=1:m,
  u(:,j)=[zeros(n0(j),1);u([1:npts-n0(j)],j)];
  if tfinal > 0.0
    u([npts-n1(j)+1:npts],j)=zeros(n1(j),1);
  end
end
return
