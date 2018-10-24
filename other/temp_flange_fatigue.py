import numpy as np
import matplotlib.pyplot as plt
import pdb
import os
import sys

from moduleFunctions import *

plotSettings = importPlottingOptions()

format_chosen = 'long'#short

if format_chosen == 'long':
	file = open('L:\\MSH-Project Management Files\\Functional Engineering\\Test Division\\Test_Daten\\J17-03-Bench Tests\\P3-J17-03-BT0228\\01_Data_set\\01_RAW\\Run 4 - First run - Failure at 122000 cycles\\Run_4_Measured values.csv', 'r')
elif format_chosen == 'short':
	file = open('L:\\MSH-Project Management Files\\Functional Engineering\\Test Division\\Test_Daten\\J17-03-Bench Tests\\P3-J17-03-BT0228\\01_Data_set\\01_RAW\\Run 4 - First run - Failure at 122000 cycles\\Run_4_Last 200 cycles.csv', 'r')
lines = file.readlines()

dataDict = {'cycle':0,'displ':1,'force':3,'freq':4,'time':5}

testing_step = 0.01

cycle, displ, force, freq, time = [], [], [], [], []
skipLines, counter = 2, 0

totalLines = len(lines)
for line in lines[skipLines:]:

	data0 = cleanString(line)

	data1 = data0.replace(',','.')

	data2 = data1.split(';')

	# pdb.set_trace()

	if format_chosen == 'long':
		cycle += [float(data2[0])]
		displ += [float(data2[1])]
		force += [float(data2[3])]
		time += [float(data2[5])]

	elif format_chosen == 'short':
		cycle += [float(data2[0])]
		displ += [float(data2[1])]
		force += [float(data2[2])]
		time += [float(data2[3])]

	status = round((counter/totalLines)* 100, 2)
	sys.stdout.write('-----> Status: '+ str(status) +'% \r')
	sys.stdout.flush()

	counter += 1

file.close()

print('Plotting')

figure, axs = plt.subplots(2, 1, sharex='col')
figure.set_size_inches(16, 10, forward=True)
axs[0].plot( time, displ, linestyle = '', marker = 'o', c = plotSettings['colors'][0], label = 'displ', **plotSettings['line'])
axs[1].plot( time, force, linestyle = '', marker = 'o', c = plotSettings['colors'][0], label = 'force', **plotSettings['line'])

axs[0].set_ylabel('Displ [mm]', **plotSettings['axes_y'])
axs[1].set_ylabel('Force [KN]', **plotSettings['axes_y'])

axs[-1].set_xlabel('Time [s]', **plotSettings['axes_x'])

for ax in axs:
	usualSettingsAX(ax, plotSettings)

plt.show(block = True)