%
%  OF_MDOE_DEMO  Demonstrates orthogonal function modeling.
%
%  Usage: of_mdoe_demo;
%
%  Description:
%
%    Demonstrates orthogonal function
%    modeling using program offit.m applied to MDOE
%    and OFAT experimental data.  
%
%  Input:
%
%    None
%
%  Output:
%
%    graphics:
%      2D plots
%      3D plots
%

%
%    Calls:
%      normx.m
%      plotsurf.m
%      offit.m
%      comfun.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      04 Jan 2001 - Created and debugged, EAM. 
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
fprintf('\n\n Multivariate Orthogonal Function Modeling Demo ')
close all;
if exist('ifmc')~=1
  clear;
  fprintf('\n\n Loading example data...')
  load 'of_mdoe_demo_data.mat'
end
fprintf('\n\n\n')
%
%  Set up figure window.
%
FgH=figure('Units','normalized',...
           'Position',[.43 .29 .56 .61],...
           'Color',[0.8 0.8 0.8],...
           'Name','Orthogonal Function Modeling',...
           'NumberTitle','off',...
           'Tag','Fig1');
%
%  Axes for plotting.
%
AxH=axes('Box','on',...
         'Units','normalized',...
         'Position',[.15 .15 .75 .8],...
         'XGrid','on', 'YGrid','on',...
         'Tag','Axes1');
%
%  Set up the data matrices and output labeling.
%
switch ifmc
  case 1,
    zlbl='CD';
    z=cd;
    zp=cdp;
    sig2=sig2d;
  case 2,
    zlbl='CL';
    z=cl;
    zp=clp;
    sig2=sig2l;
  case 3,
    zlbl='CM';
    z=cm;
    zp=cmp;
    sig2=sig2m;
end
xc=normx(x,xmin,xmax);
xcp=normx(xp,xmin,xmax);
plot3(x(:,1),x(:,2),z,'bx','MarkerSize',10,'LineWidth',1.5);
xlabel('alpha  (deg)')
ylabel('mach')
zlabel(zlbl)
grid on;
v=axis;
axis([1.5 4 0.65 0.85 v(5) v(6)]);
axis vis3d
disp('The figure shows a plot of the measured output ')
disp('for MDOE subspace 2')
fprintf('\n\n Press any key to continue ... \n\n'),pause,
if offlg==1
  disp('The model for the dependent variable is identified')
  disp('in terms of orthogonal functions generated from the ')
  disp('independent variable data.  The method for generating')
  disp('the orthogonal functions will be demonstrated now.')
  fprintf('\n\n Press any key to continue ... \n\n'),pause,
  disp('The first orthogonal function p1 is chosen')
  disp('as a vector of ones, p1=ones(length(z),1).')
  p1=ones(length(rn),1);
  disp('The next orthogonal function is chosen to be similar ')
  disp('to the first independent variable (alpha) raised to the ')
  disp('first power, so p2=x(:,1).*p1.  But p2 will not in ')
  disp('general be orthogonal to p1, so we adjust p2 to force the ')
  disp('orthogonality using p2=alpha.*p1 - gam21*p1, where ')
  disp('gam21 is a scalar to be found.  Multiplying the last ')
  disp('expression by p1 transpose on both sides and using the')
  fprintf('orthogonality condition p1''*p2=0, we can solve for\n')
  disp('gam21 as:') 
  fprintf('\n\n gam21=(p1''*(x(:,1).*p1))/(p1''*p1) \n')
  gam21=(p1'*(x(:,1).*p1))/(p1'*p1),
  fprintf('\n\n Press any key to continue ... \n\n'),pause,
  disp('Now that gam21 is known, p2 can be computed from')
  disp('p2=x(:,1).*p1-gam21*p1.  Note that the term gam21*p1 ')
  disp('removes the part of p2 that is along the p1 direction, ')
  fprintf('so p2 is now orthogonal to p1, and p1''*p2 should be zero.')
  p2=x(:,1).*p1-gam21*p1;
  fprintf('\n\nThe inner product of p1 and p2 is: \n\n')
  p1_transpose_times_p2=p1'*p2,
  fprintf('\nwhich is numerically zero.')
  fprintf('\n\n Press any key to continue ... \n\n'),pause,
  plot(rn,[p1,p2]),grid on;legend('p1','p2');
  disp('The figure shows a plot of orthogonal polynomials p1 and p2.')
  disp('')
  disp('In this simple case, p2 (based on alpha to the first power)')
  disp('has been made orthogonal to a p1 (a constant vector of ones)')
  disp('by removing a constant bias from the alpha values in x(:,1).')
  fprintf('\n\n Press any key to continue ... \n\n'),pause,
  disp('The procedure can be continued using arbitrary multiplications')
  disp('of the independent variables.  For example, if the next ')
  disp('orthogonal function is to be similar to alpha.*mach, then')
  disp('we write p3=x(:,2).*p2-gam32*p2-gam31*p1.  The scalars gam32')
  disp('and gam31 are found by multiplying both sides of the last')
  disp('equation by p2 transpose and p1 transpose, respectively, and ')
  fprintf('invoking the orthogonality conditions that p2''*p3=0,\n')
  fprintf('p2''*p1=0, p1''*p3=0, and p1''*p2=0:\n\n')
  gam32=(p2'*(x(:,2).*p2))/(p2'*p2),
  gam31=(p1'*(x(:,2).*p2))/(p1'*p1),
  fprintf('\n\n Press any key to continue ... \n\n'),pause,
  disp('Now that gam32 and gam31 are known, p3 can be computed from')
  disp('p3=x(:,2).*p2-gam32*p2-gam31*p1.  Again, the terms gam32*p2 ')
  disp('and gam31*p1 remove the parts of p3 that are along the p2 ')
  disp('and p1 directions, so p1, p2, and p3 are mutually orthogonal.')
  p3=x(:,2).*p2-gam32*p2-gam31*p1;
  disp('Arranging p1, p2, and p3 as columns of a matrix P, and then')
  fprintf('computing P''*P, the orthogonality of p1, p2, and p3\n')
  disp('is demonstrated:')
  P_transpose_times_P=[p1,p2,p3]'*[p1,p2,p3],
  disp('where the diagonal elements of the matrix above are the ')
  disp('inner products of the orthogonal functions p1, p2, and p3')
  disp('with themselves.')
  fprintf('\n\n Press any key to continue ... \n\n'),pause,
  plot(rn,[p1,p2,p3]),grid on;legend('p1','p2','p3');
  disp('A plot of orthogonal polynomials p1, p2, and p3 is ')
  disp('shown in the figure.  Although orthogonal function p3 ')
  disp('looks strange, it has of course been generated by linear ')
  disp('combinations of ordinary polynomials, just like all the ')
  disp('other orthogonal functions.  Using orthogonal functions ')
  disp('decouples the parameter estimation problem, because each ')
  disp('modeling function is unique in its ability to explain ')
  disp('variations in the dependent variable, due to the orthogonality.')
  disp('This makes it easy to choose which orthogonal modeling function(s)')
  disp('should be included as part of the model.  Subsequently, each ')
  disp('retained orthogonal modeling function can be decomposed ')
  disp('into ordinary polynomial functions (from which they came), to ')
  disp('arrive finally at a multivariate polynomial model in ')
  disp('the independent variables.')
  fprintf('\n\n Press any key to continue ... \n\n'),pause,
end
disp('Now run program offit with input parameters nord and ')
disp('maxord, which are the maximum independent variable orders ')
disp('for each individual orthogonal function modeling term, and ')
disp('the maximum order for each term, respectively.')
nord,maxord,
disp('For example, an orthogonal function similar to ')
disp('alpha.*mach.^3 would be an allowable term, but not mach.^5 ')
disp('(which exceeds maximum order for independent variable')
disp('number 2, nord(2)=3), and not (alpha.^3).*(mach.^3) (which ')
disp('exceeds maximum total order for each term, maxord=5).')
fprintf('\n\n Press any key to continue ... \n'),pause,
[y,ap,iap,s2ap,pse]=offit(xc,z,nord,maxord,sig2);
fprintf('\n\n Press any key to continue ...\n '),pause,
clf;
fprintf('\n\nIn the figure, measured output \n')
disp('data is marked with blue x, and the fitted ')
disp('model is plotted as a smooth surface. The fit can be')
disp('examined more thoroughly using the Rotate 3D button ')
disp('on the figure window toolbar.')
plot3(x(:,1),x(:,2),z,'bx','MarkerSize',10,'LineWidth',1.5);
xlabel('alpha  (deg)')
ylabel('mach')
zlabel('zlbl')
grid on;
v=axis;
axis([1.5 4 0.65 0.85 v(5) v(6)]);
hold on
Y=plotsurf(xmin,xmax,ap,iap,'alpha  (deg)','mach',zlbl);
hold off
axis vis3d
fprintf('\n\n Press any key to continue ... \n\n'),pause,
fprintf('Plot the residual:\n\n')
disp('residual = measured output minus model output')
res=z-y;
plot(rn,res,'r+','MarkerSize',10,'LineWidth',1.5),ylabel('model residual'),xlabel('data point'),grid on;
fprintf('\n\n')
disp('Notice that the residual is nearly white noise, ')
disp('indicating that the model has captured the ')
disp('functional dependence.')
fprintf('\n\n Press any key to continue ... \n\n'),pause,
disp('The identified multivariate polynomial model is ')
disp('described by vector ap, which holds the parameter ')
disp('estimates for each term in the model, and vector iap, ')
disp('which indicates the form of each model term.  Elements ')
disp('of vector iap hold the integer powers of the ')
disp('independent variables for each term in the identified ')
disp('model.  For example, iap(3)=12 means the third model ')
disp('term has the form ap(3)*mach*alpha^2. ')
disp('Notice that the exponent of the first independent variable')
disp('is in the ones place of iap(3), and the exponent of the ')
disp('second independent variable is in the tens place ')
disp('(and so on if there were more independent variables).')
disp('The identified multivariate polynomial model for the ')
disp('retained orthogonal functions is defined by:')
for i=1:length(ap),
  if i>9
    fprintf('\n  ap(%1.0f) = %11.3e',i,ap(i))
    fprintf('   iap(%1.0f) = %3i',i,iap(i))
  else
    fprintf('\n  ap(%1.0f) =  %11.3e',i,ap(i))
    fprintf('   iap(%1.0f) =  %3i',i,iap(i))
  end
end
fprintf('\n\n Press any key to continue ... \n'),pause,
fprintf('\n\n Prediction points\n')
yp=comfun(xcp,ap,iap);
subplot(2,1,1);plot(rnp,zp,rnp,yp);legend('Measured Data','Model Prediction');
xlabel('data point'),ylabel(zlbl),grid on;
subplot(2,1,2);plot(rnp,zp-yp,'ro','MarkerSize',7,'LineWidth',1.5);
xlabel('data point'),grid on;
hold on;
plot(rnp,2*sqrt(pse)*ones(length(rnp),1),'b','LineWidth',1)
plot(rnp,-2*sqrt(pse)*ones(length(rnp),1),'b','LineWidth',1)
legend('Prediction Error','95% Confidence Interval');
fprintf('\nThe plots show that the identified model')
fprintf('\npredicts very well for data that was not ')
fprintf('\nused to identify the model. ')
fprintf('\n\nEnd of demonstration \n\n')
return
