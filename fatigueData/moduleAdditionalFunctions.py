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

def internalLeakageVSTemp_regression(dataClasses, inputDataClass, plotSettings, CMDoptionsDict):
	
	dataTemp1 = [temp for temp in dataClasses if temp.get_description() == 'Temp1'][0]
	dataTemp2 = [temp for temp in dataClasses if temp.get_description() == 'Temp2'][0]
	dataVolFlow1 = [temp for temp in dataClasses if temp.get_description() == 'VolFlow1'][0]
	dataVolFlow2 = [temp for temp in dataClasses if temp.get_description() == 'VolFlow2'][0]

	stepStrs = dataTemp1.get_stepID()
	indexDictForSteps = {}
	for id_curr in stepStrs:
		indexDictForSteps[id_curr] = stepStrs.index(id_curr)

	figure, axs = plt.subplots(2, 1)
	figure.set_size_inches(16, 10, forward=True)
	markerDict = {'3-SN002-1.3':'o',	'8-SN002-2.4':'+',	'10-SN0012-1.3':'o',	'13-SN0012-2.4':'+', '3-Step-1.3':'o',	'7-Step-2.4':'+', '11-Step-2.4-Repeat':'+', '26-Step-2.4-Repeat2':'+'}
	linestyleDict = {'3-SN002-1.3':'',	'8-SN002-2.4':'',	'10-SN0012-1.3':'',	'13-SN0012-2.4':'', '3-Step-1.3':'',	'7-Step-2.4':'', '11-Step-2.4-Repeat':'', '26-Step-2.4-Repeat2':''}
	colorsDict = {'3-SN002-1.3':plotSettings['colors'][0],	'8-SN002-2.4':plotSettings['colors'][0],	'10-SN0012-1.3':plotSettings['colors'][1],	'13-SN0012-2.4':plotSettings['colors'][1], '3-Step-1.3':plotSettings['colors'][2], '7-Step-2.4':plotSettings['colors'][2], '11-Step-2.4-Repeat':plotSettings['colors'][1], '26-Step-2.4-Repeat2':plotSettings['colors'][0]}
	labelsDict = {'3-SN002-1.3':'SN002 / 100bar / CF ON',	'8-SN002-2.4':'SN002 / 100bar', '10-SN0012-1.3':'SN0012 / 100bar / CF ON', '13-SN0012-2.4':'SN0012 / 100bar', '3-Step-1.3':'SN002 / 150bar / CF ON', '7-Step-2.4':'SN002 / 150bar', '11-Step-2.4-Repeat':'SN002 / 150bar / Repeat', '26-Step-2.4-Repeat2':'SN002 / 150bar / Repeat'}
	titlesDict = {0 : 'System 1', 1: 'System 2'}
	i=0
	for dataTemp,dataVolFlow in zip([dataTemp1,dataTemp2],[dataVolFlow1,dataVolFlow2]):
		assert dataVolFlow.get_stepID() == dataTemp.get_stepID(), 'Error'
		for j in range(len(dataVolFlow.get_stepID())):
			axs[i].plot( dataTemp.get_rs_split()[j], dataVolFlow.get_rs_split()[j], linestyle = linestyleDict[dataVolFlow.get_stepID()[j]], marker = markerDict[dataVolFlow.get_stepID()[j]], c = colorsDict[dataVolFlow.get_stepID()[j]], label = labelsDict[dataVolFlow.get_stepID()[j]], **plotSettings['line'])
		axs[i].set_ylabel(inputDataClass.get_variablesInfoDict()[dataVolFlow.get_mag()+'__'+dataVolFlow.get_description()]['y-label'], **plotSettings['axes_y'])
		axs[i].set_title(titlesDict[i], **plotSettings['ax_title'])
		axs[i].legend(**plotSettings['legend'])
		usualSettingsAX(axs[i], plotSettings)
		i+=1
	axs[-1].set_xlabel(inputDataClass.get_variablesInfoDict()[dataTemp.get_mag()+'__'+dataTemp.get_description()]['y-label'], **plotSettings['axes_x'])

	# Regression
	dataTemps = [dataTemp1, dataTemp2]
	dataVolFlows = [dataVolFlow1, dataVolFlow2]
	figure, axs = plt.subplots(2, 1)
	figure.set_size_inches(16, 10, forward=True)
	markersDegreesDict = {1:'+', 2:'v', 3:'^'}
	for stepStr in dataVolFlow.get_stepID():
		if stepStr in ('7-Step-2.4', '13-SN0012-2.4', '8-SN002-2.4'):

			for sysID in range(2):
			
				print('\n--> Regression results for step '+stepStr +', sys: '+str(sysID+1))

				flow = dataVolFlows[sysID].get_rs_split()[indexDictForSteps[stepStr]]
				temp = dataTemps[sysID].get_rs_split()[indexDictForSteps[stepStr]]

				axs[sysID].plot( temp, flow, linestyle = '', marker = 'o', c = colorsDict[stepStr], label = stepStr, **plotSettings['line'])
				for degreeRangeCurrent in range(3):
					degree = 1+degreeRangeCurrent # 1, 2, 3
					p = np.polyfit(temp, flow, degree)
					regre = np.poly1d(p)

					# Regression results
					print('-> Regression results with '+str(degree)+' order curve:')
					print(','.join([str(o) for o in p]) + ' - R='+str(rsquared(temp, regre(temp))))

					axs[sysID].plot( temp, regre(temp), linestyle = '', marker = markersDegreesDict[degree], c = colorsDict[stepStr], label = str(degree)+' ord. regression', **plotSettings['line'])

	i = 0
	for ax in axs:
		ax.set_ylabel(inputDataClass.get_variablesInfoDict()[dataVolFlow1.get_mag()+'__'+dataVolFlow1.get_description()]['y-label'], **plotSettings['axes_y'])
		ax.set_title(titlesDict[i], **plotSettings['ax_title'])
		ax.legend(**plotSettings['legend'])
		usualSettingsAX(ax, plotSettings)
		
		i+=1
	axs[-1].set_xlabel('Temp. [$^\circ$C]', **plotSettings['axes_x'])

def internalLeakageVSForce_regression(dataClasses, inputDataClass, plotSettings, CMDoptionsDict):

	#Vector of steps
	dataTemp1 = [temp for temp in dataClasses if temp.get_description() == 'Temp1'][0]
	dataTemp2 = [temp for temp in dataClasses if temp.get_description() == 'Temp2'][0]
	dataVolFlow1 = [temp for temp in dataClasses if temp.get_description() == 'VolFlow1'][0]
	dataVolFlow2 = [temp for temp in dataClasses if temp.get_description() == 'VolFlow2'][0]			
	dataOutputForce = [temp for temp in dataClasses if temp.get_description() == 'OutputForce'][0]

	stepStrs = dataTemp1.get_stepID()
	indexDictForSteps = {}
	for id_curr in stepStrs:
		indexDictForSteps[id_curr] = stepStrs.index(id_curr)

	# Segments from tests at 100bar
	colorsDict = {'10-SN0012-1.3' :plotSettings['colors'][0], '3-SN002-1.3' :plotSettings['colors'][1], '1-Step-1.1':plotSettings['colors'][2], '3-Step-1.3':plotSettings['colors'][2]}
	markerDict = {'10-SN0012-1.3':'o', '3-SN002-1.3':'o', '1-Step-1.1':'o', '3-Step-1.3':'+'}
	labelsDict = {'10-SN0012-1.3':'SN0012-Step 1.3 (100bar test campaign)', '3-SN002-1.3':'SN002-Step 1.3 (100bar test campaign)', '1-Step-1.1':'SN002-Step 1.1 (150bar test campaign)', '3-Step-1.3':'SN002-Step 1.3 (150bar test campaign)'}
	titlesDict = {0 : 'System 1', 1: 'System 2'}
	executionFlags_VolflowVSForce_actuators = {}
	executionFlags_VolflowVSForce_actuators['10-SN0012-1.3'] = [  [692.8, 696.8]
																, [699.2, 703.8]
																, [714.6, 719.6]
																, [721.2, 724.0]
																, [729.5, 731.2]
																, [733.4, 737.4]
																, [740.9, 742.8]
																]
	executionFlags_VolflowVSForce_actuators['3-SN002-1.3'] = [[3339.2, 3341.8]
															, [3377.4, 3382]
															, [3392.5, 3394.75]
															, [3408.3, 3411.0]
															]
	executionFlags_VolflowVSForce_actuators['1-Step-1.1'] = [[50, 70] #Negative force
															, [90, 150] #Positive force
															]
	executionFlags_VolflowVSForce_actuators['3-Step-1.3'] = [[2235, 2250] #Negative force
															, [2260, 2290] #Positive force
															]
	
	# Figure initialization 
	figure_VolflowVSForce_actuators, axs = plt.subplots(2, 1, sharex='col', sharey='col')
	figure_VolflowVSForce_actuators.set_size_inches(16, 10, forward=True)
	figure_VolflowVSForce_actuators.suptitle('Increment of flow volume rate due to output force (effect of temperature and pressure removed)', **plotSettings['figure_title'])

	# #####################			
	correspondenceForStepsDict = {'3-SN002-1.3':'8-SN002-2.4', '10-SN0012-1.3':'13-SN0012-2.4', '1-Step-1.1':'7-Step-2.4', '3-Step-1.3':'7-Step-2.4'}

	results = {}
	for stepStr in ('3-Step-1.3', '10-SN0012-1.3', '3-SN002-1.3'):

		# Get interpolation function
		interpol_flow_s1 = interpolate.interp1d(dataTemp1.get_rs_split()[indexDictForSteps[correspondenceForStepsDict[stepStr]]], dataVolFlow1.get_rs_split()[indexDictForSteps[correspondenceForStepsDict[stepStr]]], kind = 'linear', bounds_error = False, fill_value = (min(dataVolFlow1.get_rs_split()[indexDictForSteps[correspondenceForStepsDict[stepStr]]]), max(dataVolFlow1.get_rs_split()[indexDictForSteps[correspondenceForStepsDict[stepStr]]])), assume_sorted = False) 
		interpol_flow_s2 = interpolate.interp1d(dataTemp2.get_rs_split()[indexDictForSteps[correspondenceForStepsDict[stepStr]]], dataVolFlow2.get_rs_split()[indexDictForSteps[correspondenceForStepsDict[stepStr]]], kind = 'linear', bounds_error = False, fill_value = (min(dataVolFlow2.get_rs_split()[indexDictForSteps[correspondenceForStepsDict[stepStr]]]), max(dataVolFlow2.get_rs_split()[indexDictForSteps[correspondenceForStepsDict[stepStr]]])), assume_sorted = False)
		
		segmentsAdded_Temp1, segmentsAdded_Temp2, segmentsAdded_VolFlow1, segmentsAdded_VolFlow2, segmentsAdded_OutputForce, times = [], [], [], [], [], []
		for seg in executionFlags_VolflowVSForce_actuators[stepStr]:
			newTime = createSegmentsOf_rs_FromVariableClass(dataTemp1, seg, indexDictForSteps[stepStr])[1]
			times += newTime

			segmentsAdded_Temp1 += createSegmentsOf_rs_FromVariableClass(dataTemp1, seg, indexDictForSteps[stepStr])[0]
			segmentsAdded_Temp2 += createSegmentsOf_rs_FromVariableClass(dataTemp2, seg, indexDictForSteps[stepStr])[0]
			segmentsAdded_VolFlow1 += createSegmentsOf_rs_FromVariableClass(dataVolFlow1, seg, indexDictForSteps[stepStr])[0]
			segmentsAdded_VolFlow2 += createSegmentsOf_rs_FromVariableClass(dataVolFlow2, seg, indexDictForSteps[stepStr])[0]
			segmentsAdded_OutputForce += createSegmentsOf_rs_FromVariableClass(dataOutputForce, seg, indexDictForSteps[stepStr])[0]

		# Correct points outside the interpolation range
		# Get interpol functions
		offset_flow_s1_vector = interpol_flow_s1(segmentsAdded_Temp1)
		offset_flow_s2_vector = interpol_flow_s2(segmentsAdded_Temp2)

		dataOutputForceToPlot = segmentsAdded_OutputForce
		dataVolFlowToPlot1 = [r - p for r,p in  zip(segmentsAdded_VolFlow1, offset_flow_s1_vector)]
		dataVolFlowToPlot2 = [r - p for r,p in  zip(segmentsAdded_VolFlow2, offset_flow_s2_vector)]

		axs[0].plot( dataOutputForceToPlot, dataVolFlowToPlot1, linestyle = '', marker = markerDict[stepStr], c = colorsDict[stepStr], label = labelsDict[stepStr], **plotSettings['line'])
		axs[1].plot( dataOutputForceToPlot, dataVolFlowToPlot2, linestyle = '', marker = markerDict[stepStr], c = colorsDict[stepStr], label = labelsDict[stepStr], **plotSettings['line'])

		# Save results
		results[stepStr] = {'force' : dataOutputForceToPlot, 'flow' : [dataVolFlowToPlot1, dataVolFlowToPlot2]}

	# Axis labels
	axs[0].set_ylabel(inputDataClass.get_variablesInfoDict()[dataVolFlow1.get_mag()+'__'+dataVolFlow1.get_description()]['y-label'], **plotSettings['axes_y'])
	axs[0].set_title(dataVolFlow1.get_description(), **plotSettings['ax_title'])
	
	axs[1].set_ylabel(inputDataClass.get_variablesInfoDict()[dataVolFlow2.get_mag()+'__'+dataVolFlow2.get_description()]['y-label'], **plotSettings['axes_y'])
	axs[1].set_title(dataVolFlow2.get_description(), **plotSettings['ax_title'])

	axs[-1].set_xlabel(inputDataClass.get_variablesInfoDict()[dataOutputForce.get_mag()+'__'+dataOutputForce.get_description()]['y-label'], **plotSettings['axes_x'])

	for ax in axs:
		ax.legend(**plotSettings['legend'])
		usualSettingsAX(ax, plotSettings)
	
	# Regression
	fig, axs = plt.subplots(2, 1, sharex='col', sharey='col')
	fig.set_size_inches(16, 10, forward=True)
	fig.suptitle('Regression results', **plotSettings['figure_title'])

	for flowID in range(2):

		print('\n--> Regression results for system '+str(1+flowID))
		
		rightForce, leftForce, rightFlow, leftFlow = [], [], [], []
		for stepStr in ('3-SN002-1.3', '3-Step-1.3'):

			# 100 bar data
			force_vector = results[stepStr]['force']
			flow_vector = results[stepStr]['flow'][flowID]

			for force,flow in zip(force_vector, flow_vector):

				if force > 0:
					rightForce +=  [force]
					rightFlow += [flow]
				else:
					leftForce +=  [force]
					leftFlow += [flow]

		axs[flowID].plot( leftForce, leftFlow, linestyle = '', marker = 'o', c = 'b', label = 'left', **plotSettings['line'])
		axs[flowID].plot( rightForce, rightFlow, linestyle = '', marker = 'o', c = 'k', label = 'right', **plotSettings['line'])
		for degreeRangeCurrent in range(5):
			degree = 1+degreeRangeCurrent # 1, 2, 3, 4
			p_right = np.polyfit([t/1000.0 for t in rightForce], rightFlow, degree)
			regre_right = np.poly1d(p_right)
			p_left = np.polyfit([t/1000.0 for t in leftForce], leftFlow, degree)
			regre_left = np.poly1d(p_left)

			# Regression results
			print('-> Regression results with '+str(degree)+' order curve (right):')
			print(','.join([str(round(o, 4)) for o in p_right]) + ' - R='+str(rsquared(rightForce, regre_right([t/1000.0 for t in rightForce]))))
			print('-> Regression results with '+str(degree)+' order curve (left):')
			print(','.join([str(round(o, 4)) for o in p_left]) + ' - R='+str(rsquared(leftForce, regre_left([t/1000.0 for t in leftForce]))))

			# Regression results plotting
			axs[flowID].plot( leftForce, regre_left([t/1000.0 for t in leftForce]), linestyle = '', marker = '+', c = plotSettings['colors'][degreeRangeCurrent], label = str(degree)+' ord. regression left', **plotSettings['line'])
			axs[flowID].plot( rightForce, regre_right([t/1000.0 for t in rightForce]), linestyle = '', marker = '+', c = plotSettings['colors'][degreeRangeCurrent], label = str(degree)+' ord. regression right', **plotSettings['line'])

	# Axis labels
	axs[0].set_ylabel(inputDataClass.get_variablesInfoDict()[dataVolFlow1.get_mag()+'__'+dataVolFlow1.get_description()]['y-label'], **plotSettings['axes_y'])
	axs[1].set_ylabel(inputDataClass.get_variablesInfoDict()[dataVolFlow2.get_mag()+'__'+dataVolFlow2.get_description()]['y-label'], **plotSettings['axes_y'])

	axs[-1].set_xlabel(inputDataClass.get_variablesInfoDict()[dataOutputForce.get_mag()+'__'+dataOutputForce.get_description()]['y-label'], **plotSettings['axes_x'])

	i = 0
	for ax in axs:
		ax.set_title(titlesDict[i], **plotSettings['ax_title'])
		ax.legend(**plotSettings['legend'])
		# usualSettingsAX(ax, plotSettings)
		usualSettingsAXNoDoubleAxis(ax, plotSettings)
		i+=1

def internalLeakageVSTempVSPress_withP2ref(dataClasses, inputDataClass, plotSettings, CMDoptionsDict):
	
	dataTemp1 = [temp for temp in dataClasses if temp.get_description() == 'Temp1'][0]
	dataTemp2 = [temp for temp in dataClasses if temp.get_description() == 'Temp2'][0]
	dataVolFlow1 = [temp for temp in dataClasses if temp.get_description() == 'VolFlow1'][0]
	dataVolFlow2 = [temp for temp in dataClasses if temp.get_description() == 'VolFlow2'][0]			

	#Steps to consider
	stepStrs = dataTemp1.get_stepID()
	indexDictForSteps = {}
	for id_curr in stepStrs:
		indexDictForSteps[id_curr] = stepStrs.index(id_curr)

	linestyleDict = {'6-Step-1.6':'',	'4-SN002-1.6':'',	'8-SN002-2.4':'',	'7-Step-2.4':'', '3-Step-1.3' : '', '3-SN002-1.3':''}
	markerDict = {'6-Step-1.6':'o',	'4-SN002-1.6':'o',	'8-SN002-2.4':'o',	'7-Step-2.4':'o', '3-Step-1.3' : 'o', '3-SN002-1.3':'o'}
	colorsDict = {'6-Step-1.6':plotSettings['colors'][0],	'7-Step-2.4':plotSettings['colors'][1],	'8-SN002-2.4':plotSettings['colors'][2], '3-Step-1.3' : plotSettings['colors'][3], '3-SN002-1.3':plotSettings['colors'][4], '4-SN002-1.6':plotSettings['colors'][5]}
	labelsDict = {'6-Step-1.6':'231.5 bar - Step 1.6 Proof Press.',	'4-SN002-1.6':'150 bar - Step 1.6 Proof Press.', '8-SN002-2.4':'100 bar - Step 2.4 Internal leakage', 
					'7-Step-2.4':'150 bar - Step 2.4 Internal leakage', '3-Step-1.3' : '150 bar / 4.5KN - Step 1.3 Strength output (High Temp.)', 
					'3-SN002-1.3':'100 bar / 3.2KN - Step 1.3 Strength output (High Temp.)'}
	titlesDict = {0 : 'System 1', 1: 'System 2'}

	# Segments from test step 1.3
	segments13_6_16 = [ [625, 750]
						, [751, 910]
						]
	segments13_4_16 = [  [0.0, 0.0]
						, [0.0, 0.0]
						]
	segments13_8_24 = [  [100, 2500]
						, [2501, 2800]
						]
	segments13_7_24 = [  [100, 2500]
						, [2501, 2800]
						]
	segments13_3_13 = [  [100, 2000]
						, [2260, 2300]
						]
	segments13_002_3_13 = [  [100, 1500]
						, [1501, 3100]
						]
	executionFlags_VolflowVSTemp_actuators = {	'6-Step-1.6':segments13_6_16,'4-SN002-1.6':segments13_4_16,'8-SN002-2.4':segments13_8_24,'7-Step-2.4':segments13_7_24, '3-Step-1.3': segments13_3_13, '3-SN002-1.3':segments13_002_3_13,
												'segmentsFlag' : True, 'singleTempInterpolFlag' : False, 
												'colorsIDflags' : {'SN0012' : 0, 'SN002' : 1}}

	# Create segment for data
	# Figure initialization
	figure, axs = plt.subplots(2, 1, sharex='col', sharey='col')
	figure.set_size_inches(16, 10, forward=True)
	figure.suptitle('Internal leakage versus temperature', **plotSettings['figure_title'])
	for stepStr in stepStrs:
		
		segmentsAdded_Temp1, segmentsAdded_Temp2, segmentsAdded_VolFlow1, segmentsAdded_VolFlow2, times = [], [], [], [], []
		for seg in executionFlags_VolflowVSTemp_actuators[stepStr]:
			newTime = createSegmentsOf_rs_FromVariableClass(dataTemp1, seg, indexDictForSteps[stepStr])[1]
			times += newTime

			segmentsAdded_Temp1 += createSegmentsOf_rs_FromVariableClass(dataTemp1, seg, indexDictForSteps[stepStr])[0]
			segmentsAdded_Temp2 += createSegmentsOf_rs_FromVariableClass(dataTemp2, seg, indexDictForSteps[stepStr])[0]
			segmentsAdded_VolFlow1 += createSegmentsOf_rs_FromVariableClass(dataVolFlow1, seg, indexDictForSteps[stepStr])[0]
			segmentsAdded_VolFlow2 += createSegmentsOf_rs_FromVariableClass(dataVolFlow2, seg, indexDictForSteps[stepStr])[0]

		axs[0].plot( dataTemp1.get_rs_split()[indexDictForSteps[stepStr]], dataVolFlow1.get_rs_split()[indexDictForSteps[stepStr]], linestyle = linestyleDict[stepStr], marker = markerDict[stepStr], c = colorsDict[stepStr], label = labelsDict[stepStr], **plotSettings['line'])
		axs[1].plot( dataTemp2.get_rs_split()[indexDictForSteps[stepStr]], dataVolFlow2.get_rs_split()[indexDictForSteps[stepStr]], linestyle = linestyleDict[stepStr], marker = markerDict[stepStr], c = colorsDict[stepStr], label = labelsDict[stepStr], **plotSettings['line'])

	i = 0
	limsDictP2 = {0 : 85.11, 1 : 87.64}
	annotateDictP2 = {0 : '$(T_1)_{\mathrm{P2,max}}$', 1 : '$(T_2)_{\mathrm{P2,max}}$'}
	for ax in axs:


		# Plot limit lines internal leakage
		xOldLim = ax.get_xlim()
		yOldLim = ax.get_ylim()
		ax.plot( xOldLim, 2*[2.3], linestyle = '--', marker = '', c = 'r', scalex = False, scaley = False, **plotSettings['line'])
		ax.annotate('$Q_{\mathrm{pump,max}}/4$', [0.0, 2.3], xytext = [1, 8], fontsize=12, textcoords = 'offset pixels')

		ax.plot(2*[limsDictP2[i]], ax.get_ylim(),linestyle = '--', marker = '', c = plotSettings['colors'][1], scaley = False, scalex = False, **plotSettings['line'])
		ax.annotate(annotateDictP2[i], [limsDictP2[i], 0.0], xytext = [1, 8], fontsize=12, textcoords = 'offset pixels')
		ax.set_xlim([0.0, xOldLim[1]])
		ax.set_ylim([0.0, yOldLim[1]])
		
		ax.set_ylabel(inputDataClass.get_variablesInfoDict()[dataVolFlow1.get_mag()+'__'+dataVolFlow1.get_description()]['y-label'], **plotSettings['axes_y'])
		ax.set_title(titlesDict[i], **plotSettings['ax_title'])
		ax.legend(**plotSettings['legend'])
		usualSettingsAX(ax, plotSettings)
		
		i+=1
	axs[-1].set_xlabel('Temp. [$^\circ$C]', **plotSettings['axes_x'])

def internalLeakageVSTemp_segments(dataClasses, inputDataClass, plotSettings, CMDoptionsDict):

	dataTemp1 = [temp for temp in dataClasses if temp.get_description() == 'Temp1'][0]
	dataTemp2 = [temp for temp in dataClasses if temp.get_description() == 'Temp2'][0]
	dataVolFlow1 = [temp for temp in dataClasses if temp.get_description() == 'VolFlow1'][0]
	dataVolFlow2 = [temp for temp in dataClasses if temp.get_description() == 'VolFlow2'][0]			

	#Steps to consider
	stepStrs = dataTemp1.get_stepID()
	indexDictForSteps = {}
	for id_curr in stepStrs:
		indexDictForSteps[id_curr] = stepStrs.index(id_curr)

	linestyleDict = {'3-SN002-1.3':'',	'10-SN0012-1.3':'',	'8-SN002-2.4':'', '13-SN0012-2.4' : ''}
	markerDict = {'3-SN002-1.3':'o',	'10-SN0012-1.3':'o',	'8-SN002-2.4':'x', '13-SN0012-2.4' : 'x'}
	colorsDict = {'3-SN002-1.3':plotSettings['colors'][0],	'10-SN0012-1.3':plotSettings['colors'][1],	'8-SN002-2.4':plotSettings['colors'][0], '13-SN0012-2.4' : plotSettings['colors'][1]}
	labelsDict = {  '3-SN002-1.3':'SN002 - Step 1.3 / 3.1KN', '10-SN0012-1.3':'SN0012 - Step 1.3 / 3KN',
					'8-SN002-2.4':'SN002 - Step 2.4', '13-SN0012-2.4':'SN0012 - Step 2.4'}
	titlesDict = {0 : 'System 1', 1: 'System 2'}

	# Segments from test step 1.3
	executionFlags_VolflowVSTemp_actuators = {	'segmentsFlag' : True, 'singleTempInterpolFlag' : False, 
												'colorsIDflags' : {'SN0012' : 0, 'SN002' : 1}}
	executionFlags_VolflowVSTemp_actuators['3-SN002-1.3'] = [ [100, 1000]
															, [1001, 3000]
															]

	executionFlags_VolflowVSTemp_actuators['10-SN0012-1.3'] = [ [10, 100]
															, [200, 650]
															, [775, 875]
															]
	executionFlags_VolflowVSTemp_actuators['8-SN002-2.4'] = [ [100, 1000]
															, [1001, 4400]
															]
	executionFlags_VolflowVSTemp_actuators['13-SN0012-2.4'] = [ [100, 1000]
															, [1001, 3000]
															]
	# Create segment for data
	# Figure initialization
	figure, axs = plt.subplots(2, 1, sharex='col', sharey='col')
	figure.set_size_inches(16, 10, forward=True)
	figure.suptitle('Internal leakage versus temperature', **plotSettings['figure_title'])
	for stepStr in stepStrs:
		
		segmentsAdded_Temp1, segmentsAdded_Temp2, segmentsAdded_VolFlow1, segmentsAdded_VolFlow2, times = [], [], [], [], []
		for seg in executionFlags_VolflowVSTemp_actuators[stepStr]:
			newTime = createSegmentsOf_rs_FromVariableClass(dataTemp1, seg, indexDictForSteps[stepStr])[1]
			times += newTime

			segmentsAdded_Temp1 += createSegmentsOf_rs_FromVariableClass(dataTemp1, seg, indexDictForSteps[stepStr])[0]
			segmentsAdded_Temp2 += createSegmentsOf_rs_FromVariableClass(dataTemp2, seg, indexDictForSteps[stepStr])[0]
			segmentsAdded_VolFlow1 += createSegmentsOf_rs_FromVariableClass(dataVolFlow1, seg, indexDictForSteps[stepStr])[0]
			segmentsAdded_VolFlow2 += createSegmentsOf_rs_FromVariableClass(dataVolFlow2, seg, indexDictForSteps[stepStr])[0]

		axs[0].plot( dataTemp1.get_rs_split()[indexDictForSteps[stepStr]], dataVolFlow1.get_rs_split()[indexDictForSteps[stepStr]], linestyle = linestyleDict[stepStr], marker = markerDict[stepStr], c = colorsDict[stepStr], label = labelsDict[stepStr], **plotSettings['line'])
		axs[1].plot( dataTemp2.get_rs_split()[indexDictForSteps[stepStr]], dataVolFlow2.get_rs_split()[indexDictForSteps[stepStr]], linestyle = linestyleDict[stepStr], marker = markerDict[stepStr], c = colorsDict[stepStr], label = labelsDict[stepStr], **plotSettings['line'])

	i = 0
	for ax in axs:
		
		ax.set_ylabel(inputDataClass.get_variablesInfoDict()[mag+'__'+dataVolFlow1.get_description()]['y-label'], **plotSettings['axes_y'])
		ax.set_title(titlesDict[i], **plotSettings['ax_title'])
		ax.legend(**plotSettings['legend'])
		usualSettingsAX(ax, plotSettings)
		
		i+=1
	axs[-1].set_xlabel('Temp. [$^\circ$C]', **plotSettings['axes_x'])

def internalLeakageDueToPistonDemand_P2flights(dataClasses, inputDataClass, plotSettings, CMDoptionsDict):
	
	dictCalc = {'Q_COL' : ['CNT_DST_BST_COL', 150],
				'Q_LNG' : ['CNT_DST_BST_LNG', 77.75],
				'Q_LAT' : ['CNT_DST_BST_LAT', 77.75]}

	exampleDataClass = [temp for temp in dataClasses if temp.get_description() == 'CNT_DST_BST_COL'][0]
	newCalc = len(exampleDataClass.get_rs())* [0.0]
	
	for key in dictCalc.keys():
		dataAdditional = dataFromGaugesSingleMagnitudeClass(key, 'rs', exampleDataClass.get_testFactor(), exampleDataClass.get_orderDeriv())
		dataAdditional.addDataManual3(dataClasses, dictCalc[key][0], dictCalc[key][1])

		temp = [p+o for p,o in zip(dataAdditional.get_rs(), newCalc)]
		newCalc = temp

		dataClasses += (dataAdditional, )

	dataAdditionalPed = dataFromGaugesSingleMagnitudeClass('Q_PED', 'rs', exampleDataClass.get_testFactor(), exampleDataClass.get_orderDeriv())
	dataAdditionalPed.addDataManual5(dataClasses)
	dataClasses += (dataAdditionalPed, )

	newCalc = [o+p for o,p in zip(temp, dataAdditionalPed.get_rs())]

	dataAdditional = dataFromGaugesSingleMagnitudeClass('Total_Q', 'rs', exampleDataClass.get_testFactor(), exampleDataClass.get_orderDeriv())
	dataAdditional.addDataManual4(newCalc, exampleDataClass)
	dataClasses += (dataAdditional, )

	dataAdditional.plotResampled(plotSettings, CMDoptionsDict, dataAdditional.get_mag(), (True, dataClasses, [i for i in dictCalc.keys()]+['Q_PED','Total_Q']), inputDataClass)

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

			if var == 'temp' and masterVar == 'dst':
				timeDict[var] = time_temp[first_index - 20 : second_index+20]
				dataDict[var] = dataClassesDict[var].get_rs()[first_index - 20 : second_index+20]
			elif var in ('dst_di', 'frc_rs') and masterVar == 'temp':
				timeDict[var] = time_temp[first_index - 20 : second_index+20]
				dataDict[var] = dataClassesDict[var].get_rs()[first_index - 20 : second_index+20]
			else:
				timeDict[var] = time_temp[first_index : second_index+1]
				dataDict[var] = dataClassesDict[var].get_rs()[first_index : second_index+1]

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
								'1' : [5.50915027507144e-06,-0.0008451503498918064,0.06232563400813227,-0.8553274292912779], #System 1 at 150bar, 3er orden
								'2' : [7.628554597814203e-06,-0.0012526105728704574,0.08630418531452934,-1.3223881902456438] #System 2 at 150bar, 3er orden
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


	masterVar = 'dst' #'temp', 'dst'

	rangeForHighFreqSignal_original = 20

	segmentsOfTime2 = [
					 [3140, 3160],
					 [4430, 4470]
					 ]

	segmentsOfTime3 = [
					 [2500, 3500],
					 [4300, 4500]
					 ]
	segmentsOfTime = [
					 [500, 3600],
					 [3600, 6300]
					 ]#long
	segmentsOfTime_long = [
					 [2700, 3000],
					 [4300, 4700],
					 [5700, 5900]
					 ] #fit
	statusMax = 105 #%

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
		print('\n\n--> Computing segment: t1 = '+str(t1)+' s, t2 = '+str(t2)+' s')

		q_TP_dofsDict, q_F_dofsDict, q_v_dofsDict, q_total_dofsDict, time_dofsDict, q_total_tempRange_dofsDict = {}, {}, {}, {}, {}, {}
		for dof in dofs:

			print('---> Computing volume flow for flight test data for '+dof)

			q_TP_sysList, q_F_sysList, q_v_sysList, q_total_sysList, time_sysList, q_total_tempRange_sysList = [[], []], [[], []], [[], []], [[], []], [[], []], [[], []]
			for sysID in sysIDsDict.keys():

				print('----> System '+sysID)

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
							q_TP_range += [regre_TP(t)]

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
					q_F = regre_F(force / 1000.0) if regre_F(force / 1000.0) > 0.0 else 0.0 #Correction necessary when the force is low, the regression fails

					# pdb.set_trace()

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
					status = round(((currentTime - time_vector_master[0])/(time_vector_master[-1] - time_vector_master[0]))*100, 2)
					sys.stdout.write('-----> Status: '+ str(status) +'% of current segment completed \r')
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
		resultsPerSegment += [temporal_segmentDict]

	# Results
	print('\n* Plotting results per system and dof')
	for dof in dofs:
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
				handlesList += [plt.Line2D([],[], color=plotSettings['colors'][colorsDict_var[var]], marker=markerDict_var[var], linestyle='', label=labelsDict_var[var])]
				for segment_index in range(len(segmentsOfTime)):
					axsDict[dof][3, sysIDsDict[sysID]].plot( resultsPerSegment[segment_index]['time'][dof][sysIDsDict[sysID]], resultsPerSegment[segment_index][var][dof][sysIDsDict[sysID]], linestyle = '', marker = markerDict_var[var], c = plotSettings['colors'][colorsDict_var[var]], label = labelsDict_var[var], **plotSettings['line'])
			
			axsDict[dof][3, sysIDsDict[sysID]].set_ylabel('Vol. flow [L/min]', **plotSettings['axes_y'])
			axsDict[dof][3, sysIDsDict[sysID]].legend(handles = handlesList, **plotSettings['legend'])
			usualSettingsAXNoDoubleAxis(axsDict[dof][3, sysIDsDict[sysID]], plotSettings)

			# Volumetric flow for temp ranges
			if tempRangeFlag:
				handlesList = []
				for temp_index in range(len(tempRange)):
					# Results per segment
					# resultsPerSegment[var][dof][sysIDsDict[sysID]]
					handlesList += [plt.Line2D([],[], color=plotSettings['colors'][temp_index], marker='o', linestyle='', label=str(tempRange[temp_index])+'$^\circ$C')]
					for segment_index in range(len(segmentsOfTime)):
						y_to_plot = [resultsPerSegment[segment_index]['q_total_tempRange'][dof][sysIDsDict[sysID]][i][temp_index] for i in range(len(resultsPerSegment[segment_index]['time'][dof][sysIDsDict[sysID]]))]
						axsDict[dof][4, sysIDsDict[sysID]].plot( resultsPerSegment[segment_index]['time'][dof][sysIDsDict[sysID]], y_to_plot, linestyle = '', marker = 'o', c = plotSettings['colors'][temp_index], label = '$q_{total}$/'+str(tempRange[temp_index])+'$^\circ$C', **plotSettings['line'])
				
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
	print('* Plotting results per flight')
	if tempRangeFlag:
		figure, axs = plt.subplots(5, 2, sharex='col')
	else:
		figure, axs = plt.subplots(4, 2, sharex='col')
	figure.set_size_inches(16, 10, forward=True)

	for sysID in sysIDsDict.keys():
		
		# Temp
		axs[0, sysIDsDict[sysID]].plot( [t/data_tempDict[sysID].get_freqData()[0] for t in data_tempDict[sysID].get_timeRs()], data_tempDict[sysID].get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][0], label = 'Temp SYS'+sysID, **plotSettings['line'])
		axs[0, sysIDsDict[sysID]].set_ylabel(inputDataClass.get_variablesInfoDict()[data_tempDict[sysID].get_mag()+'__'+data_tempDict[sysID].get_description()]['y-label'], **plotSettings['axes_y'])
		axs[0, sysIDsDict[sysID]].legend(**plotSettings['legend'])
		usualSettingsAXNoDoubleAxis(axs[0, sysIDsDict[sysID]], plotSettings)
	
		# Force and velocity
		for dof in dofs:
			# Force
			axs[1, sysIDsDict[sysID]].plot( [t/data_frc_rs_Dict[dof].get_freqData()[0] for t in data_frc_rs_Dict[dof].get_timeRs()], data_frc_rs_Dict[dof].get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][colorsDict_dof[dof]], label = 'Force-'+dof, **plotSettings['line'])

			# Velocity
			axs[2, sysIDsDict[sysID]].plot( [t/data_dst_di_Dict[dof].get_freqData()[0] for t in data_dst_di_Dict[dof].get_timeRs()], data_dst_di_Dict[dof].get_rs(), linestyle = '-', marker = '', c = plotSettings['colors'][colorsDict_dof[dof]], label = 'Piston '+ dof +' vel.', **plotSettings['line'])
		
		axs[1, sysIDsDict[sysID]].legend(**plotSettings['legend'])
		axs[2, sysIDsDict[sysID]].legend(**plotSettings['legend'])
		axs[1, sysIDsDict[sysID]].set_ylabel(inputDataClass.get_variablesInfoDict()[data_frc_rs_Dict[dof].get_mag()+'__'+data_frc_rs_Dict[dof].get_description()]['y-label'], **plotSettings['axes_y'])
		usualSettingsAXNoDoubleAxis(axs[1, sysIDsDict[sysID]], plotSettings)
		axs[2, sysIDsDict[sysID]].set_ylabel(inputDataClass.get_variablesInfoDict()[data_dst_di_Dict[dof].get_mag()+'__'+data_dst_di_Dict[dof].get_description()]['y-label'], **plotSettings['axes_y'])
		usualSettingsAXNoDoubleAxis(axs[2, sysIDsDict[sysID]], plotSettings)

		handlesList = []
		for dof in dofs:
			handlesList += [plt.Line2D([],[], color=plotSettings['colors'][colorsDict_dof[dof]], marker='o', linestyle='', label='$q_{'+dof+'}$')]
			for segment_index in range(len(segmentsOfTime)):
				axs[3, sysIDsDict[sysID]].plot( resultsPerSegment[segment_index]['time'][dof][sysIDsDict[sysID]], resultsPerSegment[segment_index]['q_total'][dof][sysIDsDict[sysID]], linestyle = '', marker = markerDict_dof[dof], c = plotSettings['colors'][colorsDict_dof[dof]], label = '$q_{'+dof+'}$', **plotSettings['line'])
		
		# Plot total per system
		handlesList += [plt.Line2D([],[], color=plotSettings['colors'][3], marker='o', linestyle='', label='$q_{all}$')]
		for segment_index in range(len(segmentsOfTime)):
			y_to_plot = []
			for timeCurrent_index in range(len(resultsPerSegment[segment_index]['time'][dof][sysIDsDict[sysID]])):
				q_current_sum = 0.0
				for dof in dofs:
					q_current_sum += resultsPerSegment[segment_index]['q_total'][dof][sysIDsDict[sysID]][timeCurrent_index]
				y_to_plot += [q_current_sum]
			axs[3, sysIDsDict[sysID]].plot( resultsPerSegment[segment_index]['time'][dof][sysIDsDict[sysID]], y_to_plot, linestyle = '', marker = 'o', c = plotSettings['colors'][3], label = '$q_{all}$', **plotSettings['line'])
		
		# Reference line max Q
		# Plot limit lines internal leakage
		xOldLim = axs[3, sysIDsDict[sysID]].get_xlim()
		yOldLim = axs[3, sysIDsDict[sysID]].get_ylim()
		axs[3, sysIDsDict[sysID]].plot( xOldLim, 2*[9.2*(3.0/4.0)], linestyle = '--', marker = '', c = 'r', scalex = False, scaley = False, **plotSettings['line'])

		axs[3, sysIDsDict[sysID]].set_ylabel('Vol. flow [L/min]', **plotSettings['axes_y'])
		axs[3, sysIDsDict[sysID]].legend(handles = handlesList, **plotSettings['legend'])
		usualSettingsAXNoDoubleAxis(axs[3, sysIDsDict[sysID]], plotSettings)

		# Volumetric flow recorded
		if tempRangeFlag:
			handlesList = []
			for temp_index in range(len(tempRange)):
				handlesList += [plt.Line2D([],[], color=plotSettings['colors'][temp_index], marker='o', linestyle='', label='$q_{all}$/'+str(tempRange[temp_index])+'$^\circ$C')]
				for segment_index in range(len(segmentsOfTime)):
					y_to_plot = []
					for timeCurrent_index in range(len(resultsPerSegment[segment_index]['time'][dof][sysIDsDict[sysID]])):
						q_current_sum = 0.0
						for dof in dofs:
							q_current_sum += resultsPerSegment[segment_index]['q_total_tempRange'][dof][sysIDsDict[sysID]][timeCurrent_index][temp_index]
						y_to_plot += [q_current_sum]
					axs[4, sysIDsDict[sysID]].plot( resultsPerSegment[segment_index]['time'][dof][sysIDsDict[sysID]], y_to_plot, linestyle = '', marker = 'o', c = plotSettings['colors'][temp_index], label = '$q_{all}$/'+str(tempRange[temp_index])+'$^\circ$C', **plotSettings['line'])
			
			# Reference line max Q
			# Plot limit lines internal leakage
			xOldLim = axs[4, sysIDsDict[sysID]].get_xlim()
			yOldLim = axs[4, sysIDsDict[sysID]].get_ylim()
			axs[4, sysIDsDict[sysID]].plot( xOldLim, 2*[9.2*(3.0/4.0)], linestyle = '--', marker = '', c = 'r', scalex = False, scaley = False, **plotSettings['line'])

			axs[4, sysIDsDict[sysID]].set_ylabel('Vol. flow [L/min]', **plotSettings['axes_y'])
			axs[4, sysIDsDict[sysID]].legend(handles = handlesList, **plotSettings['legend'])
			usualSettingsAXNoDoubleAxis(axs[4, sysIDsDict[sysID]], plotSettings)
		
		axs[0, sysIDsDict[sysID]].set_title('System '+sysID, **plotSettings['ax_title'])

	axs[-1, 0].set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])
	axs[-1, 1].set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])

	if CMDoptionsDict['saveFigure']:
		figure.suptitle(rangeIDstring, **plotSettings['figure_title'])
		figure.savefig('hyd_flux'+'__'+rangeIDstring+'.png', dpi = plotSettings['figure_settings']['dpi'])

def calculateSegmentsForHYDtestFT04(dataClasses, plotSettings, CMDoptionsDict):
	
	#Vector of steps
	dataExample = [temp for temp in dataClasses if temp.get_description() == 'HYD_PRS_1'][0]
	
	# Get index for the step
	stepStrs = dataExample.get_stepID()
	indexDictForSteps = {}
	for id_curr in stepStrs:
		indexDictForSteps[id_curr] = stepStrs.index(id_curr)

	# For each step

	# variables 
	# [ax loc, colorline, style, marker]
	varDict = {
				  'rs__HYD_TMP_TANK_1' : [0, plotSettings['colors'][0], plotSettings['linestyles'][0], '']
				, 'rs__HYD_TMP_TANK_2' : [0, plotSettings['colors'][1], plotSettings['linestyles'][0], '']
				, 'rs__HYD_PRS_1' : [1, plotSettings['colors'][0], plotSettings['linestyles'][0], '']
				, 'rs__HYD_PRS_2' : [1, plotSettings['colors'][1], plotSettings['linestyles'][0], '']
				, 'rs__IND_PRS_1' : [2, plotSettings['colors'][0], plotSettings['linestyles'][0], '']
				, 'rs__IND_PRS_2' : [2, plotSettings['colors'][1], plotSettings['linestyles'][0], '']
				, 'rs__CNT_DST_COL' : [3, plotSettings['colors'][0], plotSettings['linestyles'][0], '']
				, 'rs__CNT_DST_LAT' : [3, plotSettings['colors'][1], plotSettings['linestyles'][0], '']
				, 'rs__CNT_DST_LNG' : [3, plotSettings['colors'][2], plotSettings['linestyles'][0], '']
				, 'di__CNT_DST_BST_COL' : [4, plotSettings['colors'][0], plotSettings['linestyles'][0], '']
				, 'di__CNT_DST_BST_LAT' : [4, plotSettings['colors'][1], plotSettings['linestyles'][0], '']
				, 'di__CNT_DST_BST_LNG' : [4, plotSettings['colors'][2], plotSettings['linestyles'][0], '']
			}
	additionDict = {'3-actuators' : [4, plotSettings['colors'][3], plotSettings['linestyles'][0], '']}

	segmentsDict = {  
					  '8'  : [810, 1170]
					, '40' : [3925, 3966]
					, '42' : [4075, 4135]
					, '10' : [1128, 1310]
					, '11' : [1310, 1450]
					, '16' : [1465, 1840]
					, '18' : [1465, 2300]
					, '19' : [2300, 2430]
					, '24' : [2570, 2690]
					, '25' : [2570, 2690]
					, '24' : [2570, 2690]
					, '25' : [2688, 2830]
					, '26' : [2830, 2903]
					, '29' : [3006, 3053]
					, '30' : [3060, 3120]
					, '31' : [3140, 3188]
					, '32' : [3230, 3255]
					, '32-add': [3265, 3280]
					, '33' : [3310, 3347]
					, '34' : [3370, 3405]
					, '35' : [3450, 3490]
					, '36' : [3505, 3550]
					, '37' : [3563, 3607]
					, '38' : [3810, 3856]
					, '39' : [3860, 3915]
					, 'All_steps' : [810, 3966]
					}

	# segmentsDict = {'29' : [3006, 3053]}
	stepStr = '13-FT04'
	flagAdjustAxisPilot = True
	for segKey in segmentsDict.keys():

		figure, axs = plt.subplots(5, 1, sharex='col')
		figure.set_size_inches(16, 10, forward=True)
		figure.suptitle('Step '+segKey, **plotSettings['figure_title'])

		maxValue, UpLimit, DoLimit = 0, 0, 0 # for plot 3
		for var in varDict.keys():

			dataTemp = [temp for temp in dataClasses if temp.get_mag()+'__'+temp.get_description() == var][0]

			dataSplitForSegment, timeSplitForSegment = createSegmentsOf_rs_FromVariableClass(dataTemp, segmentsDict[segKey], indexDictForSteps[stepStr])

			axs[varDict[var][0]].plot( timeSplitForSegment, dataSplitForSegment, linestyle = varDict[var][2], marker = varDict[var][3], c = varDict[var][1], label = var, **plotSettings['line'])

			if varDict[var][0] == 3 and flagAdjustAxisPilot:
				# tempVal = max(abs(max(dataSplitForSegment)), abs(min(dataSplitForSegment)))
				a = max(dataSplitForSegment)
				b = min(dataSplitForSegment)
				# if b<0:
				# 	b = 0
				c = (a+b)/2
				z = max(abs(b-c), abs(c-a))
				# pdb.set_trace()
				if z > maxValue:
					maxValue = z
					UpLimit = c+z
					DoLimit = c-z

		if segKey in ('31','34','37','40','42'):

			dataCOL = [temp for temp in dataClasses if temp.get_mag()+'__'+temp.get_description() == 'di__CNT_DST_BST_COL'][0]
			dataLNG = [temp for temp in dataClasses if temp.get_mag()+'__'+temp.get_description() == 'di__CNT_DST_BST_LNG'][0]
			dataLAT = [temp for temp in dataClasses if temp.get_mag()+'__'+temp.get_description() == 'di__CNT_DST_BST_LAT'][0]

			dataSplitForSegment_COL, timeSplitForSegment_COL = createSegmentsOf_rs_FromVariableClass(dataCOL, segmentsDict[segKey], indexDictForSteps[stepStr])
			dataSplitForSegment_LNG, timeSplitForSegment_LNG = createSegmentsOf_rs_FromVariableClass(dataLNG, segmentsDict[segKey], indexDictForSteps[stepStr])
			dataSplitForSegment_LAT, timeSplitForSegment_LAT = createSegmentsOf_rs_FromVariableClass(dataLAT, segmentsDict[segKey], indexDictForSteps[stepStr])

			newData = []
			i=0
			for point in dataSplitForSegment_COL:
				newData += [ abs(dataSplitForSegment_COL[i]) + abs(dataSplitForSegment_LNG[i]) + abs(dataSplitForSegment_LAT[i])]
				i+=1

			axs[varDict[var][0]].plot( timeSplitForSegment_COL, newData, linestyle = additionDict['3-actuators'][2], marker = additionDict['3-actuators'][3], c = additionDict['3-actuators'][1], label = '3-actuators', **plotSettings['line'])
		
		axs[0].set_title('HYD Temperature', **plotSettings['ax_title'])
		axs[1].set_title('HYD pressure', **plotSettings['ax_title'])
		axs[2].set_title('HYD PRES indications', **plotSettings['ax_title'])
		axs[3].set_title('Pilot inputs', **plotSettings['ax_title'])
		axs[4].set_title('Actuator piston speed', **plotSettings['ax_title'])

		axs[0].set_ylabel('Temp. [$^\circ$C]', **plotSettings['axes_y'])
		axs[1].set_ylabel('Press. [bar]', **plotSettings['axes_y'])
		# axs[2].set_ylabel('HYD PRES indications', **plotSettings['axes_y'])
		axs[3].set_ylabel('Increment [%]', **plotSettings['axes_y'])
		axs[4].set_ylabel('Speed [mm/s]', **plotSettings['axes_y'])

		axs[-1].set_xlabel('Time elapsed [Seconds]', **plotSettings['axes_x'])

		# Limits pilot input
		if flagAdjustAxisPilot:
			axs[3].set_ylim([DoLimit-(maxValue*0.2), UpLimit+(maxValue*0.2)])
			
		for ax in axs:
			ax.legend(**plotSettings['legend'])
			usualSettingsAX(ax, plotSettings)

		if CMDoptionsDict['saveFigure']:

			figure.savefig(os.path.join('L:\\TEMP\\AlejandroValverde\\DIADEM\\resulting_plots\\FT04\\', 'HYD_GR_STEP__'+segKey+'.png'), dpi = plotSettings['figure_settings']['dpi'])