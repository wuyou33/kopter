%% MASS SPRING DAMPER IDENTIFICATION
clc
clear all
close all
% INIT
m = 1;
k = 10;
z = 0.75;
t=0:0.02:10;
v=[t' 0.1*randn(numel(t),3)]; %measurement noise
h = 10; %step height

% run simulation
sim_step = 0.02;
model = 'mass_spring_damper.slx';
[t,x,y]=sim(model);
N=length(t);

% plot
y_name={'d2x/dt2 (m/s^2)','dx/dt (m/s)','x (m)','u (N)'};
figure
for i=1:4
    subplot(4,1,i)
    plot(t,y(:,i))
    ylabel(y_name{i});xlabel('Time (s)'); grid
end

% linear regression
% theta = [1 z k]
% eq: y = m*x_dot_dot = u - z*x_dot - k*x
X = [y(:,4) -y(:,2) -y(:,3)];
z = m*y(:,1);
D = inv(X'*X);
theta_est = D*X'*z;
y_est = X*theta_est;
res = z - y_est;
sig=sqrt(res'*res/(N-3));
theta_min = theta_est - 2*sqrt(sig*sig*diag(D));
theta_max = theta_est + 2*sqrt(sig*sig*diag(D));
y_min=zeros(N,1);y_max=zeros(N,1);
for i=1:N
    y_min(i) = y_est(i) - 2*sqrt(sig*sig*X(i,:)*D*X(i,:)');
    y_max(i) = y_est(i) + 2*sqrt(sig*sig*X(i,:)*D*X(i,:)');
end
figure
plot(t,[z,y_est,y_min,y_max])
legend('Experimental Data','Estimated Data','Lower Confidence Bound','Upper Confidence Bound');xlabel('Time (s)'); grid
title('d2x/dt2 (m/s^2)');