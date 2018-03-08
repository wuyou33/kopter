function [u,t,pf,f,M,ph] = mkmsswp(amp,fmin,fmax,dt,T,m,fu,pwr)
%
%  MKMSSWP  Creates orthogonal multi-sine inputs with minimized relative peak factor.
%
%  Usage: [u,t,pf,f,M,ph] = mkmsswp(amp,fmin,fmax,dt,T,m,fu,pwr);
%
%  Description:
%
%    Generates m orthogonal multi-sine sweeps of time 
%    length T with sample rate dt, by combining 
%    equally-spaced frequencies between fmin and fmax 
%    in Hz, using a power spectrum defined by pwr.  
%    Frequencies for each input can be supplied in the 
%    corresponding columns of fu.  Otherwise, the frequencies 
%    are assigned sequentially to each input and the number 
%    of harmonic components is maximized.  The 
%    frequencies then depend on the maneuver time T, the 
%    number of inputs m, and the selected 
%    frequency band [fmin,fmax].  The signals 
%    have minimized relative peak factor for a 
%    given spectrum.  Outputs are the orthogonal  
%    multi-sine sweeps in columns of u, the corresponding 
%    time vector t, the frequencies for the harmonic 
%    components f, and the relative peak factors:
%
%        pf = (max(u)-min(u))/(2*sqrt(2)*rms(u))
%
%    M is a vector containing the number of frequencies 
%    in each input, and ph is a matrix of the phase 
%    shifts, optimized for minimum peak factors and 
%    shifted so that the inputs begin and end at zero.  
%    If amp is a scalar, all m signals have that amplitude; 
%    otherwise, each element of amp specifies the amplitude
%    of the corresponding column of u.  
%    Inputs m, fu, and pwr are optional.  
%
%  Reference:
%
%    Morelli, E.A., "Multiple Input Design for Real-Time 
%    Parameter Estimation in the Frequency Domain," 
%    Paper REG-360, 13th IFAC Symposium on System 
%    Identification, Rotterdam, The Netherlands, August 2003.
%
%  Input:
%
%     amp = amplitude(s).
%    fmin = minimum frequency, Hz.
%    fmax = maximum frequency, Hz.
%      dt = sampling interval, sec.
%       T = time length, sec.
%       m = number of signals to generate (default = 1).
%      fu = matrix with columns containing frequencies for each input, in Hz 
%           (default = maximum frequency resolution)  
%     pwr = matrix with columns defining power spectrum for each input.  
%           The sum of the elements in each column of pwr must equal 1  
%           (default = flat power spectrum).  
%
%
%  Output:
%
%       u = orthogonal multi-sine sweep(s). 
%       t = time vector.
%      pf = relative peak factor(s).
%       f = frequencies of harmonic components, Hz.
%       M = number of harmonic components for each column of u.  
%      ph = phase angles of harmonic components, rad.
%

%
%    Calls:
%      pf_cost.m
%      peakfactor.m
%      cvec.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      24 Nov 2002 - Created and debugged, EAM.
%      18 Mar 2003 - Incorporated peakfactor.m, made resulting
%                    inputs orthogonal in time and frequency domains,
%                    added peak factor optimization loop, 
%                    interleaved frequencies for multiple inputs, EAM.
%      27 Mar 2003 - Added fu input for arbitrary frequency selection, EAM.
%      25 May 2004 - Added arbitrary power spectrum capability, EAM.
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
if nargin < 6
  m=1;
else
  m=round(m);
end
if length(amp)~=m
  amp=amp(1)*ones(m,1);
end
u=zeros(npts,m);
%
%  Find appropriate harmonics and phase angles.
%
if fmax<=fmin
  fprintf('\n Illegal frequency bounds \n\n');
  return
end
%
%  Enforce limits on fmin and fmax, according to the 
%  characteristics of the data.  Minimum frequency 
%  corresponds to a period of half the maneuver length.  
%
fmin=max(fmin,2/T);
fmax=min(fmax,1/(2*dt));
%
%  The frequencies must be based on a fundamental period
%  of length T.  The last point in the time history  
%  is a repeat of the first point, but this is 
%  not a problem, because the inputs begin and end at 
%  zero, using harmonic frequencies.  
%
%  Round off the minimum and maximum frequency so 
%  that all of the requested frequency band is covered. 
%
fmin=fix(fmin/(1/T))*(1/T);
fmax=ceil(fmax/(1/T))*(1/T);
if nargin < 7 
  fo=[fmin:1/T:fmax]';
  nf=length(fo);
%
%  Interleave the harmonic frequencies 
%  assigned to the inputs, so that
%  each input will have an evenly 
%  distributed mix of frequencies 
%  across the frequency band [fmin,fmax].
%
  findx=[1:nf]';
  fo=fo(findx);
  Mo=length(fo);
  f=zeros(Mo,m);
  M=zeros(m,1);
  for j=1:m,
%
%  Take every mth frequency from fo 
%  for the jth input.  Vector fij 
%  keeps track of the indices.  
%
    fvec=fo(j:m:nf);
%
%  Put the frequencies in order.  This 
%  gives a better initial condition for 
%  the phase optimization below.  
%
    [fvec,ivec]=sort(fvec);
    M(j)=length(fvec);
    f([1:M(j)],j)=fvec;
  end
else
  if m==1
    fu=cvec(fu);
  end
  f=fu;
  for j=1:m,
    M(j)=length(find(f(:,j)~=0));
  end
end
pf=zeros(m,1);
ph=zeros(max(M),m);
%
%  Use flat power spectrum by default.
%
if nargin < 8 
  pwr=(1/max(M))*ones(max(M),m);
else
  if size(pwr,1)~=max(M)
    fprintf('\n\n Input size mismatch for fu and pwr. \n\n')
    return
  end
%
%  If the number of columns in pwr 
%  is not correct, make the power 
%  distribution the same for all m 
%  composite inputs.
%
  if size(pwr,2)~=m
    pwr=pwr(:,1)*ones(1,m);
  end
end
for j=1:m,
  fvec=f([1:M(j)],j);
  w=2*pi*fvec;
%
%  Phase angles.
%
  phvec=zeros(M(j),1);
%
%  Power spectrum.
%
  pvec=pwr([1:M(j)],j);
%
%  Use an expression that allows arbitrary
%  frequencies.  The variable tnm1 denotes 
%  the time at step (n-1).  The expression 
%  for tnm1 is Eq. (5) in Schroeder's paper.  
%
  for n=2:M(j),
    tnm1=T*sum(pwr([1:n-1],j));
    phvec(n)=phvec(n-1) - 2*pi*(f(n,j)-f(n-1,j))*tnm1;
%    phvec(n)=phvec(1)-pi*n*n/M(j);
%    phvec(n)=pi*n*n/(2*M(j));
  end
%
%  Optimize the phase angles for minimum 
%  peak factor, then adjust the phase angles
%  so that the endpoints are zero.  End 
%  the iteration when all peak factors 
%  are below pfgoal or after nloops iterations.  
%
  nloops=50;
  pfgoal=1.01;
  pf(j)=pf_cost(phvec,fvec,pvec,t);
%
%  Phase optimization loop.
%
  fprintf('\n\n Starting phase optimization for input number %i ...\n\n',j),
  pause(0.5),
  for k=1:nloops,
%
%  Stop the iterations if the peak factor 
%  goes to pfgoal or lower.  
%
    if pf(j) > pfgoal
%
%  Minimize the peak factor using 
%  the simplex method for this nonlinear 
%  optimization problem.  
%
      [phopt,pfopt]=fminsearch('pf_cost',phvec,[],fvec,pvec,t);
      pfopt,
      phvec=phopt;
%
%  Find phase offset for a zero initial condition.
%  Variable delt is the resolution for the time shift.
%
      phoff=zeros(M(j),1);
      delt=0.0001*ones(M(j),1);
%
%  Find the sign of the initial point without phase shift.
%
      uisgn=sign(sum(sqrt(pvec).*cos(phvec)));
%
%  Increment phase shift until a sign change occurs.
%  Use the frequency vector to implement the 
%  phase shift for each component, so that 
%  the shifting is really a translation along
%  the time axis until a zero crossing is found.
%  If the phase is shifted directly by a 
%  constant offset for each component,  
%  this corresponds to a different time shift 
%  for each component, because each component 
%  has a different frequency.  
%
      while sign(sum(sqrt(pvec).*cos(phvec+phoff)))==uisgn
        phoff=phoff+delt.*w;
%        phoff=phoff+delt;
      end
%
%  Adjust component phases for zero initial condition.
%
      phvec=phvec+phoff;
%
%  Compute the peak factors.
%
      pf(j)=pf_cost(phvec,fvec,pvec,t);
    end
  end
%
%  Put the final phase shifts in the interval [-pi,pi].
%
  phvec=phvec-2*pi*fix(phvec./(2*pi));
  for k=1:M(j),
    if abs(phvec(k))>pi
      phvec(k)=phvec(k)-sign(phvec(k))*2*pi;
    end
  end
%
%  Record the final phase shifts.
%
  ph([1:M(j)],j)=phvec;
%
%  Compute the composite Schroeder signal.  
%
  for k=1:M(j),
    u(:,j)=u(:,j)+sqrt(pvec(k))*cos(w(k)*t+phvec(k));
  end
%
%  Scale the result using the input amp.  
%
  u(:,j)=amp(j)*u(:,j);
%
%  Compute the peak factor.
%
  pf(j)=peakfactor(u(:,j));
end
%
%  Get rid of unnecessary values in 
%  the f and ph arrays.  
%
Mmax=max(M);
f=f([1:Mmax],:);
ph=ph([1:Mmax],:);
return
