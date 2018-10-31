import numpy as np
import matplotlib.pyplot as plt
import pdb
import os
import sys

sys.path.insert(0, 'P:\\kopter\\fatigueData')

from moduleFunctions import *

plotSettings = importPlottingOptions()

format_chosen = 'long'#short

def importData(fileName, typeImport):

	file = open(fileName, 'r')
	
	lines = file.readlines()

	skipLines, counter = 2, 0

	cycle, displ, force, freq, time = [], [], [], [], []
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
		elif format_chosen in ('step_7', 'step_9'):
			displ += [float(data2[5])]
			force += [float(data2[6])]
			time += [float(data2[10])]

		status = round((counter/totalLines)* 100, 2)
		sys.stdout.write('-----> Status: '+ str(status) +'% \r')
		sys.stdout.flush()

		counter += 1

	file.close()

	out = {}
	out['cycle'] = cycle
	out['displ'] = displ
	out['force'] = force
	out['freq'] = freq
	out['time'] = time

	if format_chosen == 'step_7':
		displ_load, force_load, displ_unload, force_unload = [], [], [], []
		flagUnload = False
		for f,d in zip(force, displ):

			if d > 1.598:
				flagUnload = True

			if flagUnload:
				force_unload += [f]
				displ_unload += [d]
			else:
				force_load += [f]
				displ_load += [d]

		out['displ_load'] = displ_load
		out['force_load'] = force_load
		out['displ_unload'] = displ_unload
		out['force_unload'] = force_unload

	return out

# file = open('L:\\MSH-Project Management Files\\Functional Engineering\\Test Division\\Test_Daten\\J17-03-Bench Tests\\P3-J17-03-BT0228\\01_Data_set\\01_RAW\\Run 4 - First run - Failure at 122000 cycles\\Run_4_Last 200 cycles.csv', 'r')
# file = open('L:\\MSH-Project Management Files\\Functional Engineering\\Test Division\\Test_Daten\\J17-03-Bench Tests\\P3-J17-03-BT0228\\01_Data_set\\01_RAW\\Run 4 - First run - Failure at 122000 cycles\\Run_4_Measured values.csv', 'r')

print('Plotting')

if False:
	if format_chosen == 'short':
		outData = importData('L:\\MSH-Project Management Files\\Functional Engineering\\Test Division\\Test_Daten\\J17-03-Bench Tests\\P3-J17-03-BT0228\\01_Data_set\\01_RAW\\Run 4 - First run - Failure at 122000 cycles\\Run_4_Last 200 cycles.csv', format_chosen)
	elif format_chosen == 'long':
		outData = importData('L:\\MSH-Project Management Files\\Functional Engineering\\Test Division\\Test_Daten\\J17-03-Bench Tests\\P3-J17-03-BT0228\\01_Data_set\\01_RAW\\Run 4 - First run - Failure at 122000 cycles\\Run_4_Measured values.csv', format_chosen)

	figure, axs = plt.subplots(2, 1, sharex='col')
	figure.set_size_inches(16, 10, forward=True)

	i=0
	y_labels = ['Displ [mm]', 'Force [KN]']
	for var in ['displ', 'force']:

		axs[i].plot( [j/100 for j in outData['time']], outData[var], linestyle = '', marker = 'o', c = plotSettings['colors'][0], label = 'displ', **plotSettings['line'])
		axs[i].set_ylabel(y_labels[i], **plotSettings['axes_y'])

		i+=1
	axs[-1].set_xlabel('Thousands of cycles', **plotSettings['axes_x'])
	for ax in axs:
		usualSettingsAX(ax, plotSettings)

if False:

	if format_chosen == 'short':
		outData = importData('L:\\MSH-Project Management Files\\Functional Engineering\\Test Division\\Test_Daten\\J17-03-Bench Tests\\P3-J17-03-BT0228\\01_Data_set\\01_RAW\\Run 4 - First run - Failure at 122000 cycles\\Run_4_Last 200 cycles.csv', format_chosen)
	elif format_chosen == 'short':
		outData = importData('L:\\MSH-Project Management Files\\Functional Engineering\\Test Division\\Test_Daten\\J17-03-Bench Tests\\P3-J17-03-BT0228\\01_Data_set\\01_RAW\\Run 4 - First run - Failure at 122000 cycles\\Run_4_Measured values.csv', format_chosen)

	figure, axs = plt.subplots(3, 2, sharex='col')
	figure.set_size_inches(16, 10, forward=True)

	i=0
	y_labels = ['Displ [mm]', 'Force [KN]']
	for var in ['displ', 'force']:

		axs[0, i].plot( outData['time'], outData[var], linestyle = '', marker = 'o', c = plotSettings['colors'][0], label = 'displ', **plotSettings['line'])
		axs[0, i].set_title('Raw data', **plotSettings['ax_title'])
		# Filter data
		fs = 1/(outData['time'][1]-outData['time'][0])
		cut_off_freq = 0.99
		low_pass_data = filter(outData[var], fs, 'low-pass', cut_off_freq)
		high_pass_data = filter(outData[var], fs, 'high-pass', cut_off_freq)
		axs[1, i].plot( outData['time'], low_pass_data, linestyle = '', marker = 'o', c = plotSettings['colors'][0], label = 'displ', **plotSettings['line'])
		axs[1, i].set_title('Low-pass filtered data, $f_{cut-off}$ = '+str(cut_off_freq)+' Hz', **plotSettings['ax_title'])
		axs[2, i].plot( outData['time'], high_pass_data, linestyle = '', marker = 'o', c = plotSettings['colors'][0], label = 'displ', **plotSettings['line'])
		axs[2, i].set_title('High-pass filtered data, $f_{cut-off}$ = '+str(cut_off_freq)+' Hz', **plotSettings['ax_title'])

		axs[-1, i].set_xlabel('Time [s]', **plotSettings['axes_x'])
		for ax in axs[:,i]:
			ax.set_ylabel(y_labels[i], **plotSettings['axes_y'])
			usualSettingsAX(ax, plotSettings)

		i+=1

if True:

	format_chosen_array = ('step_7','step_9')

	figure, axs = plt.subplots(2, 2, sharey='row')
	figure.set_size_inches(16, 10, forward=True)

	filesNames = ('L:\\MSH-Project Management Files\\Functional Engineering\\Test Division\\Test_Daten\\J17-03-Bench Tests\\P3-J17-03-BT0228\\01_Data_set\\01_RAW\\Step 7\\Run_5_Measured values.csv',
				'L:\\MSH-Project Management Files\\Functional Engineering\\Test Division\\Test_Daten\\J17-03-Bench Tests\\P3-J17-03-BT0228\\01_Data_set\\01_RAW\\Step 9\\Run_6_Measured values.csv')
	limits, newAxis = [8.250, 12.350], []
	titles = ('Step #7 - Target: ', 'Step #9 - Target: ')
	for i in range(len(filesNames)):

		format_chosen = format_chosen_array[i]

		outData = importData(filesNames[i], format_chosen)

		if format_chosen == 'step_7':
			axs[i, 0].plot( outData['displ_load'], outData['force_load'], linestyle = '', marker = 'o', c = plotSettings['colors'][0], label = 'load', **plotSettings['line'])
			axs[i, 0].plot( outData['displ_unload'], outData['force_unload'], linestyle = '', marker = 'o', c = 'b', label = 'unload', **plotSettings['line'])
			axs[i, 0].legend(**plotSettings['legend'])
		else:
			axs[i, 0].plot( outData['displ'], outData['force'], linestyle = '', marker = 'o', c = plotSettings['colors'][0], label = 'force', **plotSettings['line'])
		
		axs[i, 1].plot( outData['time'], outData['force'], linestyle = '', marker = 'o', c = plotSettings['colors'][0], label = 'force', **plotSettings['line'])

		xOldLim = axs[i,1].get_xlim()
		axs[i,1].plot( xOldLim, 2*[limits[i]], linestyle = '--', marker = '', c = 'r', scalex = False, scaley = False, **plotSettings['line'])
		xOldLim = axs[i,0].get_xlim()
		axs[i,0].plot( xOldLim, 2*[limits[i]], linestyle = '--', marker = '', c = 'r', scalex = False, scaley = False, **plotSettings['line'])

		axs[i,0].set_ylabel(titles[i]+str(limits[i])+' KN'+'\n\n'+'Force [KN]', **plotSettings['axes_y'])

		axs[i,0].set_xlabel('Displ [mm]', **plotSettings['axes_x'])
		axs[i,1].set_xlabel('Time [s]', **plotSettings['axes_x'])

		usualSettingsAXNoDoubleAxis(axs[i, 0], plotSettings)
		newAxis += [usualSettingsAX(axs[i, 1], plotSettings)]

	makeZoomViewFlag = True
	if makeZoomViewFlag:
		axs[0, 0].set_xlim(1.565, 1.6)
		axs[0, 0].set_ylim(8.235, 8.27)
		axs[0, 1].set_ylim(8.235, 8.27)
		newAxis[0].set_ylim(8.235, 8.27)
		axs[0, 1].set_xlim(26, 34)

		axs[1, 0].set_xlim(3.74, 3.88)
		axs[1, 0].set_ylim(12.30, 12.39)
		axs[1, 1].set_ylim(12.30, 12.39)
		newAxis[1].set_ylim(12.30, 12.39)
		axs[1, 1].set_xlim(40.5, 43.5)

plt.show(block = True)