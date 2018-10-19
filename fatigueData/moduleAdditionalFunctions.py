import pdb
import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats as st
import scipy.linalg as lalg
from scipy import interpolate
import statistics as stat
import math
import getopt
import pdb #pdb.set_trace()

from moduleFunctions import *

def rsquared(x, y):
	""" Return R^2 where x and y are array-like."""

	slope, intercept, r_value, p_value, std_err = st.linregress(x, y)
	return r_value**2


def calculateFlowFlight(dataClasses, testFactor, orderDeriv, inputDataClass, plotSettings, CMDoptionsDict):

	# Pre-calc, automatic
	#############################
	dofs = []
	for var in CMDoptionsDict['variables']:
		for dof in ('LNG', 'LAT', 'COL'):
			if dof in var and not dof in dofs:
				dofs+=[dof]

	data_dst_di_Dict, data_frc_rs_Dict, figureDict, axsDict = {}, {}, {}, {}
	for dof in dofs:
		data_dst_di_Dict[dof] = [temp for temp in dataClasses if temp.get_description() == 'CNT_DST_BST_'+dof and temp.get_mag() == 'di'][0]
		data_frc_rs_Dict[dof] = [temp for temp in dataClasses if temp.get_description() == 'CNT_FRC_BST_'+dof and temp.get_mag() == 'rs'][0]
		
		figure, axs = plt.subplots(4, 2, sharex='all')
		figure.set_size_inches(16, 10, forward=True)
		figureDict[dof] = figure
		axsDict[dof] = axs
	# #####################################################

	# Constants
	coefsListDict_force = {
							'1' : {'right': [-0.0173,0.2138,-0.9386,1.6783,-0.6698,0.1313], 'left': [0.042,0.3649,0.9596,0.5208,0.1089]}, #System 1
							'2' : {'right': [-0.0073,0.0847,-0.3734,0.8092,-0.4751,0.0733], 'left': [0.0211,0.1412,0.2137,-0.3442,0.055]} #System 2
							}

	coefsListDict_temp_press = {
								'1' : [0.0001947181107924777,0.003059624094205853,0.09678837994880818], #System 1 at 150bar 
								'2' : [0.00017721930741852556,0.005693618965191619,-0.05458563700116385] #System 2 at 150bar 
								}

	areas_dict = {	'COL' : [(math.pi/4.0)*(np.power(20.0, 2) - np.power(15.0, 2)), math.pi*(np.power(20.0, 2) - np.power(13.5, 2))], 
					'CYC' : [(math.pi/4.0)*(np.power(18.0, 2) - np.power(15.0, 2)), ]}
	
	correspondence_areas_dict = {'COL' : 'COL', 'LNG' : 'CYC', 'LAT' : 'CYC'}
	markerDict = {'COL' : 'o', 'LNG' : 'o', 'LAT' : 'o'}
	colorsDict = {'COL' : 0, 'LNG' : 1, 'LAT' : 2}
	
	sysIDsDict = {'1' : 0 , '2' : 1}

	statusMax = 97 #%

	masterVar = 'temp' #'temp', 'dst'

	rangeForHighFreqSignal_original = 20

	q_TP_dofsDict, q_F_dofsDict, q_v_dofsDict, q_total_dofsDict = {}, {}, {}, {}
	for dof in dofs:

		print('\n\n--> Computing volume flow for flight test data for '+dof)

		q_TP_dof, q_F_dof, q_v_dof, q_total_dof = [[], []], [[], []], [[], []], [[], []]
		for sysID in sysIDsDict.keys():

			print('---> System '+sysID)
			
			# Temp depends on the system!
			data_temp = [temp for temp in dataClasses if temp.get_description() == 'HYD_ARI_MFD_TMP_'+sysID][0]
			
			if masterVar == 'dst':
				data_points_master = data_dst_di_Dict[dof].get_rs()
				time_vector_master = [t/data_dst_di_Dict[dof].get_freqData()[0] for t in data_dst_di_Dict[dof].get_timeRs()]
				time_vector_slave = [t/data_temp.get_freqData()[0] for t in data_temp.get_timeRs()]
			elif masterVar == 'temp':
				data_points_master = data_temp.get_rs()
				time_vector_master = [t/data_temp.get_freqData()[0] for t in data_temp.get_timeRs()]
				time_vector_slave = [t/data_dst_di_Dict[dof].get_freqData()[0] for t in data_dst_di_Dict[dof].get_timeRs()]

			assert len(data_points_master) == len(time_vector_master), 'ERROR for dimension master vectors'

			i = 0
			q_TP_vect, q_F_vect, q_v_vect, q_total_vect = [], [], [], []
			for p in data_points_master:

				rangeForHighFreqSignal = rangeForHighFreqSignal_original
				currentTime = time_vector_master[i] # Current time
				if masterVar == 'dst':
					index_slave = time_vector_slave.index([t for t in time_vector_slave if abs(currentTime-t)<(0.6*(1/data_temp.get_freqData()[0]))][0])
				elif masterVar == 'temp':
					index_slave = time_vector_slave.index([t for t in time_vector_slave if abs(currentTime-t)<(0.6*(1/data_dst_di_Dict[dof].get_freqData()[0]))][0])
					rangeForHighFreqSignal = min(index_slave, rangeForHighFreqSignal)
					rangeForHighFreqSignal = min(len(time_vector_slave) - index_slave - 2, rangeForHighFreqSignal)
				# ##############################################
				# Effect piston demand - NEED TO INCORPORATE DIFFERENT CHAMBERS SIZE
				factorConversion = 60.0/1E6 #mm^3/s to L/min
				if masterVar == 'dst':
					vel = abs(data_dst_di_Dict[dof].get_rs()[i])
				elif masterVar == 'temp':
					if index_slave != 0:
						vel = abs(np.mean(data_dst_di_Dict[dof].get_rs()[index_slave-rangeForHighFreqSignal:index_slave+rangeForHighFreqSignal]))
					else:
						vel = abs(np.mean(data_dst_di_Dict[dof].get_rs()[0]))

				q_v = vel * areas_dict[correspondence_areas_dict[dof]][0] * factorConversion
				# ##############################################
				# Effect temperature
				regre_TP = np.poly1d(coefsListDict_temp_press[sysID])
				
				# Find index in temp vector for current time
				if masterVar == 'dst':
					q_TP = regre_TP(data_temp.get_rs()[index_slave])
				elif masterVar == 'temp':
					q_TP = regre_TP(data_temp.get_rs()[i])

				# ##############################################
				# Effect force
				if masterVar == 'dst':
					force = data_frc_rs_Dict[dof].get_rs()[i]
				elif masterVar == 'temp':
					if index_slave != 0:
						force = np.mean(data_frc_rs_Dict[dof].get_rs()[index_slave-rangeForHighFreqSignal:index_slave+rangeForHighFreqSignal])
					else:
						force = np.mean(data_frc_rs_Dict[dof].get_rs()[0])
				if force > 0:
					side = 'right'
				else:
					side = 'left'
				regre_F = np.poly1d(coefsListDict_force[sysID][side])
				q_F = regre_TP(force / 1000.0) if regre_TP(force / 1000.0) > 0.0 else 0.0 #Correction necessary when the force is low, the regression fails

				# ##############################################
				# Final output
				q_TP_vect += [q_TP]
				q_F_vect += [q_F]
				q_v_vect += [q_v]
				q_total_vect += [q_TP + q_F + q_v]
				i+=1

				# Print processing status
				status = round((currentTime/time_vector_master[-1])*100, 2)
				sys.stdout.write('----> Status: '+ str(status) +'% of flight completed \r')
				sys.stdout.flush()

				if status > statusMax:
					q_TP_vect += [0.0] * (len(data_points_master) - i)
					q_F_vect += [0.0] * (len(data_points_master) - i)
					q_v_vect += [0.0] * (len(data_points_master) - i)
					q_total_vect += [0.0] * (len(data_points_master) - i)
					break

			# One system imported
			q_TP_dof[sysIDsDict[sysID]] = q_TP_vect
			q_F_dof[sysIDsDict[sysID]] = q_F_vect
			q_v_dof[sysIDsDict[sysID]] = q_v_vect
			q_total_dof[sysIDsDict[sysID]] = q_total_vect

		# One dof imported
		q_TP_dofsDict[dof] = q_TP_dof
		q_F_dofsDict[dof] = q_F_dof
		q_v_dofsDict[dof] = q_v_dof
		q_total_dofsDict[dof] = q_total_dof
		# Results
		for sysID in sysIDsDict.keys():

			# Temp depends on the system!
			data_temp = [temp for temp in dataClasses if temp.get_description() == 'HYD_ARI_MFD_TMP_'+sysID][0]

			# Temp
			axsDict[dof][0, sysIDsDict[sysID]].plot( [t/data_temp.get_freqData()[0] for t in data_temp.get_timeRs()], data_temp.get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Temp', **plotSettings['line'])
			axsDict[dof][0, sysIDsDict[sysID]].set_ylabel(inputDataClass.get_variablesInfoDict()[data_temp.get_mag()+'__'+data_temp.get_description()]['y-label'], **plotSettings['axes_y'])
			usualSettingsAXNoDoubleAxis(axsDict[dof][0, sysIDsDict[sysID]], plotSettings)
			
			# Force
			axsDict[dof][1, sysIDsDict[sysID]].plot( [t/data_frc_rs_Dict[dof].get_freqData()[0] for t in data_frc_rs_Dict[dof].get_timeRs()], data_frc_rs_Dict[dof].get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Force', **plotSettings['line'])
			axsDict[dof][1, sysIDsDict[sysID]].set_ylabel(inputDataClass.get_variablesInfoDict()[data_frc_rs_Dict[dof].get_mag()+'__'+data_frc_rs_Dict[dof].get_description()]['y-label'], **plotSettings['axes_y'])
			usualSettingsAXNoDoubleAxis(axsDict[dof][1, sysIDsDict[sysID]], plotSettings)

			# Velocity
			axsDict[dof][2, sysIDsDict[sysID]].plot( [t/data_dst_di_Dict[dof].get_freqData()[0] for t in data_dst_di_Dict[dof].get_timeRs()], data_dst_di_Dict[dof].get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Velocity', **plotSettings['line'])
			axsDict[dof][2, sysIDsDict[sysID]].set_ylabel(inputDataClass.get_variablesInfoDict()[data_dst_di_Dict[dof].get_mag()+'__'+data_dst_di_Dict[dof].get_description()]['y-label'], **plotSettings['axes_y'])
			usualSettingsAXNoDoubleAxis(axsDict[dof][2, sysIDsDict[sysID]], plotSettings)

			axsDict[dof][3, sysIDsDict[sysID]].plot( time_vector_master, q_TP_dof[sysIDsDict[sysID]], linestyle = '', marker = 'o', c = plotSettings['colors'][0], label = '$q_{T,P}$', **plotSettings['line'])
			axsDict[dof][3, sysIDsDict[sysID]].plot( time_vector_master, q_F_dof[sysIDsDict[sysID]], linestyle = '', marker = '^', c = plotSettings['colors'][1], label = '$q_F$', **plotSettings['line'])
			axsDict[dof][3, sysIDsDict[sysID]].plot( time_vector_master, q_v_dof[sysIDsDict[sysID]], linestyle = '', marker = 'v', c = plotSettings['colors'][2], label = '$q_v$', **plotSettings['line'])
			axsDict[dof][3, sysIDsDict[sysID]].plot( time_vector_master, q_total_dof[sysIDsDict[sysID]], linestyle = '', marker = 's', c = plotSettings['colors'][3], label = '$q_{total}$', **plotSettings['line'])
			axsDict[dof][3, sysIDsDict[sysID]].legend(**plotSettings['legend'])
			usualSettingsAXNoDoubleAxis(axsDict[dof][3, sysIDsDict[sysID]], plotSettings)

			axsDict[dof][0, sysIDsDict[sysID]].set_title('System '+sysID, **plotSettings['ax_title'])
			axsDict[dof][3, sysIDsDict[sysID]].set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])

		if CMDoptionsDict['saveFigure']:

			# Range files
			if len(CMDoptionsDict['rangeFileIDs']) < 8:
				rangeIDstring = ','.join([str(i) for i in CMDoptionsDict['rangeFileIDs']])
			else:
				rangeIDstring = str(CMDoptionsDict['rangeFileIDs'][0])+'...'+str(CMDoptionsDict['rangeFileIDs'][-1])

			figureDict[dof].suptitle(dof+' - '+rangeIDstring, **plotSettings['figure_title'])
			figureDict[dof].savefig('hyd_flux__'+dof+'__'+rangeIDstring+'.png', dpi = plotSettings['figure_settings']['dpi'])


	#Final summary plot
	figure, axs = plt.subplots(4, 1, sharex='col')
	figure.set_size_inches(16, 10, forward=True)
	# Temp
	data_temp1 = [temp for temp in dataClasses if temp.get_description() == 'HYD_ARI_MFD_TMP_1'][0]
	data_temp2 = [temp for temp in dataClasses if temp.get_description() == 'HYD_ARI_MFD_TMP_2'][0]
	axs[0].plot( [t/data_temp1.get_freqData()[0] for t in data_temp1.get_timeRs()], data_temp1.get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Temp SYS1', **plotSettings['line'])
	axs[0].plot( [t/data_temp2.get_freqData()[0] for t in data_temp2.get_timeRs()], data_temp2.get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][2], label = 'Temp SYS2', **plotSettings['line'])
	axs[0].set_ylabel(inputDataClass.get_variablesInfoDict()[data_temp.get_mag()+'__'+data_temp.get_description()]['y-label'], **plotSettings['axes_y'])
	axs[0].legend(**plotSettings['legend'])
	usualSettingsAXNoDoubleAxis(axs[0], plotSettings)
	
	# Force
	axs[1].plot( [t/data_frc_rs_Dict[dof].get_freqData()[0] for t in data_frc_rs_Dict[dof].get_timeRs()], data_frc_rs_Dict[dof].get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Force', **plotSettings['line'])
	axs[1].set_ylabel(inputDataClass.get_variablesInfoDict()[data_frc_rs_Dict[dof].get_mag()+'__'+data_frc_rs_Dict[dof].get_description()]['y-label'], **plotSettings['axes_y'])
	usualSettingsAXNoDoubleAxis(axs[1], plotSettings)

	# Velocity
	axs[2].plot( [t/data_dst_di_Dict[dof].get_freqData()[0] for t in data_dst_di_Dict[dof].get_timeRs()], data_dst_di_Dict[dof].get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Velocity', **plotSettings['line'])
	axs[2].set_ylabel(inputDataClass.get_variablesInfoDict()[data_dst_di_Dict[dof].get_mag()+'__'+data_dst_di_Dict[dof].get_description()]['y-label'], **plotSettings['axes_y'])
	usualSettingsAXNoDoubleAxis(axs[2], plotSettings)

	for dof in dofs:
		q_total_2sys = [p+u for p,u in zip(q_total_dofsDict[dof][0], q_total_dofsDict[dof][1])]
		axs[3].plot( [t/data_temp.get_freqData()[0] for t in data_temp.get_timeRs()], q_total_2sys, linestyle = '', marker = markerDict[dof], c = plotSettings['colors'][colorsDict[dof]], label = '$q_{'+dof+'}$', **plotSettings['line'])
	axs[3].legend(**plotSettings['legend'])
	
	for ax in axs:
		usualSettingsAX(ax, plotSettings)

	axs[-1].set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])

	figure.suptitle(rangeIDstring, **plotSettings['figure_title'])
	figureDict[dof].savefig('hyd_flux'+'__'+rangeIDstring+'.png', dpi = plotSettings['figure_settings']['dpi'])