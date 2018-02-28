import os
import numpy as np
import matplotlib.pyplot as plt
import control
import pdb # pdb.set_trace()

from configClassModule import *

#### SCRIPT
cwd = os.getcwd()
#Load plotting options
plotSettings = plottingOptionsFn()

#Definitions
n_states = 81
n_outputs = 9
n_inputs = 4

# x_dot = A x + B u
# y = C x + D u

# 4 input u = {lon,lat,col,ped}
# v1 C (6x81) 81 states, 6 output y = {q,p,r,phi,psi,theta} u,v,w are missing
# v2 C (9x81) 81 states, 9 output y = {q,p,r,phi,psi,theta,u,v,w}
outputsList = ['q', 'p', 'r','$\phi$','$\psi$', '$\\theta$']
outputsUnitsDict = ['[rad/s]', '[rad]']

A_from_FlightLab = np.loadtxt(cwd+'\\'+'fromFlightPhysics\\FL_LTI_models\\May2017RevAA_BE_0ft_15degC_2800kg_3.37m_147.tab', skiprows = 34)
B_from_FlightLab = np.loadtxt('B_mat_from_FL_v1.txt')
C_from_FlightLab = np.loadtxt('C_mat_from_FL_v1.txt')

#Reshape imported matrix from txt file
A = np.hstack([mat.reshape(n_states, 1) for mat in np.vsplit(A_from_FlightLab, n_states)])
B = np.hstack([mat.reshape(n_states, 1) for mat in np.vsplit(B_from_FlightLab, n_inputs)])
C = np.vstack([mat.reshape(1, n_states) for mat in np.vsplit(C_from_FlightLab, n_outputs)])
D = np.zeros([n_outputs, n_inputs])

np.savetxt('A.txt', A, delimiter = ',' ,fmt='%5.1f')
np.savetxt('B.txt', B, delimiter = ',' ,fmt='%5.1f')
np.savetxt('C.txt', C, delimiter = ',' ,fmt='%5.1f')
np.savetxt('D.txt', D, delimiter = ',' ,fmt='%5.1f')

print('A, shape: '+str(A.shape))
print('B, shape: '+str(B.shape))
print('C, shape: '+str(C.shape))

sh09 = control.ss(A, B, C, D)

# pdb.set_trace()

# Set time
T_in = np.asarray(np.linspace(0, 1, 100, endpoint=True))
youts = []

for i_input in range(n_inputs):

	T, yout = control.step_response(sh09, T = T_in, input = i_input, output = None)

	youts += [yout, ]

figure, axs = plt.subplots(6, n_inputs)
figure.set_size_inches(10, 14, forward=True)

i_input = 0
for yout in youts:
	
	i_out = 0
	for i_out in range(6):
		print('ax'+str(i_out) +str(i_input))
		axs[i_out, i_input].tick_params(axis='both', **plotSettings['axesTicks'])

		axs[i_out, i_input].plot(T, yout[i_input, :], linestyle = '-',  c = plotSettings['colors'][0], **plotSettings['line'])

		#Plotting axes
		if i_input == 0:
			axs[i_out, i_input].set_ylabel('To: '+outputsList[i_out]+outputsUnitsDict[i_out//3], **plotSettings['axes_y'])

		if i_out == 5:
			axs[i_out, i_input].set_xlabel('t [s]', **plotSettings['axes_x'])

		axs[i_out, i_input].grid(which='both', **plotSettings['grid'])
		i_out += 1

	i_input += 1

# ax.legend(**plotSettings['legend'])

# plt.show(block = True)
