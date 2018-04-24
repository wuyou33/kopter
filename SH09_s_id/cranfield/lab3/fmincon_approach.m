% Script to use fmincon function to obtain optimal mass and damping
%
% Original code by: Mudassir Lone 16-12-2016
% Last modified by: Mudassir Lone 16-12-2016

clc; clear all

rng(1); % set random number generator seed

% Set optimisation algorithm
options = optimset('fmincon');
options = optimset(options,'Display','iter-detailed');
options = optimset(options,'MaxFunEvals',1000);
options = optimset(options,'MaxIter',500);

% initial set of parameters
par0 = [0.5 0.8];

% set constraints for parameters 
A = eye(2);
B = [1 1]';

% function handle for cost function
f1 = @(pars)cost_fun(pars);
% execute fmincon constrained optimisation
[x,fval,exitflag,output,lambda,grad,hessian] = fmincon(f1,par0,A,B,[],[],[],[],[],options);
%%