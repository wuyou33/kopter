function [y,p,crb,s2,ph,th,seh,s2h,Xh,Zh,f] = rtpid(x,z,t,w,lder,p0,crb0)
%
%  RTPID  Real-time parameter estimation using least squares in the frequency domain.
%
%  Usage: [y,p,crb,s2,ph,th,seh,s2h,Xh,Zh,f] = rtpid(x,z,t,w,lder,p0,crb0);
%
%  Description:
%
%    Real-time parameter estimation using sequential
%    least squares equation-error in the frequency domain.  
%    Transformation of input time-domain data into the 
%    frequency domain is done using a recursive 
%    Fourier transform.  Inputs specifying the derivative 
%    option lder, initial estimated parameter vector p0,
%    and initial estimated parameter covariance 
%    matrix crb0, are optional.  
%
%  Input:
%    
%      x = matrix of column regressors.  
%      z = measured output vector.
%      t = time vector.
%      w = frequency vector, rad/sec.
%   lder = derivative flag:
%          = 0 to model output z (default)
%          = 1 to model derivative of output z
%     p0 = initial parameter vector (default=zero vector).
%   crb0 = initial parameter covariance matrix (default=10^6*identity matrix).
%
%  Output:
%
%      y = model output using final estimated parameters.
%      p = final estimated parameter vector.
%    crb = final estimated parameter covariance matrix.
%     s2 = final model fit error variance estimate.  
%     ph = estimated parameter vector history.  
%     th = vector of times for parameter estimate history ph. 
%    seh = estimated parameter standard error history.
%    s2h = estimated model fit error variance history.
%     Xh = regressor matrix Fourier transform history.
%     Zh = measured output Fourier transform history.
%      f = frequency vector, Hz.
%

%
%    Calls:
%      rft.m
%      lesq.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      20 Sept 1999 - Created and debugged, EAM.
%      20 July 2004 - Updated inputs and outputs, 
%                     added output derivative option, 
%                     modified to use regressors as input, EAM.  
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
[npts,no]=size(z);
[npts,np]=size(x);
%
%  Set defaults.
%
if nargin < 5 | isempty(lder)
  lder=0;
end
if nargin < 6
  p0=zeros(np,1);
end
if nargin < 7
  crb0=1.0e6*eye(np,np);
end
%
%  Initialization.
%
jay=sqrt(-1);
dt=t(2)-t(1);
f=w/(2*pi);
df=f(2)-f(1);
nw=length(w);
%
%  Fourth-order low-pass butterworth filter coefficients.
%
%  This filter design is for cut-off frequency of 1 Hz, 
%  using 40 Hz data.  The filter coefficients are
%  hard-coded here, so that the butter.m routine from 
%  the MATLAB Signal Processing Toolbox is not required.  
%  Specific applications may require a re-design of the
%  filter coefficients b and a.  
%
% fc=0.05;
% fn=1/(2*dt);
% ford=4;
% [b,a]=butter(ford,fc/fn);
%
b=[ 2.353920947051336e-010,...
    9.415683788205342e-010,...
    1.412352568230801e-009,...
    9.415683788205342e-010,...
    2.353920947051336e-010];
a=[ 1.00000000000000,...
   -3.97947658253818,...
    5.93864009075580,...
   -3.93884917328088,...
    0.97968566882953];
%
%  Parameter idstp equals the number of data points skipped 
%  between data points used in the identification calculations. 
%
idstp=1;
mpts=npts-idstp-1;
%
%  Initial time delay before any parameter estimation.
%
td=2;
ntd=round(td/dt);
%
%  Time interval between parameter estimation updates.
%
ti=1;
nti=round(ti/dt);
%
%  More initialization.
%
ph=zeros(mpts,np*no);
th=zeros(mpts,1);
s2h=zeros(mpts,1);
seh=zeros(mpts,np*no);
X0=zeros(np,nw);
Xh=zeros(mpts,np,nw);
Z0=zeros(no,nw);
Zh=zeros(mpts,no,nw);
C0=exp(-jay*w'*t(1));
dC=exp(-jay*w'*(idstp+1)*dt);
nstp=0;
icnt=0;
%
%  Use initial values for the trim offset.
%
x0=x(1,:)';
z0=z(1,:)';
%
%  Real-time parameter estimation loop starts here.
%
while nstp <= mpts,
  nstp=nstp+idstp+1;
  xn=x(nstp,:)';
  zn=z(nstp,:)';
%
%  Compute the low pass filtered values of x and z,
%  and subtract them off before computing the Fourier 
%  transform.  This is done to prevent pollution of 
%  the frequency content by large biases in the time 
%  domain data.  
%
  xn=xn-x0;
  zn=zn-z0;
%
%  Recursive Fourier transform calculation.
%
  [X,C]=rft(xn,dC,X0,C0);
  Xh(nstp,:,:)=X;
  X0=X;
  [Z,C]=rft(zn,dC,Z0,C0);
  Zh(nstp,:,:)=Z;
  Z0=Z;
  C0=C;
%
%  Check if it is time for a parameter estimation calculation. 
%
  if ((nstp >= ntd) & (mod(nstp,nti)==0))
%
%  Do equation error parameter estimation in the 
%  frequency domain every ti seconds.
%
    icnt=icnt+1;
%
%  Use z or z derivative, according to lder.
%  The characters .' mean transpose without 
%  complex conjugation.  
%
    if lder==1
      Ze=jay*w(:,ones(1,no)).*Z.';
    else
      Ze=Z.';
    end
%
%  Equation-error loop.
%
    for j=1:no,
      Xe=X.';
%
%  Estimate model parameters using equation-error 
%  in the frequency domain.
%
%      indx=[1,2,3];
      indx=[1:1:np];
      [Y,P,CRB,S2]=lesq([Xe(:,indx)],Ze(:,j),[],p0,crb0);
%
%  Compute and record results.
%
      if j==1
        p=P;
        s2=S2;
        serr=sqrt(diag(CRB));
      else
        p=[p;P];
        s2=[s2;S2];
        serr=[serr;sqrt(diag(CRB))];
      end
%
%      perr=100*(p-ptrue)./ptrue;
%      perrh(:,icnt)=perr;
%      eta=(p-ptrue)./serr;
%      etah(:,icnt)=eta;
%      fprintf(1,'\n     ptrue        p        serr       perr       eta ');
%      fprintf(1,'\n     -----       ---       ----       ----       --- ');
%      for k=1:np,
%        fprintf(1,'\n  %9.5f  %9.5f  %8.5f  %10.2e  %8.5f',...
%                   ptrue(k),p(k),serr(k),perr(k),eta(k));
%     end
%    fprintf(1,'\n');
%
    end    % equation-error loop
    ph(icnt,:)=p';
    th(icnt)=t(nstp);
    s2h(icnt,:)=s2';
    seh(icnt,:)=serr';
  end    % parameter estimation if statement
end
ph=ph([1:icnt],:);
th=th(1:icnt);
s2h=s2h(1:icnt);
seh=seh([1:icnt],:);
%perrh=perrh(:,[1:icnt]);
%etah=etah(:,[1:icnt]);
%
%  Final estimated parameter covariance matrix.  
%
crb=CRB;
%
%  Off-diagonal terms dropped for multiple outputs.
%
%crb=diag(serr.*serr);
%
%  The biases are omitted 
%  in the frequency domain, so 
%  subtract off the initial regressor 
%  values before computing the 
%  model output.  
%
y=(x-ones(npts,1)*x0')*p;
return
