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
n_states = 73
n_outputs = 6
n_inputs = 4

# x_dot = A x + B u
# y = C x + D u

# 4 input u = {lon,lat,col,ped}
# v1 C (6x81) 81 states, 6 output y = {q,p,r,phi,psi,theta} u,v,w are missing
# v2 C (9x81) 81 states, 9 output y = {q,p,r,phi,psi,theta,u,v,w}
inputsList = ['lon','lat','col','ped']
outputsList = ['q', 'p', 'r','$\phi$','$\psi$', '$\\theta$']
outputsUnitsDict = ['[rad/s]', '[rad]']

A = np.loadtxt(cwd+'\\'+'fromFlightPhysics\\FL_LTI_models\\A_from_LTI.txt')
B = np.loadtxt(cwd+'\\'+'fromFlightPhysics\\FL_LTI_models\\B_from_LTI.txt')
C = np.loadtxt(cwd+'\\'+'fromFlightPhysics\\FL_LTI_models\\C_from_LTI.txt')
D = np.loadtxt(cwd+'\\'+'fromFlightPhysics\\FL_LTI_models\\D_from_LTI.txt')

sh09 = control.ss(A, B, C, D)

# Set time
T_in = np.asarray(np.linspace(0, 3, 100, endpoint=True))

youts = []
for i_input in range(n_inputs):

	T, yout = control.step_response(sh09, T = T_in, input = i_input, output = None)

	youts += [yout, ]

figure, axs = plt.subplots(6, n_inputs, sharex = 'col')
figure.set_size_inches(10, 14, forward=True)


i_input = 0
for yout in youts:
	
	for i_out in range(6):

		axs[i_out, i_input].plot(T, yout[i_out, :], linestyle = '-',  c = plotSettings['colors'][0], **plotSettings['line'])

		axs[i_out, i_input].tick_params(axis='both', **plotSettings['axesTicks'])
		
		#Plotting axes
		if i_input == 0:
			axs[i_out, i_input].set_ylabel('To: '+outputsList[i_out]+outputsUnitsDict[i_out//3], **plotSettings['axes_y'])

		if i_out == 5:
			axs[i_out, i_input].set_xlabel('t [s]', **plotSettings['axes_x'])

		elif i_out == 0:
			axs[i_out, i_input].set_title('From: '+inputsList[i_input], **plotSettings['title'])

		axs[i_out, i_input].grid(which='both', **plotSettings['grid'])

	i_input += 1

# ax.legend(**plotSettings['legend'])

plt.show(block = True)
