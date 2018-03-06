clc
close all
clear all

%% Flightlab model P3 May2017, rigid rotor blade (BE)
% trim fwd flight at different airspeed (z=0ft, 15�C) and helicopter mass and horiz cg position (condition defined in the .tab file name)

% LTI system
% x_dot = A x + B u
% y = C x + D u

% May2017RevAA_BE_0ft_15degC_2800kg_3.37m_90.tab
% May2017RevAA_BE_0ft_15degC_2800kg_3.37m_147.tab
% May2017RevAA_BE_0ft_15degC_2800kg_3.37m_151.tab
% 
% May2017RevAA_BE_0ft_15degC_2120kg_3.50m_90.tab
% May2017RevAA_BE_0ft_15degC_2120kg_3.50m_147.tab
% May2017RevAA_BE_0ft_15degC_2120kg_3.50m_151.tab

%{\n%}\nFL_data_sel = input('Select data from Flightlab : \n [1] 0ft_15degC_2800kg_3.37m_90 \n [2] 0ft_15degC_2800kg_3.37m_147 \n [3] 0ft_15degC_2800kg_3.37m_151 \n [4] 0ft_15degC_2120kg_3.50m_90 \n [5] 0ft_15degC_2120kg_3.50m_147 \n [6] 0ft_15degC_2120kg_3.50m_151 \n: ');
FL_data_sel = 1;

if FL_data_sel == 1
    fname = 'May2017RevAA_BE_0ft_15degC_2800kg_3.37m_90.tab';
elseif FL_data_sel == 2
    fname = 'May2017RevAA_BE_0ft_15degC_2800kg_3.37m_147.tab';
elseif FL_data_sel == 3
    fname = 'May2017RevAA_BE_0ft_15degC_2800kg_3.37m_151.tab';
elseif FL_data_sel == 4
    fname = 'May2017RevAA_BE_0ft_15degC_2120kg_3.50m_90.tab';
elseif FL_data_sel == 5
    fname = 'May2017RevAA_BE_0ft_15degC_2120kg_3.50m_147.tab';
elseif FL_data_sel == 6
    fname = 'May2017RevAA_BE_0ft_15degC_2120kg_3.50m_151.tab';
end

n_state = 73;

if FL_data_sel == 6
    A_start=33;
    B_start=1811;
    C_start=1910;
else
    A_start=34;
    B_start=1812;
    C_start=1911;
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
    save('May2017RevAA_BE_0ft_15degC_2800kg_3.37m_90.mat','A','B','C','D')
elseif FL_data_sel == 2
    save('May2017RevAA_BE_0ft_15degC_2800kg_3.37m_147.mat','A','B','C','D')
elseif FL_data_sel == 3
    save('May2017RevAA_BE_0ft_15degC_2800kg_3.37m_151.mat','A','B','C','D')
elseif FL_data_sel == 4
    save('May2017RevAA_BE_0ft_15degC_2120kg_3.50m_90.mat','A','B','C','D')
elseif FL_data_sel == 5
    %save('May2017RevAA_BE_0ft_15degC_2120kg_3.50m_147.mat','A','B','C','D')
    save('May2017RevAA_BE_0ft_15degC_2120kg_3.50m_147.txt','A','B','C','D','-ascii')
elseif FL_data_sel == 6
    save('May2017RevAA_BE_0ft_15degC_2120kg_3.50m_151.mat','A','B','C','D')
end


%% Step response

LTI_trim = ss(A,B,C,D,'InputName',{'lon' 'lat' 'col' 'ped'},'OutputName',{'q' 'p' 'r' 'phi' 'psi' 'theta'});

[y,t] = step(LTI_trim,3);

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
bode(LTI_trim)
grid on

%% state matrix eigen

eig_A = eig(A);

figure
plot(real(eig_A),imag(eig_A),'+')
title('state matrix eigenvalues')
xlabel('real')
ylabel('imag')
grid on

