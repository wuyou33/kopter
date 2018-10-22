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


def calculateFlowFlight(dataClasses, inputDataClass, plotSettings, CMDoptionsDict):
	# ################################
	# Sub-function to analyze the volumetric flight for  

	def getSegmentDataFn(dataClass_dst_di, dataClass_frc_rs, dataClass_temp, timeSegment):
		
		t1 = timeSegment[0]
		t2 = timeSegment[1]

		dataClassesDict = {'dst_di':dataClass_dst_di, 'frc_rs':dataClass_frc_rs, 'temp':dataClass_temp}

		timeDict, dataDict = {}, {}
		for var in dataClassesDict.keys():
			time_temp = [t/dataClassesDict[var].get_freqData()[0] for t in dataClassesDict[var].get_timeRs()]

			first_index = time_temp.index([t for t in time_temp if abs(t1-t)<(0.6*(1/dataClassesDict[var].get_freqData()[0]))][0])
			second_index = time_temp.index([t for t in time_temp if abs(t2-t)<(0.6*(1/dataClassesDict[var].get_freqData()[0]))][0])

			timeDict[var] = time_temp[first_index : second_index]
			dataDict[var] = dataClassesDict[var].get_rs()[first_index : second_index]

		return timeDict, dataDict

	# Pre-calc, automatic
	#############################

	# Get degrees of freedom - OUT: dofs
	dofs = []
	for var in CMDoptionsDict['variables']:
		for dof in ('LNG', 'LAT', 'COL'):
			if dof in var and not dof in dofs:
				dofs+=[dof]
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
	markerDict_dof = {'COL' : 'o', 'LNG' : 'o', 'LAT' : 'o'}
	colorsDict_dof = {'COL' : 0, 'LNG' : 1, 'LAT' : 2}

	colorsDict_var = {'q_TP' : 0, 'q_F' : 1, 'q_v' : 2, 'q_total' : 3} #Used to get the keys
	markerDict_var = {'q_TP' : 'o', 'q_F' : '^', 'q_v' : 'v', 'q_total' : 's'}
	labelsDict_var = {'q_TP' : '$q_{T,P}$', 'q_F' : '$q_F$', 'q_v' : '$q_v$', 'q_total' : '$q_{total}$'}
	
	sysIDsDict = {'1' : 0 , '2' : 1}

	tempRange = [60, 70, 80, 90, 100, 110]

	tempRangeFlag = True

	# Get data 
	data_dst_di_Dict, data_frc_rs_Dict, data_tempDict = {}, {}, {}
	for dof in dofs:
		data_dst_di_Dict[dof] = [temp for temp in dataClasses if temp.get_description() == 'CNT_DST_BST_'+dof and temp.get_mag() == 'di'][0]
		data_frc_rs_Dict[dof] = [temp for temp in dataClasses if temp.get_description() == 'CNT_FRC_BST_'+dof and temp.get_mag() == 'rs'][0]

	for sysID in sysIDsDict.keys():
		data_tempDict[sysID] = [temp for temp in dataClasses if temp.get_description() == 'HYD_ARI_MFD_TMP_'+sysID][0]


	masterVar = 'temp' #'temp', 'dst'

	rangeForHighFreqSignal_original = 20

	segmentsOfTime = [
					 [500, 5000],
					 [500, 5000]
					 ]

	# Initialize figures
	figureDict, axsDict = {}, {}
	for dof in dofs:
		if tempRangeFlag:
			figure, axs = plt.subplots(5, 2, sharex='all')
		else:
			figure, axs = plt.subplots(4, 2, sharex='all')
		figure.set_size_inches(16, 10, forward=True)
		figureDict[dof] = figure
		axsDict[dof] = axs

	resultsPerSegment = []
	for timeSegment in segmentsOfTime:

		t1 = timeSegment[0]
		t2 = timeSegment[1]

		q_TP_dofsDict, q_F_dofsDict, q_v_dofsDict, q_total_dofsDict, time_dofsDict, q_total_tempRange_dofsDict = {}, {}, {}, {}, {}, {}
		for dof in dofs:

			print('\n\n--> Computing volume flow for flight test data for '+dof)

			q_TP_sysList, q_F_sysList, q_v_sysList, q_total_sysList, time_sysList, q_total_tempRange_sysList = [[], []], [[], []], [[], []], [[], []], [[], []], [[], []]
			for sysID in sysIDsDict.keys():

				print('---> System '+sysID)

				# Create data for system, dof and segment:
				# -> temp, data and time
				# -> dst_di, data and time
				# -> frc_rs, data and time
				# Temp depends on the system!

				timeDict, dataDict = getSegmentDataFn(data_dst_di_Dict[dof], data_frc_rs_Dict[dof], data_tempDict[sysID], timeSegment)
				
				if masterVar == 'dst':
					data_points_master = dataDict['dst_di'] #data_dst_di_Dict[dof].get_rs()
					time_vector_master = timeDict['dst_di'] #[t/data_dst_di_Dict[dof].get_freqData()[0] for t in data_dst_di_Dict[dof].get_timeRs()]
					time_vector_slave = timeDict['temp'] #[t/data_temp.get_freqData()[0] for t in data_temp.get_timeRs()]
				elif masterVar == 'temp':
					data_points_master = dataDict['temp']
					time_vector_master = timeDict['temp']
					time_vector_slave = timeDict['dst_di']

				assert len(data_points_master) == len(time_vector_master), 'ERROR for dimension master vectors'

				i = 0
				q_TP_vect, q_F_vect, q_v_vect, q_total_vect, q_total_vect_tempRange = [], [], [], [], []
				for p in data_points_master:

					rangeForHighFreqSignal = rangeForHighFreqSignal_original
					currentTime = time_vector_master[i] # Current time
					if masterVar == 'dst':
						index_slave = time_vector_slave.index([t for t in time_vector_slave if abs(currentTime-t)<(0.6*(1/data_tempDict[sysID].get_freqData()[0]))][0])
					elif masterVar == 'temp':
						index_slave = time_vector_slave.index([t for t in time_vector_slave if abs(currentTime-t)<(0.6*(1/data_dst_di_Dict[dof].get_freqData()[0]))][0])
						rangeForHighFreqSignal = min(index_slave, rangeForHighFreqSignal)
						rangeForHighFreqSignal = min(len(time_vector_slave) - index_slave - 2, rangeForHighFreqSignal)
					# ##############################################
					# Effect piston demand - NEED TO INCORPORATE DIFFERENT CHAMBERS SIZE
					factorConversion = 60.0/1E6 #mm^3/s to L/min
					if masterVar == 'dst':
						vel = abs(dataDict['dst_di'][i]) #abs(data_dst_di_Dict[dof].get_rs()[i])
					elif masterVar == 'temp':
						if index_slave != 0:
							vel = abs(np.mean(dataDict['dst_di'][index_slave-rangeForHighFreqSignal:index_slave+rangeForHighFreqSignal]))
						else:
							vel = abs(np.mean(dataDict['dst_di'][0]))

					q_v = vel * areas_dict[correspondence_areas_dict[dof]][0] * factorConversion
					# ##############################################
					# Effect temperature
					regre_TP = np.poly1d(coefsListDict_temp_press[sysID])
					
					# Find index in temp vector for current time
					if masterVar == 'dst':
						q_TP = regre_TP(dataDict['temp'][index_slave])
					elif masterVar == 'temp':
						q_TP = regre_TP(dataDict['temp'][i])

					if tempRangeFlag:
						q_TP_range = []
						for t in tempRange:
							q_TP_range += regre_TP(t)

					# ##############################################
					# Effect force
					if masterVar == 'dst':
						force = dataDict['frc_rs'][i]
					elif masterVar == 'temp':
						if index_slave != 0:
							force = np.mean(dataDict['frc_rs'][index_slave-rangeForHighFreqSignal:index_slave+rangeForHighFreqSignal])
						else:
							force = np.mean(dataDict['frc_rs'][0])
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

					# Temperature ranges
					if tempRangeFlag:
						q_total_tempRange = []
						for q_TP_current in q_TP_range:
							q_total_tempRange += [q_TP_current + q_F + q_v]

						q_total_vect_tempRange += [q_total_tempRange]

					i+=1

					# Print processing status
					status = round((currentTime/time_vector_master[-1])*100, 2)
					sys.stdout.write('----> Status: '+ str(status) +'% of current segment completed \r')
					sys.stdout.flush()

					if status > statusMax:
						q_TP_vect += [0.0] * (len(data_points_master) - i)
						q_F_vect += [0.0] * (len(data_points_master) - i)
						q_v_vect += [0.0] * (len(data_points_master) - i)
						q_total_vect += [0.0] * (len(data_points_master) - i)
						if tempRangeFlag:
							q_total_vect_tempRange += [0.0] * (len(data_points_master) - i)
						break

				# One system imported
				q_TP_sysList[sysIDsDict[sysID]] = q_TP_vect
				q_F_sysList[sysIDsDict[sysID]] = q_F_vect
				q_v_sysList[sysIDsDict[sysID]] = q_v_vect
				q_total_sysList[sysIDsDict[sysID]] = q_total_vect
				time_sysList[sysIDsDict[sysID]] = time_vector_master

				if tempRangeFlag:
					q_total_tempRange_sysList[sysIDsDict[sysID]] = q_total_vect_tempRange

			# One dof imported
			q_TP_dofsDict[dof] = q_TP_sysList
			q_F_dofsDict[dof] = q_F_sysList
			q_v_dofsDict[dof] = q_v_sysList
			q_total_dofsDict[dof] = q_total_sysList
			time_dofsDict[dof] = time_sysList
			if tempRangeFlag:
				q_total_tempRange_dofsDict[dof] = q_total_tempRange_sysList

		# One segment imported
		temporal_segmentDict = {}
		temporal_segmentDict['q_TP'] = q_TP_dofsDict
		temporal_segmentDict['q_F'] = q_F_dofsDict
		temporal_segmentDict['q_v'] = q_v_dofsDict
		temporal_segmentDict['q_total'] = q_total_dofsDict
		temporal_segmentDict['time'] = time_dofsDict
		if tempRangeFlag:
			temporal_segmentDict['q_total_tempRange'] = q_total_tempRange_dofsDict

		resultsPerSegment += temporal_segmentDict

	# Results
	for sysID in sysIDsDict.keys():

		# Temp
		axsDict[dof][0, sysIDsDict[sysID]].plot( [t/data_tempDict[sysID].get_freqData()[0] for t in data_tempDict[sysID].get_timeRs()], data_tempDict[sysID].get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Temp', **plotSettings['line'])
		axsDict[dof][0, sysIDsDict[sysID]].set_ylabel(inputDataClass.get_variablesInfoDict()[data_tempDict[sysID].get_mag()+'__'+data_tempDict[sysID].get_description()]['y-label'], **plotSettings['axes_y'])
		usualSettingsAXNoDoubleAxis(axsDict[dof][0, sysIDsDict[sysID]], plotSettings)
		
		# Force
		axsDict[dof][1, sysIDsDict[sysID]].plot( [t/data_frc_rs_Dict[dof].get_freqData()[0] for t in data_frc_rs_Dict[dof].get_timeRs()], data_frc_rs_Dict[dof].get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Force', **plotSettings['line'])
		axsDict[dof][1, sysIDsDict[sysID]].set_ylabel(inputDataClass.get_variablesInfoDict()[data_frc_rs_Dict[dof].get_mag()+'__'+data_frc_rs_Dict[dof].get_description()]['y-label'], **plotSettings['axes_y'])
		usualSettingsAXNoDoubleAxis(axsDict[dof][1, sysIDsDict[sysID]], plotSettings)

		# Velocity
		axsDict[dof][2, sysIDsDict[sysID]].plot( [t/data_dst_di_Dict[dof].get_freqData()[0] for t in data_dst_di_Dict[dof].get_timeRs()], data_dst_di_Dict[dof].get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Velocity', **plotSettings['line'])
		axsDict[dof][2, sysIDsDict[sysID]].set_ylabel(inputDataClass.get_variablesInfoDict()[data_dst_di_Dict[dof].get_mag()+'__'+data_dst_di_Dict[dof].get_description()]['y-label'], **plotSettings['axes_y'])
		usualSettingsAXNoDoubleAxis(axsDict[dof][2, sysIDsDict[sysID]], plotSettings)

		# Volumetric flow calculated
		handlesList = []
		for var in colorsDict_var.keys():
			# Results per segment
			# resultsPerSegment[var][dof][sysIDsDict[sysID]]
			handlesList += plt.Line2D([],[], color=plotSettings['colors'][colorsDict_var[var]], marker=markerDict_var[var], linestyle='', label=labelsDict_var[var])
			for segment_index in range(len(segmentsOfTime)):
				axsDict[dof][3, sysIDsDict[sysID]].plot( resultsPerSegment[segment_index]['time'][dof][sysIDsDict[sysID]], resultsPerSegment[segment_index][var][dof][sysIDsDict[sysID]], linestyle = '', marker = markerDict_var[var], c = plotSettings['colors'][colorsDict_var[var]], label = labelsDict_var[var], **plotSettings['line'])
		
		axsDict[dof][3, sysIDsDict[sysID]].set_ylabel('Vol. flow [L/min]', **plotSettings['axes_y'])
		axsDict[dof][3, sysIDsDict[sysID]].legend(handles = handlesList, **plotSettings['legend'])
		usualSettingsAXNoDoubleAxis(axsDict[dof][3, sysIDsDict[sysID]], plotSettings)

		# Volumetric flow for temp ranges
		if tempRangeFlag:
			handlesList = []
			for temp_index in range(list(tempRange)):
				# Results per segment
				# resultsPerSegment[var][dof][sysIDsDict[sysID]]
				handlesList += plt.Line2D([],[], color=plotSettings['colors'][temp_index], marker='o', linestyle='', label=tempRange[temp_index]+'$^\circ$C')
				for segment_index in range(len(segmentsOfTime)):
					for timeCurrent_index in range(len(resultsPerSegment[segment_index]['time'][dof][sysIDsDict[sysID]])):
						axsDict[dof][4, sysIDsDict[sysID]].plot( resultsPerSegment[segment_index]['time'][dof][sysIDsDict[sysID]][timeCurrent_index], resultsPerSegment[segment_index]['q_total_tempRange'][dof][sysIDsDict[sysID]][timeCurrent_index][temp_index], linestyle = '', marker = 'o', c = plotSettings['colors'][temp_index], label = tempRange[temp_index]+'$^\circ$C', **plotSettings['line'])
			
			axsDict[dof][4, sysIDsDict[sysID]].set_ylabel('Vol. flow [L/min]', **plotSettings['axes_y'])
			axsDict[dof][4, sysIDsDict[sysID]].legend(handles = handlesList, **plotSettings['legend'])
			usualSettingsAXNoDoubleAxis(axsDict[dof][4, sysIDsDict[sysID]], plotSettings)

		axsDict[dof][0, sysIDsDict[sysID]].set_title('System '+sysID, **plotSettings['ax_title'])
		axsDict[dof][-1, sysIDsDict[sysID]].set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])


	if CMDoptionsDict['saveFigure']:

		# Range files
		if len(CMDoptionsDict['rangeFileIDs']) < 8:
			rangeIDstring = ','.join([str(i) for i in CMDoptionsDict['rangeFileIDs']])
		else:
			rangeIDstring = str(CMDoptionsDict['rangeFileIDs'][0])+'...'+str(CMDoptionsDict['rangeFileIDs'][-1])

		figureDict[dof].suptitle(dof+' - '+rangeIDstring, **plotSettings['figure_title'])
		figureDict[dof].savefig('hyd_flux__'+dof+'__'+rangeIDstring+'.png', dpi = plotSettings['figure_settings']['dpi'])

	# ################################################
	#Final summary plot
	if tempRangeFlag:
		figure, axs = plt.subplots(5, 1, sharex='col')
	else:
		figure, axs = plt.subplots(4, 1, sharex='col')
	figure.set_size_inches(16, 10, forward=True)

	# Temp
	for sysID in sysIDsDict.keys()
		axs[0].plot( [t/data_tempDict[sysID].get_freqData()[0] for t in data_tempDict[sysID].get_timeRs()], data_tempDict[sysID].get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][sysIDsDict[sysID]], label = 'Temp SYS1', **plotSettings['line'])
	axs[0].set_ylabel(inputDataClass.get_variablesInfoDict()[data_tempDict[sysID].get_mag()+'__'+data_tempDict[sysID].get_description()]['y-label'], **plotSettings['axes_y'])
	axs[0].legend(**plotSettings['legend'])
	usualSettingsAXNoDoubleAxis(axs[0], plotSettings)
	
	# Force and velocity
	for dof in dofs:
		# Force
		axs[1].plot( [t/data_frc_rs_Dict[dof].get_freqData()[0] for t in data_frc_rs_Dict[dof].get_timeRs()], data_frc_rs_Dict[dof].get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][colorsDict_dof[dof]], label = 'Force-'+dof, **plotSettings['line'])

		# Velocity
		axs[2].plot( [t/data_dst_di_Dict[dof].get_freqData()[0] for t in data_dst_di_Dict[dof].get_timeRs()], data_dst_di_Dict[dof].get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][colorsDict_dof[dof]], label = 'Velocity-'+dof, **plotSettings['line'])
	
	axs[1].legend(**plotSettings['legend'])
	axs[2].legend(**plotSettings['legend'])
	axs[1].set_ylabel(inputDataClass.get_variablesInfoDict()[data_frc_rs_Dict[dof].get_mag()+'__'+data_frc_rs_Dict[dof].get_description()]['y-label'], **plotSettings['axes_y'])
	usualSettingsAXNoDoubleAxis(axs[1], plotSettings)
	axs[2].set_ylabel(inputDataClass.get_variablesInfoDict()[data_dst_di_Dict[dof].get_mag()+'__'+data_dst_di_Dict[dof].get_description()]['y-label'], **plotSettings['axes_y'])
	usualSettingsAXNoDoubleAxis(axs[2], plotSettings)

	# Volumetric flow recorded
	if tempRangeFlag:
	handlesList = []
	for temp_index in range(list(tempRange)):
		for segment_index in range(len(segmentsOfTime)):
			handlesList += plt.Line2D([],[], color=plotSettings['colors'][temp_index], marker='o', linestyle='', label='$q_{COL,LAT,LON}$/'+tempRange[temp_index]+'$^\circ$C')
			for timeCurrent_index in range(len(resultsPerSegment[segment_index]['time'][dof][sysIDsDict[sysID]])):
				q_current_sum = 0.0
				for dof in dofs:
					for sysID in sysIDsDict.keys()
						q_current_sum += resultsPerSegment[segment_index]['q_total_tempRange'][dof][sysIDsDict[sysID]][timeCurrent_index][temp_index]
				axs[4].plot( timeCurrent, q_current_sum, linestyle = '', marker = 'o', c = plotSettings['colors'][temp_index], label = '$q_{COL,LAT,LON}$/'+tempRange[temp_index]+'$^\circ$C', **plotSettings['line'])
	axs[4].set_ylabel('Vol. flow [L/min]', **plotSettings['axes_y'])
	axs[4].legend(handles = handlesList, **plotSettings['legend'])
	
	for ax in axs:
		usualSettingsAX(ax, plotSettings)

	axs[-1].set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])

	figure.suptitle(rangeIDstring, **plotSettings['figure_title'])
	figure.savefig('hyd_flux'+'__'+rangeIDstring+'.png', dpi = plotSettings['figure_settings']['dpi'])