clc
close all
clear all

load P3_FL_model_LTI_100kts_rigid
A_rigid = A;
B_rigid = B;
C_rigid = C;
D_rigid = D;

load P3_FL_model_LTI_100kts_flex
A_flex = A;
B_flex = B;
C_flex = C;
D_flex = D;

%% Step response

LTI_rigid = ss(A_rigid,B_rigid,C_rigid,D_rigid ,'InputName',{'lon' 'lat' 'col' 'ped'},'OutputName',{'q' 'p' 'r' 'phi' 'psi' 'theta'});
LTI_flex = ss(A_flex,B_flex,C_flex,D_flex,'InputName',{'lon' 'lat' 'col' 'ped'},'OutputName',{'q' 'p' 'r' 'phi' 'psi' 'theta'});

[y_rigid,t_rigid] = step(LTI_rigid,3);
[y_flex,t_flex] = step(LTI_flex,3);

figure

subplot(6,4,1)
plot(t_rigid,y_rigid(:,1,1))
hold on
plot(t_flex,y_flex(:,1,1),'r--')
grid on
title('From: LON')
ylabel('To: q [rad/s]')
subplot(6,4,2)
plot(t_rigid,y_rigid(:,1,2))
hold on
plot(t_flex,y_flex(:,1,2),'r--')
grid on
title('From: LAT')
subplot(6,4,3)
plot(t_rigid,y_rigid(:,1,3))
hold on
plot(t_flex,y_flex(:,1,3),'r--')
grid on
title('From: COL')
subplot(6,4,4)
plot(t_rigid,y_rigid(:,1,4))
hold on
plot(t_flex,y_flex(:,1,4),'r--')
grid on
title('From: PED')

subplot(6,4,5)
plot(t_rigid,y_rigid(:,2,1))
hold on
plot(t_flex,y_flex(:,2,1),'r--')
grid on
ylabel('To: p [rad/s]')
subplot(6,4,6)
plot(t_rigid,y_rigid(:,2,2))
hold on
plot(t_flex,y_flex(:,2,2),'r--')
grid on
subplot(6,4,7)
plot(t_rigid,y_rigid(:,2,3))
hold on
plot(t_flex,y_flex(:,2,3),'r--')
grid on
subplot(6,4,8)
plot(t_rigid,y_rigid(:,2,4))
hold on
plot(t_flex,y_flex(:,2,4),'r--')
grid on

subplot(6,4,9)
plot(t_rigid,y_rigid(:,3,1))
hold on
plot(t_flex,y_flex(:,3,1),'r--')
grid on
ylabel('To: r [rad/s]')
subplot(6,4,10)
plot(t_rigid,y_rigid(:,3,2))
hold on
plot(t_flex,y_flex(:,3,2),'r--')
grid on
subplot(6,4,11)
plot(t_rigid,y_rigid(:,3,3))
hold on
plot(t_flex,y_flex(:,3,3),'r--')
grid on
subplot(6,4,12)
plot(t_rigid,y_rigid(:,3,4))
hold on
plot(t_flex,y_flex(:,3,4),'r--')
grid on

subplot(6,4,13)
plot(t_rigid,y_rigid(:,4,1))
hold on
plot(t_flex,y_flex(:,4,1),'r--')
grid on
ylabel('To: phi [rad]')
subplot(6,4,14)
plot(t_rigid,y_rigid(:,4,2))
hold on
plot(t_flex,y_flex(:,4,2),'r--')
grid on
subplot(6,4,15)
plot(t_rigid,y_rigid(:,4,3))
hold on
plot(t_flex,y_flex(:,4,3),'r--')
grid on
subplot(6,4,16)
plot(t_rigid,y_rigid(:,4,4))
hold on
plot(t_flex,y_flex(:,4,4),'r--')
grid on

subplot(6,4,17)
plot(t_rigid,y_rigid(:,5,1))
hold on
plot(t_flex,y_flex(:,5,1),'r--')
ylabel('To: psi [rad]')
grid on
subplot(6,4,18)
plot(t_rigid,y_rigid(:,5,2))
hold on
plot(t_flex,y_flex(:,5,2),'r--')
grid on
subplot(6,4,19)
plot(t_rigid,y_rigid(:,5,3))
hold on
plot(t_flex,y_flex(:,5,3),'r--')
grid on
subplot(6,4,20)
plot(t_rigid,y_rigid(:,5,4))
hold on
plot(t_flex,y_flex(:,5,4),'r--')
grid on

subplot(6,4,21)
plot(t_rigid,y_rigid(:,6,1))
hold on
plot(t_flex,y_flex(:,6,1),'r--')
grid on
ylabel('To: theta [rad]')
xlabel('t [s]')
subplot(6,4,22)
plot(t_rigid,y_rigid(:,6,2))
hold on
plot(t_flex,y_flex(:,6,2),'r--')
grid on
xlabel('t [s]')
subplot(6,4,23)
plot(t_rigid,y_rigid(:,6,3))
hold on
plot(t_flex,y_flex(:,6,3),'r--')
grid on
xlabel('t [s]')
subplot(6,4,24)
plot(t_rigid,y_rigid(:,6,4))
hold on
plot(t_flex,y_flex(:,6,4),'r--')
grid on
xlabel('t [s]')
legend('rigid blade','flexible blade')

%% Bode plot

figure
bode(LTI_rigid)
hold on
bode(LTI_flex,'r--')
legend('rigid blade','flexible blade')
grid on

%% state matrix eigen

eig_A_rigid = eig(A_rigid);
eig_A_flex = eig(A_flex);

figure
plot(real(eig_A_rigid),imag(eig_A_rigid),'+r')
hold on
plot(real(eig_A_flex),imag(eig_A_flex),'ob')
title('state matrix eigenvalues')
xlabel('real')
ylabel('imag')
grid on
legend('rigid blade','flexible blade')
