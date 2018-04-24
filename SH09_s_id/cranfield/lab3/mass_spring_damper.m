function [X] = mass_spring_damper(m,lambda,k,u,t)
%% Mass-spring-damper model
% [X] = mass_spring_damper(m,lambda,k,u,t)
%
%
% Original code by: Mudassir Lone 16-12-2016
% Last modified by: Mudassir Lone 16-12-2016

% Define model state space matrices
A = [0 1; -k/m -lambda/m];
B = [0 1/m]';
C = eye(2);
D = 0;

model = ss(A,B,C,D);
% run linear simulation
X.signal = lsim(model,u,t);
% calculate variances
X.vars = var(X.signal);
return