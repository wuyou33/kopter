%Script
close all
clear all
%Constants
const.k = 10;
const.m = 1; %We know this
const.lambda = 0.5;
u = 5;
samplingTimeStep = 0.02; %50Hz
samplingTime = 0:samplingTimeStep:20;

%Noise
v = [samplingTime' 10*randn(length(samplingTime), 3)];

%Initial conditions
ini.x = 5;
ini.xdot = 0;

%Sim
[T,X,Y] = sim('massSpringDamper',samplingTime); %Output will be save to workspace - force(timeseries), output(structure)

%Plot output
figure('Units', 'normalized', 'Position', [0.15 0.1 0.7 0.75])

ylabels = {'xdotdot', 'xdot', 'x'};
for i=1:3
    subplot(3, 1, i)

    plot(T(:,1), Y(:,i))
    
    ylabel(ylabels{i})
    xlabel('Time (s)')
end

%Add noise

%Matrix formulation
X = [force.Data(:), -output.xdot.Data(:), -output.x.Data(:)];
theta_est = inv(X' * X) * X' * output.xdotdot.Data;

y_est = X * theta_est;

v_calc = output.xdotdot.Data - y_est;

%Confidence interval
N = length(v_calc);
D = inv(X' * X);
sigmaSQRT = (v_calc' * v_calc) / (N - 3);

%Theta - Upper and lower bounds
paraNames = {'\lambda', 'k'};
for p=1:2
    lower = theta_est(1+p)-2*sqrt(sigmaSQRT * D(1+p, 1+p));
    upper = theta_est(1+p)+2*sqrt(sigmaSQRT * D(1+p, 1+p)); 
    fprintf(['Calculation for ' paraNames{p} '\n'])
    fprintf([num2str(lower) '<' num2str(theta_est(1+p)) '<' num2str(upper) '\n'])

    %Save data
    estPara{p} = [lower, theta_est(1+p), upper]; 
end

%Figure with Confidence bounds
figure('Units', 'normalized', 'Position', [0.15 0.1 0.7 0.75])

ax = gca;

plot(ones(1, 3), estPara{1}(1), 'r^');
hold on;
plot(ones(1, 3), estPara{1}(2), 'ro');
plot(ones(1, 3), estPara{1}(3), 'rv');

ylabel(paraNames{1});

yyaxis right;

ax.YColor = 'k';

ylabel(paraNames{2});

plot(2 .* ones(1, 3), estPara{2}(1), 'b^');
plot(2 .* ones(1, 3), estPara{2}(2), 'bo');
plot(2 .* ones(1, 3), estPara{2}(3), 'bv');

ax.XTick = [1 2];

ax.XTickLabel = paraNames;

ax.XLim = [0 3];
