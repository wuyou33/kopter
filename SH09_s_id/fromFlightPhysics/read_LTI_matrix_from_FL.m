clc
close all
clear all

%% Flightlab model P3 May2017_RevW

% ss LTI system from linearization, at the following trim condition:
% forward level flight at 100 kts
% z = 0m, ISA +15°C
% heli weight = 1900 kg

% x_dot = A x + B u
% y = C x + D u

% FL_data_sel = input('Select SH90 P3 model (trim fwd 100Kts) from Flightlab : \n [1] v1 [ y = {q,p,r,phi,psi,theta} u,v,w are missing ; u = {lon,lat,col,ped} ] \n [2] v2 [ y = {phi,psi,theta,p,q,r,u,v,w} ] ; u = {lat,lon,col,ped} \n: ');
% v2 it is not available
FL_data_sel = 1;

%% A matrix (81x81) 81 states

n_state = 81;

% read A matrix from FL 2187x3

if FL_data_sel == 1
    load A_mat_from_FL_v1.txt 
    A_mat_from_FL = A_mat_from_FL_v1;
else
    load A_mat_from_FL_v2.txt 
    A_mat_from_FL = A_mat_from_FL_v2;
end

% read it by raws up to n_state=81 elements, hence each n_state/3=27 raw (2187/81=27), hence put the
% results in a column and repeat with the following n_state=81 elements, up to you
% have collected the n_state=81 columns of matrix A

for ii = 1:n_state
    
    idx_stop_A(ii) = (n_state/3)*ii;

end

idx_start_A = horzcat(1,idx_stop_A(1:end-1) + 1);
 
for ii=1:n_state
    
    AA = A_mat_from_FL(idx_start_A(ii):idx_stop_A(ii),:);
    A(:,ii) = reshape(AA',[n_state,1]);

end

%% B (81x4) 81 states, 4 input 

n_input = 4;

% read B matrix from FL 108x3
if FL_data_sel == 1
    load B_mat_from_FL_v1.txt 
    B_mat_from_FL = B_mat_from_FL_v1;
else
    load B_mat_from_FL_v2.txt 
    B_mat_from_FL = B_mat_from_FL_v2;
end

% read it by raws up to n_state=81 elements, hence each n_state/3=27 raw (108/n_input=27), hence put the
% results in a column and repeat with the following n_state=81 elements, up to you
% have collected the n_input=4 columns of matrix B

for ii = 1:n_input
    
    idx_stop_B(ii) = (n_state/3)*ii;

end

idx_start_B = horzcat(1,idx_stop_B(1:end-1) + 1);
 
for ii=1:n_input
    
    BB = B_mat_from_FL(idx_start_B(ii):idx_stop_B(ii),:);
    B(:,ii) = reshape(BB',[n_state,1]);

end

%% v1 C (6x81) 81 states, 6 output y = {q,p,r,phi,psi,theta} u,v,w are missing
% v2 C (9x81) 81 states, 9 output y = {q,p,r,phi,psi,theta,u,v,w} 

% C = zeros(9,81);
% row_C = 1:1:9;
% col_C =[2 10 18 23 30 43 56 67 74]; % positions on the original state vector of the 9 states of interest = 9 output
% 
% indices = sub2ind(size(C), row_C, col_C);
% 
% C(indices) = 1;

n_output = 9;

% read C matrix from FL 243x3
if FL_data_sel == 1
    load C_mat_from_FL_v1.txt
    C_mat_from_FL = C_mat_from_FL_v1;
else
    load C_mat_from_FL_v2.txt
    C_mat_from_FL = C_mat_from_FL_v2;
end
% read it by raws up to n_output=9 elements, hence each n_output/3=3 raw, hence put the
% results in a column and repeat with the following n_output=9 elements, up to you
% have collected the n_state=9 columns of matrix C

for ii = 1:(n_state)
    
    idx_stop_C(ii) = 3*ii;

end

idx_start_C = horzcat(1,idx_stop_C(1:end-1) + 1);
 
for ii=1:(n_state)
    
    CC = C_mat_from_FL(idx_start_C(ii):idx_stop_C(ii),:);
    C(:,ii) = reshape(CC',[n_output,1]);
    
end

% check numbering of the desired output in the state vector

x_all = (1:1:n_state)';
state_index = C*x_all;

% from y = {q,p,r,phi,psi,theta,u,v,w} to y = {q,p,r,phi,psi,theta} (u,v,w are missing) ?!?
delete_raw = find(state_index==0);
C(delete_raw,:) = [];


%% v1 D (6x4) 4 input u = {lon,lat,col,ped}, 6 output y = {q,p,r,phi,psi,theta}
% v2 (9x4) 4 input u = {lat,lon,col,ped},  9 output y = {phi,psi,theta,p,q,r,u,v,w}

if FL_data_sel == 1
    D = zeros(6,4);
else
    D = zeros(9,4);
end

if FL_data_sel == 1
    save('P3_FL_model_LTI_100kts_v1_full.mat','A','B','C','D')
else
    save('P3_FL_model_LTI_100kts_v2_full.mat','A','B','C','D')
end

%% Step response

if FL_data_sel == 1
    LTI_trim_fwd_100 = ss(A,B,C,D,'InputName',{'lon' 'lat' 'col' 'ped'},'OutputName',{'q' 'p' 'r' 'phi' 'psi' 'theta'});
else
    LTI_trim_fwd_100 = ss(A,B,C,D,'InputName',{'lat' 'lon' 'col' 'ped'},'OutputName',{'phi' 'psi' 'theta' 'p' 'q' 'r' 'u' 'v' 'w'});
end

[y,t] = step(LTI_trim_fwd_100,3);

if FL_data_sel == 1

figure

subplot(6,4,1)
plot(t,y(:,1,1))
grid on
title('From: LON')
ylabel('To: q [rad/s]')
subplot(6,4,2)
plot(t,y(:,1,2))
grid on
title('From: LAT')
subplot(6,4,3)
plot(t,y(:,1,3))
grid on
title('From: COL')
subplot(6,4,4)
plot(t,y(:,1,4))
grid on
title('From: PED')

subplot(6,4,5)
plot(t,y(:,2,1))
grid on
ylabel('To: p [rad/s]')
subplot(6,4,6)
plot(t,y(:,2,2))
grid on
subplot(6,4,7)
plot(t,y(:,2,3))
grid on
subplot(6,4,8)
plot(t,y(:,2,4))
grid on

subplot(6,4,9)
plot(t,y(:,3,1))
grid on
ylabel('To: r [rad/s]')
subplot(6,4,10)
plot(t,y(:,3,2))
grid on
subplot(6,4,11)
plot(t,y(:,3,3))
grid on
subplot(6,4,12)
plot(t,y(:,3,4))
grid on

subplot(6,4,13)
plot(t,y(:,4,1))
grid on
ylabel('To: phi [rad]')
subplot(6,4,14)
plot(t,y(:,4,2))
grid on
subplot(6,4,15)
plot(t,y(:,4,3))
grid on
subplot(6,4,16)
plot(t,y(:,4,4))
grid on

subplot(6,4,17)
plot(t,y(:,5,1))
ylabel('To: psi [rad]')
grid on
subplot(6,4,18)
plot(t,y(:,5,2))
grid on
subplot(6,4,19)
plot(t,y(:,5,3))
grid on
subplot(6,4,20)
plot(t,y(:,5,4))
grid on

subplot(6,4,21)
plot(t,y(:,6,1))
grid on
ylabel('To: theta [rad]')
xlabel('t [s]')
subplot(6,4,22)
plot(t,y(:,6,2))
grid on
xlabel('t [s]')
subplot(6,4,23)
plot(t,y(:,6,3))
grid on
xlabel('t [s]')
subplot(6,4,24)
plot(t,y(:,6,4))
grid on
xlabel('t [s]')

else
    
figure

subplot(9,4,1)
plot(t,y(:,1,1))
grid on
title('From: LAT')
ylabel('To: phi [rad]')
subplot(9,4,2)
plot(t,y(:,1,2))
grid on
title('From: LON')
subplot(9,4,3)
plot(t,y(:,1,3))
grid on
title('From: COL')
subplot(9,4,4)
plot(t,y(:,1,4))
grid on
title('From: PED')

subplot(9,4,5)
plot(t,y(:,2,1))
grid on
ylabel('To: psi [rad]')
subplot(9,4,6)
plot(t,y(:,2,2))
grid on
subplot(9,4,7)
plot(t,y(:,2,3))
grid on
subplot(9,4,8)
plot(t,y(:,2,4))
grid on

subplot(9,4,9)
plot(t,y(:,3,1))
grid on
ylabel('To: theta [rad]')
subplot(9,4,10)
plot(t,y(:,3,2))
grid on
subplot(9,4,11)
plot(t,y(:,3,3))
grid on
subplot(9,4,12)
plot(t,y(:,3,4))
grid on

subplot(9,4,13)
plot(t,y(:,4,1))
grid on
ylabel('To: p [rad/s]')
subplot(9,4,14)
plot(t,y(:,4,2))
grid on
subplot(9,4,15)
plot(t,y(:,4,3))
grid on
subplot(9,4,16)
plot(t,y(:,4,4))
grid on

subplot(9,4,17)
plot(t,y(:,5,1))
ylabel('To: q [rad/s]')
grid on
subplot(9,4,18)
plot(t,y(:,5,2))
grid on
subplot(9,4,19)
plot(t,y(:,5,3))
grid on
subplot(9,4,20)
plot(t,y(:,5,4))
grid on

subplot(9,4,21)
plot(t,y(:,6,1))
grid on
ylabel('To: r [rad/s]')
subplot(9,4,22)
plot(t,y(:,6,2))
grid on
subplot(9,4,23)
plot(t,y(:,6,3))
grid on
subplot(9,4,24)
plot(t,y(:,6,4))
grid on

subplot(9,4,25)
plot(t,y(:,7,1))
grid on
ylabel('To: u [ft/s]')
subplot(9,4,26)
plot(t,y(:,7,2))
grid on
subplot(9,4,27)
plot(t,y(:,7,3))
grid on
subplot(9,4,28)
plot(t,y(:,7,4))
grid on

subplot(9,4,29)
plot(t,y(:,8,1))
grid on
ylabel('To: v [ft/s]')
subplot(9,4,30)
plot(t,y(:,8,2))
grid on
subplot(9,4,31)
plot(t,y(:,8,3))
grid on
subplot(9,4,32)
plot(t,y(:,8,4))
grid on

subplot(9,4,33)
plot(t,y(:,9,1))
grid on
ylabel('To: w [ft/s]')
xlabel('t [s]')
subplot(9,4,34)
plot(t,y(:,9,2))
xlabel('t [s]')
grid on
subplot(9,4,35)
plot(t,y(:,9,3))
xlabel('t [s]')
grid on
subplot(9,4,36)
plot(t,y(:,9,4))
xlabel('t [s]')
grid on

end

%% Bode plot

figure
bode(LTI_trim_fwd_100)
grid on

%% state matrix eigen

eig_A = eig(A);

figure
plot(real(eig_A),imag(eig_A),'+')
title('state matrix eigenvalues')
xlabel('real')
ylabel('imag')
grid on

%% model reduction

redu_sel = input('Select model reduction type : \n [1] balreal-modred \n [2] minreal  \n [3] sminreal \n: ');

if redu_sel == 1
% The diagonal g of the joint gramian can be used to reduce the model order. 
% Because g reflects the combined controllability and observability of individual states of the balanced model, you can delete those states with a small g(i) while retaining the most important input-output characteristics of the original system. 
% Use modred to perform the state elimination
[sys,g] = balreal(LTI_trim_fwd_100);  % Compute balanced realization
elim = (g<1e-4);         % Small entries of g are negligible states
redu_sys = modred(sys,elim); % Remove negligible states

elseif redu_sel == 2
% Minimal realization or pole-zero cancelation
redu_sys = minreal(LTI_trim_fwd_100);

elseif redu_sel == 3
% The model resulting from sminreal(sys) is not necessarily minimal, and may have a higher order than one resulting from minreal(sys). 
% However, sminreal(sys) retains the state structure of sys, while, in general, minreal(sys) does not.
redu_sys = sminreal(LTI_trim_fwd_100);

end

A = redu_sys.A;
B = redu_sys.B;
C = redu_sys.C;
D = redu_sys.D;

eig_A_redu = eig(redu_sys.A);

if FL_data_sel == 1
    
    if redu_sel == 1
        save('P3_FL_model_LTI_100kts_v1_redu_1.mat','A','B','C','D')
    elseif redu_sel == 2
        save('P3_FL_model_LTI_100kts_v1_redu_2.mat','A','B','C','D')
    elseif redu_sel == 3
        save('P3_FL_model_LTI_100kts_v1_redu_3.mat','A','B','C','D')
    end

else
    
    if redu_sel == 1
        save('P3_FL_model_LTI_100kts_v2_redu_1.mat','A','B','C','D')
    elseif redu_sel == 2
        save('P3_FL_model_LTI_100kts_v2_redu_2.mat','A','B','C','D')
    elseif redu_sel == 3
        save('P3_FL_model_LTI_100kts_v2_redu_3.mat','A','B','C','D')
    end

end


%% Step response comparison full states vs redux

[y_redu,t] = step(redu_sys,3);

if FL_data_sel == 1

figure
subplot(6,4,1)
plot(t,y(:,1,1))
hold on
plot(t,y_redu(:,1,1),'r--')
grid on
title('From: LON')
ylabel('To: q [rad/s]')
subplot(6,4,2)
plot(t,y(:,1,2))
hold on
plot(t,y_redu(:,1,2),'r--')
grid on
title('From: LAT')
subplot(6,4,3)
plot(t,y(:,1,3))
hold on
plot(t,y_redu(:,1,3),'r--')
grid on
title('From: COL')
subplot(6,4,4)
plot(t,y(:,1,4))
hold on
plot(t,y_redu(:,1,4),'r--')
grid on
title('From: PED')

subplot(6,4,5)
plot(t,y(:,2,1))
hold on
plot(t,y_redu(:,2,1),'r--')
grid on
ylabel('To: p [rad/s]')
subplot(6,4,6)
plot(t,y(:,2,2))
hold on
plot(t,y_redu(:,2,2),'r--')
grid on
subplot(6,4,7)
plot(t,y(:,2,3))
hold on
plot(t,y_redu(:,2,3),'r--')
grid on
subplot(6,4,8)
plot(t,y(:,2,4))
hold on
plot(t,y_redu(:,2,4),'r--')
grid on

subplot(6,4,9)
plot(t,y(:,3,1))
hold on
plot(t,y_redu(:,3,1),'r--')
grid on
ylabel('To: r [rad/s]')
subplot(6,4,10)
plot(t,y(:,3,2))
hold on
plot(t,y_redu(:,3,2),'r--')
grid on
subplot(6,4,11)
plot(t,y(:,3,3))
hold on
plot(t,y_redu(:,3,3),'r--')
grid on
subplot(6,4,12)
plot(t,y(:,3,4))
hold on
plot(t,y_redu(:,3,4),'r--')
grid on

subplot(6,4,13)
plot(t,y(:,4,1))
hold on
plot(t,y_redu(:,4,1),'r--')
grid on
ylabel('To: phi [rad]')
subplot(6,4,14)
plot(t,y(:,4,2))
hold on
plot(t,y_redu(:,4,2),'r--')
grid on
subplot(6,4,15)
plot(t,y(:,4,3))
hold on
plot(t,y_redu(:,4,3),'r--')
grid on
subplot(6,4,16)
plot(t,y(:,4,4))
hold on
plot(t,y_redu(:,4,4),'r--')
grid on

subplot(6,4,17)
plot(t,y(:,5,1))
hold on
plot(t,y_redu(:,5,1),'r--')
grid on
ylabel('To: psi [rad]')
subplot(6,4,18)
plot(t,y(:,5,2))
hold on
plot(t,y_redu(:,5,2),'r--')
grid on
subplot(6,4,19)
plot(t,y(:,5,3))
hold on
plot(t,y_redu(:,5,3),'r--')
grid on
subplot(6,4,20)
plot(t,y(:,5,4))
hold on
plot(t,y_redu(:,5,4),'r--')
grid on

subplot(6,4,21)
plot(t,y(:,6,1))
hold on
plot(t,y_redu(:,6,1),'r--')
grid on
ylabel('To: theta [rad]')
xlabel('t [s]')
subplot(6,4,22)
plot(t,y(:,6,2))
hold on
plot(t,y_redu(:,6,2),'r--')
grid on
xlabel('t [s]')
subplot(6,4,23)
plot(t,y(:,6,3))
hold on
plot(t,y_redu(:,6,3),'r--')
grid on
xlabel('t [s]')
subplot(6,4,24)
plot(t,y(:,6,4))
hold on
plot(t,y_redu(:,6,4),'r--')
grid on
xlabel('t [s]')
legend(['full model states = ' num2str(length(eig_A))],['redux model states = ' num2str(length(eig_A_redu))])

else
    
figure
subplot(6,4,1)
plot(t,y(:,1,1))
hold on
plot(t,y_redu(:,1,1),'r--')
grid on
title('From: LAT')
ylabel('To: phi [rad]')
subplot(6,4,2)
plot(t,y(:,1,2))
hold on
plot(t,y_redu(:,1,2),'r--')
grid on
title('From: LON')
subplot(6,4,3)
plot(t,y(:,1,3))
hold on
plot(t,y_redu(:,1,3),'r--')
grid on
title('From: COL')
subplot(6,4,4)
plot(t,y(:,1,4))
hold on
plot(t,y_redu(:,1,4),'r--')
grid on
title('From: PED')

subplot(6,4,5)
plot(t,y(:,2,1))
hold on
plot(t,y_redu(:,2,1),'r--')
grid on
ylabel('To: psi [rad]')
subplot(6,4,6)
plot(t,y(:,2,2))
hold on
plot(t,y_redu(:,2,2),'r--')
grid on
subplot(6,4,7)
plot(t,y(:,2,3))
hold on
plot(t,y_redu(:,2,3),'r--')
grid on
subplot(6,4,8)
plot(t,y(:,2,4))
hold on
plot(t,y_redu(:,2,4),'r--')
grid on

subplot(6,4,9)
plot(t,y(:,3,1))
hold on
plot(t,y_redu(:,3,1),'r--')
grid on
ylabel('To: theta [rad]')
subplot(6,4,10)
plot(t,y(:,3,2))
hold on
plot(t,y_redu(:,3,2),'r--')
grid on
subplot(6,4,11)
plot(t,y(:,3,3))
hold on
plot(t,y_redu(:,3,3),'r--')
grid on
subplot(6,4,12)
plot(t,y(:,3,4))
hold on
plot(t,y_redu(:,3,4),'r--')
grid on

subplot(6,4,13)
plot(t,y(:,4,1))
hold on
plot(t,y_redu(:,4,1),'r--')
grid on
ylabel('To: p [rad/s]')
subplot(6,4,14)
plot(t,y(:,4,2))
hold on
plot(t,y_redu(:,4,2),'r--')
grid on
subplot(6,4,15)
plot(t,y(:,4,3))
hold on
plot(t,y_redu(:,4,3),'r--')
grid on
subplot(6,4,16)
plot(t,y(:,4,4))
hold on
plot(t,y_redu(:,4,4),'r--')
grid on

subplot(6,4,17)
plot(t,y(:,5,1))
hold on
plot(t,y_redu(:,5,1),'r--')
grid on
ylabel('To: q [rad/s]')
subplot(6,4,18)
plot(t,y(:,5,2))
hold on
plot(t,y_redu(:,5,2),'r--')
grid on
subplot(6,4,19)
plot(t,y(:,5,3))
hold on
plot(t,y_redu(:,5,3),'r--')
grid on
subplot(6,4,20)
plot(t,y(:,5,4))
hold on
plot(t,y_redu(:,5,4),'r--')
grid on

subplot(6,4,21)
plot(t,y(:,6,1))
hold on
plot(t,y_redu(:,6,1),'r--')
grid on
ylabel('To: r [rad/s]')
subplot(6,4,22)
plot(t,y(:,6,2))
hold on
plot(t,y_redu(:,6,2),'r--')
grid on
subplot(6,4,23)
plot(t,y(:,6,3))
hold on
plot(t,y_redu(:,6,3),'r--')
grid on
subplot(6,4,24)
plot(t,y(:,6,4))
hold on
plot(t,y_redu(:,6,4),'r--')
grid on

subplot(6,4,25)
plot(t,y(:,7,1))
hold on
plot(t,y_redu(:,7,1),'r--')
grid on
ylabel('To: u [ft/s]')
subplot(6,4,26)
plot(t,y(:,7,2))
hold on
plot(t,y_redu(:,7,2),'r--')
grid on
subplot(6,4,27)
plot(t,y(:,7,3))
hold on
plot(t,y_redu(:,7,3),'r--')
grid on
subplot(6,4,28)
plot(t,y(:,7,4))
hold on
plot(t,y_redu(:,7,4),'r--')
grid on

subplot(6,4,29)
plot(t,y(:,8,1))
hold on
plot(t,y_redu(:,8,1),'r--')
grid on
ylabel('To: v [ft/s]')
subplot(6,4,30)
plot(t,y(:,8,2))
hold on
plot(t,y_redu(:,8,2),'r--')
grid on
subplot(6,4,31)
plot(t,y(:,8,3))
hold on
plot(t,y_redu(:,8,3),'r--')
grid on
subplot(6,4,32)
plot(t,y(:,8,4))
hold on
plot(t,y_redu(:,8,4),'r--')
grid on

subplot(6,4,33)
plot(t,y(:,9,1))
hold on
plot(t,y_redu(:,9,1),'r--')
xlabel('t [s]')
grid on
ylabel('To: u [ft/s]')
subplot(6,4,34)
plot(t,y(:,9,2))
hold on
plot(t,y_redu(:,9,2),'r--')
xlabel('t [s]')
grid on
subplot(6,4,35)
plot(t,y(:,9,3))
hold on
plot(t,y_redu(:,9,3),'r--')
xlabel('t [s]')
grid on
subplot(6,4,36)
plot(t,y(:,9,4))
hold on
plot(t,y_redu(:,9,4),'r--')
grid on
xlabel('t [s]')
legend(['full model states = ' num2str(length(eig_A))],['redux model states = ' num2str(length(eig_A_redu))])
    
end

%% state matrix eigen comparison full states vs redux

figure
plot(real(eig_A),imag(eig_A),'+')
title('state matrix eigenvalues')
hold on
plot(real(eig_A_redu),imag(eig_A_redu),'or')
xlabel('real')
ylabel('imag')
grid on
legend(['full model states = ' num2str(length(eig_A))],['redux model states = ' num2str(length(eig_A_redu))])

%% Bode plot

figure
bode(LTI_trim_fwd_100)
hold on
bode(redu_sys,'r')
grid on
legend(['full model states = ' num2str(length(eig_A))],['redux model states = ' num2str(length(eig_A_redu))])