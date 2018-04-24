close all
clear all

%Constants
const.S = 6297.8;
const.c = 78.53;
const.Iy = 10^7;

%Flight condition - trim
flight.M = 2.0;
flight.h = 60000; %ft
flight.V = 1936; %ft/s
flight.alpha = 6.2; %deg
flight.q = 424; %lb/ft^2

%Transfer functions
s = zpk('s');

tf_q_eta = (-1.62*s*(s + 0.00174)*(s + 0.175)) / ((s + 0.0743)*(s + 0.0181)*(s^2 + 0.5597*s + 3.725));
tf_q_eta.InputName = '\eta';
tf_q_eta.InputUnit = 'deg';
tf_q_eta.OutputName = 'q';
tf_q_eta.OutputUnit = 'deg/s';

tf_u_eta = (1.5*(s + 226)*(s^2 + 0.2729*s + 0.0269)) / ((s + 0.0743)*(s + 0.0181)*(s^2 + 0.5597*s + 3.725));
tf_u_eta.InputName = '\eta';
tf_u_eta.InputUnit = 'deg';
tf_u_eta.OutputName = 'u';
tf_u_eta.OutputUnit = 'ft/s';

tf_w_eta = (-13.8*(s + 226)*(s + 0.0196)*(s + 0.01)) / ((s + 0.0743)*(s + 0.0181)*(s^2 + 0.5597*s + 3.725));
tf_w_eta.InputName = '\eta';
tf_w_eta.InputUnit = 'deg';
tf_w_eta.OutputName = 'w';
tf_w_eta.OutputUnit = 'ft/s';

%Build input
iSR = 100; %inputSamplingRate,100Hz
time = 0 : (1/iSR) : 15;
time = time(1, 1:(end-1))';

N = length(time);

input1 = [zeros(iSR, 1); -ones(iSR, 1); ones(2*iSR, 1); -ones(iSR, 1); zeros(10*iSR, 1)];
input2 = [zeros(iSR, 1); -ones(2*iSR, 1); ones(2*iSR, 1); zeros(10*iSR, 1)];
input3 = [zeros(iSR, 1); -ones(iSR, 1); ones(2*iSR, 1); -ones(iSR, 1); ones(iSR, 1); -ones(iSR, 1); zeros(8*iSR, 1)];

inputval = [zeros(iSR, 1); -ones(iSR, 1); zeros(13*iSR, 1)];

inputs.test = {input1, input2, input3};
inputs.val = {inputval};

%Matrix of TFs
H = [tf_q_eta; tf_u_eta; tf_w_eta];

%Variables
estimators = cell(1, 3);

for iTest=1:3
    
    estimators{iTest} = zeros(4, 3);
    
    %Simulation
    input = inputs.test{iTest} .*(pi/180);

    figure('Units', 'normalized', 'Position', [0.15 0.1 0.7 0.75])
    lsim(H, input, time')
    [y_out,~,~] = lsim(H, input, time'); %out: q, u, w

    %Obtain variables
    q = y_out(:, 1); %q
    qdot = gradient(q, time); %[0.0; diff(y_out(:, 1))/(1/iSR)]; %qdot
    alpha = (y_out(:, 3) ./ flight.V);% - flight.alpha; %alpha

    %Errors
    % noise_eta = ;

    %Matrix formulation
    X = [ones(N, 1), alpha(:), q(:), input(:)];
    theta_est = inv(X' * X) * X' * qdot;

    y_est = X * theta_est;

    v_calc = qdot - y_est;

    %Obtain coefficients
    adim1 = (flight.q * const.S * const.c) / const.Iy;
    adim2 = const.c / (2*flight.V);
    adim = {1/adim1, 1/adim1, 1/(adim1*adim2), 1/adim1};

    %Confidence bounds
    D = inv(X' * X);
    sigmaSQRT = (v_calc' * v_calc) / (N - 3);

    %Coefficients
    fprintf(['Aerodynamic derivatives' '\n'])
    estimatorsName = {'Cm_{0}', 'Cm_{alpha}', 'Cm_q', 'Cm_{eta}'};
    estimatorsName2 = {'Cm_{0}', 'Cm_{\alpha}', 'Cm_q', 'Cm_{\eta}'};
    for o=1:4
        
        lower = theta_est(o)-2*sqrt(sigmaSQRT * D(o, o));
        upper = theta_est(o)+2*sqrt(sigmaSQRT * D(o, o)); 
        fprintf([estimatorsName{o} ': ' num2str(lower*adim{o}) '<' num2str(theta_est(o)*adim{o}) '<' num2str(upper*adim{o}) '\n'])
        
        estimators{iTest}(o, 1) = lower*adim{o};
        estimators{iTest}(o, 2) = theta_est(o)*adim{o};
        estimators{iTest}(o, 3) = upper*adim{o};
    end
    
end

colors = {'r', 'b', 'k'};
conf = {'^', '*', 'v'};

figure('Units', 'normalized', 'Position', [0.15 0.1 0.7 0.75])

hold on
grid on

subplotN = [1, 1, 2, 2];
subplotM = [1, 2, 1, 2];
for p=1:4 %Estimator
    
    subplot(2, 2, p)
    
    grid on
    
    hold on
    
    title(estimatorsName2{p});
    
    for o=1:3 %Test
        
        for u=1:3 %Limits
    
            scatter([o], [estimators{o}(p, u)], strcat(conf{u}, colors{o}))
            
        end
        
    end
    
    xlabel('Test')
    ax = gca;
    ax.XTick = ([1 2 3]);
    
end
