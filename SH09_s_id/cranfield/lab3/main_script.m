% Script to obtain cost function topology for mass-spring-damper example
%
% Original code by: Mudassir Lone 16-12-2016
% Last modified by: Mudassir Lone 16-12-2016

clear all; clc

lambda = 0:0.02:1;
m = 0.1:0.02:1;
k=1;

t = 0:0.01:10;
rng(1); % set random number seed
u = randn(size(t));
tic;
for i=1:numel(lambda)
    for j=1:numel(m)
        X = mass_spring_damper(m(j),lambda(i),k,u,t);
        J(i,j) = sum(X.vars)+lambda(i)^2+exp(1-0.1*lambda(i))+m(j)^2+exp(1-0.1*m(j));
    end
end
time = toc;

% find minima
[a,b]=min(J(:));
[R,C] = ind2sub(size(J),b);
lambda_0 = lambda(R);
m_0 = m(C);

% plot contours of cost function value
[X,Y]=meshgrid(lambda,m);
figure
subplot(1,2,2)
contour(X,Y,J',50); hold on; grid on
plot(lambda_0,m_0,'ro','MarkerFaceColor','r')
xlabel('\lambda'); ylabel('m');
text(lambda_0+0.02,m_0,['minima J = ' num2str(J(R,C))])
text(lambda_0+0.02,m_0+0.04,['\lambda = ' num2str(lambda_0)])
text(lambda_0+0.02,m_0+0.08,['m = ' num2str(m_0)])

subplot(1,2,1)
plot(lambda,lambda.^2+exp(1-0.1*lambda)); grid on
xlabel('\lambda')
ylabel('g(\lambda)')
