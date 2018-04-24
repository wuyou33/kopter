function J = cost_fun(pars)
%% cost function for mass-spring-damper example
% J = cost_fun(pars)
%
% Original code by: Mudassir Lone 16-12-2016
% Last modified by: Mudassir Lone 16-12-2016

t = 0:0.01:10;
rng(1); % set random number seed
u = randn(size(t));
k=1;
X = mass_spring_damper(pars(1),pars(2),k,u,t);
J = sum(X.vars)+pars(2)^2+exp(1-0.1*pars(2))+pars(1)^2+exp(1-0.1*pars(1));
return