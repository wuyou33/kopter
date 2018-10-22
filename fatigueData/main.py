import os
import sys
import pdb #pdb.set_trace()
import getopt
import shutil
from scipy import interpolate
import numpy as np #pdb.set_trace()

from moduleFunctions import *
from moduleAdditionalFunctions import *

# CMD input
# actuator:
# python main.py -f filesToLoad_actuator_outerBearing.txt -o -2.1,2.1 -s t
# 
# gauges:
# python main.py -f filesToLoad_gauges_enduranceActuatorNewBearing.txt -v DruckHP1,DruckHP2,DurchflussHP1,DurchflussHP2,ForcePistonEyeHP1,ForcePistonEyeHP2,InputForce,LaserPiston,LaserSteuerventilhebel,OutputForce,TemperaturHP1,TemperaturHP2 -m lp -o f -s t,t -r 1,2,3,4,5,6,7,8,9 -a t
# python main.py -f filesToLoad_gauges_TRbladeholder.txt -v BendingMoment,MyBlade,MyLoadcell,MzBlade,CF -m rs -o f -s t,t -a f -r 11,12,13,14,15
# python main.py -f filesToLoad_gauges_OC.txt -v Tension,Bending -m rs -o t -s t,t -a f -r 1,2,3,4,5,6

# Dicitionary of loading options
CMDoptionsDict = {}

#Get working directory
cwd = os.getcwd()
CMDoptionsDict['cwd'] = cwd

#Read postProc folder name from CMD
CMDoptionsDict = readCMDoptionsMainAbaqusParametric(sys.argv[1:], CMDoptionsDict)

#Write output data
if CMDoptionsDict['writeStepResultsToFileFlag']:
	CMDoptionsDict['stepsSummaryResultsFolder'] = os.path.join(CMDoptionsDict['cwd'],'stepsSummaryResults')
	if not os.path.isdir(CMDoptionsDict['stepsSummaryResultsFolder']):
		os.mkdir(CMDoptionsDict['stepsSummaryResultsFolder'])

# What to do?
gaugesFlag = CMDoptionsDict['dmsFlag']
actuatorFlag = CMDoptionsDict['actuatorFlag']
actuatorMesswerteFlag = CMDoptionsDict['actuatorMesswerte']

# Gauges data analysis
if gaugesFlag:
	print('\n'+'**** Running data analysis program for calibrated strain gauges measurements'+'\n')

	testFactor = 1.0 #HZ
	orderDeriv = 2	
	# Import settings
	plotSettings = importPlottingOptions()
	dataClasses = ()
	for magComplex in CMDoptionsDict['magnitudes']:

		# Mag operations
		mag = magComplex[:2]
		if magComplex[2:]:
			additionalMag = magComplex[2:]
		inputDataClass = loadFileAddressesAndData(CMDoptionsDict['fileNameOfFileToLoadFiles'], 'gauges')

		listOfFilesSortedInFolder = []
		for folderName in inputDataClass.getTupleFiles(): #For each folder with min, max or mean values
			listOfFilesInFolderMathingVar = []

			for fileName2 in os.listdir(folderName):
				if fileName2.endswith('.csv'): #Take only .csv files
					if magComplex[2:]:
						if fileName2.startswith(mag) and fileName2.split('.csv')[0].split('__')[-1] in CMDoptionsDict['rangeFileIDs'] and fileName2.split('__')[-2][:-2] == additionalMag:
							listOfFilesInFolderMathingVar += [fileName2]
					else:
						if fileName2.startswith(mag) and fileName2.split('.csv')[0].split('__')[-1] in CMDoptionsDict['rangeFileIDs']:
							listOfFilesInFolderMathingVar += [fileName2]

			listOfFilesSortedInFolder += sortFilesInFolderByLastNumberInName(listOfFilesInFolderMathingVar, folderName, CMDoptionsDict)

		# Create dataClasses
		listOfFilesMatchingMag = [t[1] for t in listOfFilesSortedInFolder]
		listOfMagVarPairs = [t.split('__')[0]+'__'+t.split('__')[1] for t in listOfFilesMatchingMag]
		for var in CMDoptionsDict['variables']:
			if mag+'__'+var in listOfMagVarPairs:
				dataVar = dataFromGaugesSingleMagnitudeClass(var, mag, testFactor, orderDeriv)
				dataClasses += (dataVar, )
		
		# pdb.set_trace()
		for dataClass in dataClasses: #For each class variable

			if dataClass.get_mag() == mag: #Only to dataClass with the current mag


				# mag = dataClass.get_mag()

				#Create summmary file
				if CMDoptionsDict['writeStepResultsToFileFlag']:
					# pdb.set_trace()
					fileOutComeSummaryForVarAndMag = open(os.path.join(CMDoptionsDict['stepsSummaryResultsFolder'], dataClass.get_mag()+'__'+dataClass.get_description()+'.csv'), 'w')
					fileOutComeSummaryForVarAndMag.write(','.join(['step ID', 'max', 'min', 'mean']) + '\n') 
				else:
					fileOutComeSummaryForVarAndMag = []

				#Main inner loop
				print('\n'+'---> Importing data for variable: ' + dataClass.get_description() + ', '+dataClass.get_mag()+ ' values')
					
				for fileNameList in listOfFilesSortedInFolder: #For each file matching the criteria

					shortFileName = fileNameList[1]
					longFileName = os.path.join(fileNameList[0], fileNameList[1])
					if dataClass.get_description() in shortFileName.split('__')[1] and shortFileName.split('__')[1] in dataClass.get_description(): #Restring to only file matching type of variable of class
						print('\n'+'-> Reading: ' + shortFileName)
						dataClass.importDataForClass(shortFileName, longFileName, dataClass.get_mag(), CMDoptionsDict, fileOutComeSummaryForVarAndMag)

				#Here dataClass has collected the full data for a variable and magnitude

				#Close data summary to file
				if CMDoptionsDict['writeStepResultsToFileFlag']:
					fileOutComeSummaryForVarAndMag.close()
				
				#Time operations				
				if dataClass.get_mag() in ('hp', 'lp', 'di'):
					dataClass.getTimeList('rs')
				else:
					dataClass.getTimeList(dataClass.get_mag())
				
				dataClass.reStartXvaluesAndLastID()

				if dataClass.get_mag() == 'rs' and False:

					newPicksMax, newPicksMean, newPicksMin, timePicks = dataClass.computePicks() ###STRANGE ERROR, PYTHON BUG?
					dataClass.updatePicksData(newPicksMax, newPicksMean, newPicksMin, timePicks)
		
		# Up to here all the data for a single variable has bee imported 

		# Plotting
		for dataClass in dataClasses: #For each class variable

			#Plotting max, min and mean from DIAdem
			# dataClass.plotMaxMinMean_fromDIAdem(plotSettings)

			#Plotting resampled total data
			if (CMDoptionsDict['showFigures'] or CMDoptionsDict['saveFigure']) and not CMDoptionsDict['additionalCalsFlag']:
				dataClass.plotResampled(plotSettings, CMDoptionsDict, dataClass.get_mag(), (False, [], []), inputDataClass)

			# dataClass.plotMinMeanMax(plotSettings)
			# pass

	# Additional calculations
	if CMDoptionsDict['additionalCalsFlag']:

		print('\n\n'+'-> Additional calculations in progress...')

		# dataAdditional = dataFromGaugesSingleMagnitudeClass('forceFighting', testFactor, orderDeriv)
		if CMDoptionsDict['additionalCalsOpt'] == 1:
			dataAdditional = dataFromGaugesSingleMagnitudeClass('forceFightingEyes(HP1-HP2)', 'rs', testFactor, orderDeriv)
			dataAdditional.addDataManual1(dataClasses)
			dataAdditional.plotResampled(plotSettings, CMDoptionsDict, dataAdditional.get_mag(), (False, [], []), inputDataClass)
		elif CMDoptionsDict['additionalCalsOpt'] == 2:
			dataAdditional = dataFromGaugesSingleMagnitudeClass('forceSumEyes(HP1+HP2)', 'rs', testFactor, orderDeriv)
			dataAdditional.addDataManual2(dataClasses)
			dataAdditional.plotResampled(plotSettings, CMDoptionsDict, dataAdditional.get_mag(), (True, dataClasses, 'OutputForce'), inputDataClass)
		elif CMDoptionsDict['additionalCalsOpt'] == 3:
			# dataAdditional = dataFromGaugesSingleMagnitudeClass('forceSumEyes(HP1+HP2)', 'rs', testFactor, orderDeriv)
			# dataAdditional.addDataManual2(dataClasses)
			dataClass.plotResampled(plotSettings, CMDoptionsDict, dataAdditional.get_mag(), (True, dataClasses, ('BoosterLinklong','BoosterLinklat','BoosterLinkcol')), inputDataClass)

		elif CMDoptionsDict['additionalCalsOpt'] == 4:

			# Show relationship between internal leakage and tempertature

			# python main.py -f filesToLoad_gauges_actuatorPerformance.txt -v Temp1,Temp2,VolFlow1,VolFlow2 -m rs -o f -s f,t -a 4 -c f -n t -r 3-SN002-1.3,8-SN002-2.4,10-SN0012-1.3,13-SN0012-2.4,3-Step-1.3,7-Step-2.4 -w t -l f
			# python main.py -f filesToLoad_gauges_actuatorPerformance.txt -v Temp1,Temp2,VolFlow1,VolFlow2 -m rs -o f -s f,t -a 4 -c f -n t -r 7-Step-2.4 -w t -l f

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
			markerDict = {'3-SN002-1.3':'o',	'8-SN002-2.4':'+',	'10-SN0012-1.3':'o',	'13-SN0012-2.4':'+', '3-Step-1.3':'o',	'7-Step-2.4':'+'}
			linestyleDict = {'3-SN002-1.3':'',	'8-SN002-2.4':'',	'10-SN0012-1.3':'',	'13-SN0012-2.4':'', '3-Step-1.3':'',	'7-Step-2.4':''}
			colorsDict = {'3-SN002-1.3':plotSettings['colors'][0],	'8-SN002-2.4':plotSettings['colors'][0],	'10-SN0012-1.3':plotSettings['colors'][1],	'13-SN0012-2.4':plotSettings['colors'][1], '3-Step-1.3':plotSettings['colors'][2], '7-Step-2.4':plotSettings['colors'][2]}
			labelsDict = {'3-SN002-1.3':'SN002 / 100bar / CF ON',	'8-SN002-2.4':'SN002 / 100bar / CF OFF', '10-SN0012-1.3':'SN0012 / 100bar / CF ON', '13-SN0012-2.4':'SN0012 / 100bar / CF OFF', '3-Step-1.3':'150bar / CF ON', '7-Step-2.4':'150bar / CF OFF'}
			titlesDict = {0 : 'System 1', 1: 'System 2'}
			i=0
			for dataTemp,dataVolFlow in zip([dataTemp1,dataTemp2],[dataVolFlow1,dataVolFlow2]):
				assert dataVolFlow.get_stepID() == dataTemp.get_stepID(), 'Error'
				for j in range(len(dataVolFlow.get_stepID())):
					axs[i].plot( dataTemp.get_rs_split()[j], dataVolFlow.get_rs_split()[j], linestyle = linestyleDict[dataVolFlow.get_stepID()[j]], marker = markerDict[dataVolFlow.get_stepID()[j]], c = colorsDict[dataVolFlow.get_stepID()[j]], label = labelsDict[dataVolFlow.get_stepID()[j]], **plotSettings['line'])
				axs[i].set_ylabel(inputDataClass.get_variablesInfoDict()[mag+'__'+dataVolFlow.get_description()]['y-label'], **plotSettings['axes_y'])
				axs[i].set_title(titlesDict[i], **plotSettings['ax_title'])
				axs[i].legend(**plotSettings['legend'])
				usualSettingsAX(axs[i], plotSettings)
				i+=1
			axs[-1].set_xlabel(inputDataClass.get_variablesInfoDict()[mag+'__'+dataTemp.get_description()]['y-label'], **plotSettings['axes_x'])

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
				ax.set_ylabel(inputDataClass.get_variablesInfoDict()[mag+'__'+dataVolFlow1.get_description()]['y-label'], **plotSettings['axes_y'])
				ax.set_title(titlesDict[i], **plotSettings['ax_title'])
				ax.legend(**plotSettings['legend'])
				usualSettingsAX(ax, plotSettings)
				
				i+=1
			axs[-1].set_xlabel('Temp. [$^\circ$C]', **plotSettings['axes_x'])

		elif CMDoptionsDict['additionalCalsOpt'] == 5:
			# Plot flow rate versus force
			# Test 2.4 contains the relationship between temperature and volume flow for zero force
			# Remove contribution from the temperature to the volume flow shown in test 1.3

			# CMD execution line:
			# python main.py -f filesToLoad_gauges_actuatorPerformance.txt -v Temp1,Temp2,VolFlow1,VolFlow2,OutputForce -m rs -o f -s f,t -a 5 -c f -n t -r 3-SN002-1.3,8-SN002-2.4,10-SN0012-1.3,13-SN0012-2.4,7-Step-2.4,1-Step-1.1,3-Step-1.3 -w f

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
			figure_VolflowVSForce_actuators.suptitle('Increment of flow volume rate due to output force (effect of temperature removed)', **plotSettings['figure_title'])

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

				axs[0].plot( dataOutputForceToPlot, dataVolFlowToPlot1, linestyle = '', marker = markerDict[stepStr], c = colorsDict[stepStr], label = stepStr, **plotSettings['line'])
				axs[1].plot( dataOutputForceToPlot, dataVolFlowToPlot2, linestyle = '', marker = markerDict[stepStr], c = colorsDict[stepStr], label = stepStr, **plotSettings['line'])

				# Save results
				results[stepStr] = {'force' : dataOutputForceToPlot, 'flow' : [dataVolFlowToPlot1, dataVolFlowToPlot2]}

			# Axis labels
			axs[0].set_ylabel(inputDataClass.get_variablesInfoDict()[mag+'__'+dataVolFlow1.get_description()]['y-label'], **plotSettings['axes_y'])
			axs[0].set_title(dataVolFlow1.get_description(), **plotSettings['ax_title'])
			
			axs[1].set_ylabel(inputDataClass.get_variablesInfoDict()[mag+'__'+dataVolFlow2.get_description()]['y-label'], **plotSettings['axes_y'])
			axs[1].set_title(dataVolFlow2.get_description(), **plotSettings['ax_title'])

			axs[-1].set_xlabel(inputDataClass.get_variablesInfoDict()[mag+'__'+dataOutputForce.get_description()]['y-label'], **plotSettings['axes_x'])

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
			axs[0].set_ylabel(inputDataClass.get_variablesInfoDict()[mag+'__'+dataVolFlow1.get_description()]['y-label'], **plotSettings['axes_y'])
			axs[1].set_ylabel(inputDataClass.get_variablesInfoDict()[mag+'__'+dataVolFlow2.get_description()]['y-label'], **plotSettings['axes_y'])

			axs[-1].set_xlabel(inputDataClass.get_variablesInfoDict()[mag+'__'+dataOutputForce.get_description()]['y-label'], **plotSettings['axes_x'])

			i = 0
			for ax in axs:
				ax.set_title(titlesDict[i], **plotSettings['ax_title'])
				ax.legend(**plotSettings['legend'])
				usualSettingsAX(ax, plotSettings)
				i+=1

		elif CMDoptionsDict['additionalCalsOpt'] == 6:
			# Plot flow rate versus temperature for various operating pressures

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
				ax.plot( xOldLim, 2*[2.3], linestyle = '--', marker = '', c = plotSettings['colors'][4], scalex = False, scaley = False, **plotSettings['line'])
				ax.annotate('$Q_{\mathrm{pump,max}}/4$', [0.0, 2.3], xytext = [1, 8], fontsize=12, textcoords = 'offset pixels')

				# ax.plot(2*[limsDictP2[i]], ax.get_ylim(),linestyle = '--', marker = '', c = plotSettings['colors'][1], scaley = False, scalex = False, **plotSettings['line'])
				# ax.annotate(annotateDictP2[i], [limsDictP2[i], 0.0], xytext = [1, 8], fontsize=12, textcoords = 'offset pixels')
				ax.set_xlim([0.0, xOldLim[1]])
				ax.set_ylim([0.0, yOldLim[1]])
				
				ax.set_ylabel(inputDataClass.get_variablesInfoDict()[mag+'__'+dataVolFlow1.get_description()]['y-label'], **plotSettings['axes_y'])
				ax.set_title(titlesDict[i], **plotSettings['ax_title'])
				ax.legend(**plotSettings['legend'])
				usualSettingsAX(ax, plotSettings)
				
				i+=1
			axs[-1].set_xlabel('Temp. [$^\circ$C]', **plotSettings['axes_x'])

		elif CMDoptionsDict['additionalCalsOpt'] == 7:
			# Plot flow rate versus temperature for various operating pressures
			# python main.py -f filesToLoad_gauges_actuatorPerformance.txt -v VolFlow1,VolFlow2,Temp1,Temp2 -m rs -o f -s f,t -c f -n t -w f -l t -r 3-SN002-1.3,10-SN0012-1.3,8-SN002-2.4,13-SN0012-2.4 -a 7

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

		elif CMDoptionsDict['additionalCalsOpt'] == 8:

			# Estimate the volume flow considering the piston velocities recorded during flight
			# python main.py -f filesToLoad_gauges_P2_FTI_100Hz.txt -v CNT_DST_BST_COL,CNT_DST_BST_LNG,CNT_DST_BST_LAT -m di -o f -s f,t -a 8 -c f -n f -w f -l t -r 192-FT0106

			dictCalc = {'Q_COL' : ['CNT_DST_BST_COL', 150],
						'Q_LNG' : ['CNT_DST_BST_LNG', 77.75],
						'Q_LAT' : ['CNT_DST_BST_LAT', 77.75]}

			exampleDataClass = [temp for temp in dataClasses if temp.get_description() == 'CNT_DST_BST_COL'][0]
			newCalc = len(exampleDataClass.get_rs())* [0.0]
			
			for key in dictCalc.keys():
				dataAdditional = dataFromGaugesSingleMagnitudeClass(key, 'rs', testFactor, orderDeriv)
				dataAdditional.addDataManual3(dataClasses, dictCalc[key][0], dictCalc[key][1])

				temp = [p+o for p,o in zip(dataAdditional.get_rs(), newCalc)]
				newCalc = temp

				dataClasses += (dataAdditional, )

			dataAdditionalPed = dataFromGaugesSingleMagnitudeClass('Q_PED', 'rs', testFactor, orderDeriv)
			dataAdditionalPed.addDataManual5(dataClasses)
			dataClasses += (dataAdditionalPed, )

			newCalc = [o+p for o,p in zip(temp, dataAdditionalPed.get_rs())]

			dataAdditional = dataFromGaugesSingleMagnitudeClass('Total_Q', 'rs', testFactor, orderDeriv)
			dataAdditional.addDataManual4(newCalc, exampleDataClass)
			dataClasses += (dataAdditional, )

			dataAdditional.plotResampled(plotSettings, CMDoptionsDict, dataAdditional.get_mag(), (True, dataClasses, [i for i in dictCalc.keys()]+['Q_PED','Total_Q']), inputDataClass)

		elif CMDoptionsDict['additionalCalsOpt'] == 9:

			# python main.py -f filesToLoad_gauges_P2_FTI_100Hz.txt -v CNT_DST_BST_COL,CNT_FRC_BST_COL,CNT_DST_BST_LNG,CNT_FRC_BST_LNG,CNT_DST_BST_LAT,CNT_FRC_BST_LAT,HYD_ARI_MFD_TMP_1,HYD_ARI_MFD_TMP_2 -m rs,di -o f -s t,t -a 9 -c f -n t -l f -w f -r 192-FT0106

			calculateFlowFlight(dataClasses, testFactor, plotSettings, CMDoptionsDict)

	os.chdir(cwd)

#Import data from actuator
elif actuatorFlag:

	# Import plot settings
	plotSettings = importPlottingOptions()

	print('\n'+'**** Running data analysis program for actuator measurements'+'\n')
	inputDataClass = loadFileAddressesAndData(CMDoptionsDict['fileNameOfFileToLoadFiles'], 'actuator')

	dataFromRuns, previousNCycles, iFile = [], 0, 1

	for file in inputDataClass.getTupleFiles():

		if float(file.split('\\')[-1].split('_')[1]) in CMDoptionsDict['rangeFileIDs']:

			print('-> Reading: ' + file.split('\\')[-1])
			dataFromRun_temp = importDataActuator(file, iFile, CMDoptionsDict, inputDataClass)

			dataFromRun_temp.setAbsoluteNCycles(previousNCycles)

			previousNCycles = dataFromRun_temp.get_absoluteNCycles()[-1]

			print('\t'+'-> Last computed data point index (accumulated): ' + str(int(previousNCycles)/1000000.0) + ' millions')

			dataFromRuns += [dataFromRun_temp]

			iFile += 1


	#################################
	#Calculate std and mean of recorded values
	if 'OC' in CMDoptionsDict['fileNameOfFileToLoadFiles']:
		calculate_stats(dataFromRuns[:-2]) #Only the first loading phase
	else:
		calculate_stats(dataFromRuns)

	#################################
	#Plot data
	# dataFromRuns[0].plotSingleRun(plotSettings)
	# dataFromRuns[-1].plotSingleRun(plotSettings)

	plotAllRuns_force(dataFromRuns, plotSettings, CMDoptionsDict, inputDataClass)
	plotAllRuns_displacement(dataFromRuns, plotSettings, CMDoptionsDict, inputDataClass)

elif actuatorMesswerteFlag:

	# Import plot settings
	plotSettings = importPlottingOptions()

	print('\n'+'**** Running data analysis program for actuator measurements, all data'+'\n')
	inputDataClass = loadFileAddressesAndData(CMDoptionsDict['fileNameOfFileToLoadFiles'], 'actuatorMesswerte')

	dataFromRuns, iFile, lastDataPointCounter, lastTimeList, totalTime = [], 1, 0, [], []

	for file in inputDataClass.getTupleFiles():

		if int(file.split('\\')[-1].split('_')[1]) in [int(o) for o in CMDoptionsDict['rangeFileIDs']]: #Filter out test steps that are not specified 

			print('-> Reading: ' + file.split('\\')[-1])
			dataFromRun_temp = importDataActuator(file, iFile, CMDoptionsDict, inputDataClass)

			lastDataPointCounter += dataFromRun_temp.get_lastDataPointCounter()
			
			if not lastTimeList: #If list is empty
				lastTimeList += [dataFromRun_temp.get_time()[-1]]
			else:
				lastTimeList += [lastTimeList[-1]+dataFromRun_temp.get_time()[-1]]

			print('\t'+'-> Last computed data point index (accumulated): ' + str(int(lastDataPointCounter)/1000000.0) + ' millions')

			dataFromRuns += [dataFromRun_temp]

			iFile += 1

	timesDict = {'lastTimeList': lastTimeList}

	# plotAllRuns_force_Messwerte(dataFromRuns, plotSettings, CMDoptionsDict, inputDataClass)
	# plotAllRuns_filtered_Messwerte(dataFromRuns, timesDict, plotSettings, CMDoptionsDict, inputDataClass)
	plotStiffnessForChoosenSteps_Messwerte(dataFromRuns, timesDict, plotSettings, CMDoptionsDict, inputDataClass)


plt.show(block = CMDoptionsDict['showFigures'])