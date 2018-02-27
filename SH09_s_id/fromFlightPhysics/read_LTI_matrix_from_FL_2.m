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

FL_data_sel = input('Select SH90 P3 model (trim fwd 100Kts) from Flightlab : \n [1] rigid blade [ y = {q,p,r,phi,psi,theta} ; u = {lon,lat,col,ped} ] \n [2] flexible blade [ y = {phi,psi,theta,p,q,r} ; u = {lat,lon,col,ped} ] \n: ');

if FL_data_sel == 1
    fname = 'P3_FL_model_LTI_100kts_v1.tab';
else
    fname = 'May2017_RevAA_FE_0ft_15degC_1900kg_3.14m_100.tab';
end

if FL_data_sel == 1
    n_state = 81;
    A_start=34;
    B_start=2223;
    D_start=2333;
    C_start=2347;
else
    n_state = 1553;
    A_start=34;
    B_start=803972;
    C_start=806044;
    D_start=810705;
end

fid = fopen(fname, 'r');
fmt = '%f %f %f';

dati_A = textscan(fid, fmt, 'headerlines', A_start);
A_mat_from_FL = cell2mat(dati_A);
fclose(fid);

fid = fopen(fname, 'r');
dati_B = textscan(fid, fmt, 'headerlines', B_start);
B_mat_from_FL = cell2mat(dati_B);
fclose(fid);

fid = fopen(fname, 'r');
dati_C = textscan(fid, fmt, 'headerlines', C_start);
C_mat_from_FL = cell2mat(dati_C);
fclose(fid);

fid = fopen(fname, 'r');
dati_D = textscan(fid, fmt, 'headerlines', D_start);
D_mat_from_FL = cell2mat(dati_D);
fclose(fid);

%% build A matrix from FL 

size_A_mat_from_FL = size(A_mat_from_FL);

A_mat_from_FL_1 = reshape(A_mat_from_FL',[size_A_mat_from_FL(1)*size_A_mat_from_FL(2),1]);

A_mat_from_FL_1(isnan(A_mat_from_FL_1)) = [];

A = reshape(A_mat_from_FL_1,[n_state,n_state]);
    

%% build B matrix from FL 

n_input = 4;

size_B_mat_from_FL = size(B_mat_from_FL);

B_mat_from_FL_1 = reshape(B_mat_from_FL',[size_B_mat_from_FL(1)*size_B_mat_from_FL(2),1]);

B_mat_from_FL_1(isnan(B_mat_from_FL_1)) = [];

B = reshape(B_mat_from_FL_1,[n_state,n_input]);

%% build C matrix from FL

n_output = 9;

size_C_mat_from_FL = size(C_mat_from_FL);

C_mat_from_FL_1 = reshape(C_mat_from_FL',[size_C_mat_from_FL(1)*size_C_mat_from_FL(2),1]);

C_mat_from_FL_1(isnan(C_mat_from_FL_1)) = [];

C = reshape(C_mat_from_FL_1,[n_output,n_state]);

% check numbering of the desired output in the state vector

x_all = (1:1:n_state)';
state_index = C*x_all;

delete_raw = find(state_index==0);
C(delete_raw,:) = [];


%% build D matrix from FL

D = zeros(6,4);

%%

if FL_data_sel == 1
    save('P3_FL_model_LTI_100kts_rigid.mat','A','B','C','D')
else
    save('P3_FL_model_LTI_100kts_flex.mat','A','B','C','D')
end

%% Step response

LTI_trim_fwd_100 = ss(A,B,C,D,'InputName',{'lon' 'lat' 'col' 'ped'},'OutputName',{'q' 'p' 'r' 'phi' 'psi' 'theta'});

[y,t] = step(LTI_trim_fwd_100,3);

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

% if FL_data_sel == 1
%     
%     if redu_sel == 1
%         save('P3_FL_model_LTI_100kts_v1_redu_1.mat','A','B','C','D')
%     elseif redu_sel == 2
%         save('P3_FL_model_LTI_100kts_v1_redu_2.mat','A','B','C','D')
%     elseif redu_sel == 3
%         save('P3_FL_model_LTI_100kts_v1_redu_3.mat','A','B','C','D')
%     end
% 
% else
%     
%     if redu_sel == 1
%         save('P3_FL_model_LTI_100kts_v2_redu_1.mat','A','B','C','D')
%     elseif redu_sel == 2
%         save('P3_FL_model_LTI_100kts_v2_redu_2.mat','A','B','C','D')
%     elseif redu_sel == 3
%         save('P3_FL_model_LTI_100kts_v2_redu_3.mat','A','B','C','D')
%     end
% 
% end


%% Step response comparison full states vs redux

[y_redu,t] = step(redu_sys,3);

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